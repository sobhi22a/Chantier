using System.Security.Cryptography;
using Chantier.Core.Exceptions;

namespace Chantier.Infrastructure.Imaging;

/// <summary>
/// Flux en lecture seule qui <b>compte</b> les octets (413 <c>FICHIER_TROP_GROS</c> au-dela de la limite, sans lire plus loin) et calcule leur empreinte SHA-256 au
/// fil de la lecture : un fichier n'est jamais charge entier en memoire.
/// </summary>
public sealed class MeteredStream(Stream inner, long maxBytes) : Stream
{
    private readonly IncrementalHash _hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);

    public long BytesRead { get; private set; }

    /// <summary>Lit ce qui reste pour que l'empreinte couvre tout le corps (fichier deja envoye : on ne le stocke pas, on le compare).</summary>
    public async Task DrainAsync(CancellationToken cancellationToken)
    {
        var buffer = new byte[16 * 1024];
        while (await ReadAsync(buffer, cancellationToken) > 0)
        {
        }
    }

    /// <summary>Empreinte en hexadecimal minuscule (a appeler une fois le flux lu jusqu'au bout).</summary>
    public string Sha256Hex() => Convert.ToHexStringLower(_hash.GetHashAndReset());

    public override async ValueTask<int> ReadAsync(Memory<byte> buffer, CancellationToken cancellationToken = default)
    {
        var read = await inner.ReadAsync(buffer, cancellationToken);
        Count(buffer.Span[..read]);
        return read;
    }

    public override async Task<int> ReadAsync(byte[] buffer, int offset, int count, CancellationToken cancellationToken)
        => await ReadAsync(buffer.AsMemory(offset, count), cancellationToken);

    public override int Read(byte[] buffer, int offset, int count)
    {
        var read = inner.Read(buffer, offset, count);
        Count(buffer.AsSpan(offset, read));
        return read;
    }

    private void Count(ReadOnlySpan<byte> bytes)
    {
        BytesRead += bytes.Length;
        if (BytesRead > maxBytes)
        {
            throw new FileTooLargeException();
        }

        _hash.AppendData(bytes);
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _hash.Dispose();
        }

        base.Dispose(disposing);
    }

    public override bool CanRead => true;

    public override bool CanSeek => false;

    public override bool CanWrite => false;

    public override long Length => throw new NotSupportedException();

    public override long Position
    {
        get => throw new NotSupportedException();
        set => throw new NotSupportedException();
    }

    public override void Flush()
    {
    }

    public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();

    public override void SetLength(long value) => throw new NotSupportedException();

    public override void Write(byte[] buffer, int offset, int count) => throw new NotSupportedException();
}
