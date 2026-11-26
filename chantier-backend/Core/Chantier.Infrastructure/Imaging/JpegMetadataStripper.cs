using Chantier.Core.Exceptions;

namespace Chantier.Infrastructure.Imaging;

/// <summary>
/// Retire les metadonnees d'un JPEG <b>sans le reencoder</b> (ADR 0013), par <b>liste blanche</b> (R2-03) : seuls les segments necessaires a l'affichage sont recopies
/// (<c>APP0</c> JFIF, <c>APP14</c> Adobe, tables <c>DQT</c>, <c>DHT</c>, <c>DRI</c>, cadre <c>SOFn</c>, <c>SOS</c> et les donnees des balayages). Tout le reste est ignore, <b>ou qu'il se trouve</b> :
/// <c>APP1</c> (Exif, XMP : coordonnees GPS, date, appareil), <c>APP2</c> (MPF, profil ICC), <c>APP3</c> a <c>APP13</c> (dont Photoshop, IPTC), <c>COM</c>, y compris entre deux balayages
/// d'un JPEG progressif. <b>Tout ce qui suit le premier <c>FF D9</c> (fin d'image) est supprime</b> : images secondaires des appareils, vignette, video d'une photo animee, second JPEG avec
/// son propre Exif. Les octets <c>FF 00</c> et <c>FF D0</c>-<c>D7</c> des donnees d'un balayage sont des donnees, pas des marqueurs. Le flux d'entree est lu en entier (l'empreinte SHA-256 du
/// fichier recu se calcule au fil de la lecture) mais jamais conserve en memoire.
/// Un fichier qui ne commence pas par les octets magiques <c>FF D8 FF</c> est refuse (415) ; un JPEG incoherent (segment tronque, pas d'image, pas de fin <c>FF D9</c>) est
/// refuse (422), jamais stocke tel quel.
/// </summary>
public static class JpegMetadataStripper
{
    private const byte Marker = 0xFF;
    private const byte StartOfImage = 0xD8;
    private const byte EndOfImage = 0xD9;
    private const byte StartOfScan = 0xDA;
    private const byte DefineQuantizationTable = 0xDB;
    private const byte DefineHuffmanTable = 0xC4;
    private const byte DefineRestartInterval = 0xDD;
    private const byte App0 = 0xE0;
    private const byte App14 = 0xEE;

    private static readonly byte[] Jfif = "JFIF\0"u8.ToArray();
    private static readonly byte[] Adobe = "Adobe"u8.ToArray();

    /// <summary>Copie <paramref name="input"/> vers <paramref name="output"/> sans les metadonnees ; renvoie le nombre d'octets ecrits.</summary>
    public static async Task<long> StripAsync(Stream input, Stream output, CancellationToken cancellationToken = default)
    {
        var reader = new ByteReader(input);
        var writer = new ByteWriter(output);

        if (await reader.ReadAsync(cancellationToken) != Marker || await reader.ReadAsync(cancellationToken) != StartOfImage || await reader.ReadAsync(cancellationToken) != Marker)
        {
            throw new UnsupportedFileTypeException();
        }

        await writer.WriteAsync(Marker, cancellationToken);
        await writer.WriteAsync(StartOfImage, cancellationToken);

        var pendingMarker = true; // l'octet FF du premier marqueur a deja ete lu
        var sawFrame = false;

        // Avant le premier balayage : segments d'en-tete.
        while (true)
        {
            var code = await NextMarkerCodeAsync(reader, pendingMarker, cancellationToken);
            pendingMarker = false;

            if (code == EndOfImage)
            {
                throw Invalid();
            }

            // Marqueurs sans segment (RSTn, TEM) : recopies.
            if (code is 0x01 or (>= 0xD0 and <= 0xD7))
            {
                await writer.WriteAsync(Marker, cancellationToken);
                await writer.WriteAsync(code, cancellationToken);
                continue;
            }

            var data = await ReadSegmentAsync(reader, cancellationToken);
            sawFrame |= IsFrame(code);

            if (Keep(code, data))
            {
                await WriteSegmentAsync(writer, code, data, cancellationToken);
            }

            if (code == StartOfScan)
            {
                if (!sawFrame)
                {
                    throw Invalid();
                }

                break;
            }
        }

        await CopyScansAsync(reader, writer, cancellationToken);
        await writer.FlushAsync(cancellationToken);

        // Ce qui suit la fin d'image est lu (pour l'empreinte et la limite de taille) mais jamais ecrit.
        await input.CopyToAsync(Stream.Null, cancellationToken);
        return writer.Total;
    }

    /// <summary>Donnees d'un ou plusieurs balayages (progressif) jusqu'au premier <c>FF D9</c> hors donnees, qui est recopie ; les segments intercales sont filtres.</summary>
    private static async Task CopyScansAsync(ByteReader reader, ByteWriter writer, CancellationToken cancellationToken)
    {
        while (true)
        {
            var value = await reader.ReadAsync(cancellationToken);
            if (value < 0)
            {
                throw Invalid(); // pas de fin d'image
            }

            if (value != Marker)
            {
                await writer.WriteAsync((byte)value, cancellationToken);
                continue;
            }

            var code = await reader.ReadAsync(cancellationToken);
            while (code == Marker)
            {
                code = await reader.ReadAsync(cancellationToken); // octets de remplissage
            }

            if (code < 0)
            {
                throw Invalid();
            }

            if (code == 0x00 || code is >= 0xD0 and <= 0xD7)
            {
                // Donnees entropiques (FF 00) ou marqueur de redemarrage : appartiennent au balayage.
                await writer.WriteAsync(Marker, cancellationToken);
                await writer.WriteAsync((byte)code, cancellationToken);
                continue;
            }

            if (code == EndOfImage)
            {
                await writer.WriteAsync(Marker, cancellationToken);
                await writer.WriteAsync(EndOfImage, cancellationToken);
                return;
            }

            if (code == 0x01)
            {
                continue; // TEM : sans segment, sans utilite
            }

            var data = await ReadSegmentAsync(reader, cancellationToken);
            if (Keep((byte)code, data))
            {
                await WriteSegmentAsync(writer, (byte)code, data, cancellationToken);
            }
        }
    }

    /// <summary>Liste blanche : tables, cadre, balayage, JFIF et Adobe (aucune donnee personnelle) ; tout le reste (APPn, COM...) est ecarte.</summary>
    private static bool Keep(byte code, byte[] data) => code switch
    {
        DefineQuantizationTable or DefineHuffmanTable or DefineRestartInterval or StartOfScan => true,
        App0 => data.AsSpan().StartsWith(Jfif),
        App14 => data.AsSpan().StartsWith(Adobe),
        _ => IsFrame(code),
    };

    private static bool IsFrame(byte code) => code is >= 0xC0 and <= 0xCF and not 0xC4 and not 0xC8 and not 0xCC;

    private static async Task<byte[]> ReadSegmentAsync(ByteReader reader, CancellationToken cancellationToken)
    {
        var high = await reader.ReadAsync(cancellationToken);
        var low = await reader.ReadAsync(cancellationToken);
        if (low < 0)
        {
            throw Invalid();
        }

        var length = (high << 8) | low;
        if (length < 2)
        {
            throw Invalid();
        }

        var data = new byte[length - 2];
        for (var index = 0; index < data.Length; index++)
        {
            var value = await reader.ReadAsync(cancellationToken);
            if (value < 0)
            {
                throw Invalid();
            }

            data[index] = (byte)value;
        }

        return data;
    }

    private static async Task WriteSegmentAsync(ByteWriter writer, byte code, byte[] data, CancellationToken cancellationToken)
    {
        var length = data.Length + 2;
        await writer.WriteAsync(Marker, cancellationToken);
        await writer.WriteAsync(code, cancellationToken);
        await writer.WriteAsync((byte)(length >> 8), cancellationToken);
        await writer.WriteAsync((byte)(length & 0xFF), cancellationToken);
        await writer.WriteAsync(data, cancellationToken);
    }

    /// <summary>Code du prochain marqueur (les octets <c>FF</c> de remplissage sont ignores).</summary>
    private static async Task<byte> NextMarkerCodeAsync(ByteReader reader, bool markerAlreadyRead, CancellationToken cancellationToken)
    {
        if (!markerAlreadyRead && await reader.ReadAsync(cancellationToken) != Marker)
        {
            throw Invalid();
        }

        while (true)
        {
            var value = await reader.ReadAsync(cancellationToken);
            if (value < 0)
            {
                throw Invalid();
            }

            if (value != Marker)
            {
                return value == 0x00 ? throw Invalid() : (byte)value;
            }
        }
    }

    private static DomainRuleException Invalid()
        => new(ErrorCodes.TypeFichierRefuse, "Ce fichier JPEG est illisible ou incomplet.");

    /// <summary>Lecture octet par octet sur un tampon (pas de lecture synchrone du flux : le corps d'une requete ne l'autorise pas).</summary>
    private sealed class ByteReader(Stream stream)
    {
        private readonly byte[] _buffer = new byte[16 * 1024];
        private int _position;
        private int _length;

        /// <summary>Octet suivant, ou <c>-1</c> en fin de flux.</summary>
        public async ValueTask<int> ReadAsync(CancellationToken cancellationToken)
        {
            if (_position == _length)
            {
                _length = await stream.ReadAsync(_buffer, cancellationToken);
                _position = 0;
                if (_length == 0)
                {
                    return -1;
                }
            }

            return _buffer[_position++];
        }
    }

    /// <summary>Ecriture tamponnee (les octets sont ecrits par paquets de 16 Ko) ; compte les octets ecrits.</summary>
    private sealed class ByteWriter(Stream stream)
    {
        private readonly byte[] _buffer = new byte[16 * 1024];
        private int _count;

        public long Total { get; private set; }

        public async ValueTask WriteAsync(byte value, CancellationToken cancellationToken)
        {
            if (_count == _buffer.Length)
            {
                await FlushAsync(cancellationToken);
            }

            _buffer[_count++] = value;
            Total++;
        }

        public async ValueTask WriteAsync(byte[] data, CancellationToken cancellationToken)
        {
            foreach (var value in data)
            {
                await WriteAsync(value, cancellationToken);
            }
        }

        public async ValueTask FlushAsync(CancellationToken cancellationToken)
        {
            if (_count > 0)
            {
                await stream.WriteAsync(_buffer.AsMemory(0, _count), cancellationToken);
                _count = 0;
            }
        }
    }
}
