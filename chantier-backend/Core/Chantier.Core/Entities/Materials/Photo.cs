using Chantier.Core.Entities.Common;

namespace Chantier.Core.Entities.Materials;

/// <summary>
/// Photo d'un bon de livraison (ADR 0013) : les metadonnees se creent d'abord (hors ligne possible, idempotentes par <see cref="ClientId"/>), le binaire JPEG
/// s'envoie ensuite par un <c>PUT</c> (un fichier a la fois). Ni chemin de stockage ni empreinte dans les reponses. <c>DeliveryId</c> est obligatoire dans ce
/// lot (le lot « photos » le rendra facultatif et ajoutera les autres liens). Jamais supprimee dans ce lot.
/// </summary>
public class Photo : BasicEntity, ISiteScoped, IHasClientId
{
    public const string JpegContentType = "image/jpeg";

    // EF Core
    private Photo()
    {
    }

    public Guid SiteId { get; private set; }

    public Guid? ClientId { get; private set; }

    public DateTimeOffset? ClientCreatedAt { get; private set; }

    public Guid DeliveryId { get; private set; }

    /// <summary>Heure de prise de vue du telephone : information seulement.</summary>
    public DateTimeOffset TakenAt { get; private set; }

    public string ContentType { get; private set; } = JpegContentType;

    /// <summary>Taille declaree a la creation, puis taille du fichier stocke une fois envoye (les metadonnees EXIF retirees l'ont reduit).</summary>
    public long SizeBytes { get; private set; }

    /// <summary>Empreinte SHA-256 declaree du fichier envoye par le telephone (64 caracteres hexadecimaux, minuscules) : rend l'envoi idempotent.</summary>
    public string Sha256 { get; private set; } = string.Empty;

    /// <summary>Cle de stockage relative (jamais exposee), aleatoire : <c>&lt;chantier&gt;/&lt;annee&gt;/&lt;mois&gt;/&lt;guid&gt;.jpg</c>.</summary>
    public string? StorageKey { get; private set; }

    public PhotoContentStatus ContentStatus { get; private set; }

    public DateTimeOffset? UploadedAt { get; private set; }

    public bool IsUploaded => ContentStatus == PhotoContentStatus.Uploaded;

    public static Photo Create(Guid siteId, Guid deliveryId, Guid clientId, DateTimeOffset? clientCreatedAt, DateTimeOffset takenAt, long sizeBytes, string sha256)
        => new()
        {
            SiteId = siteId,
            DeliveryId = deliveryId,
            ClientId = clientId,
            ClientCreatedAt = clientCreatedAt,
            TakenAt = takenAt,
            ContentType = JpegContentType,
            SizeBytes = sizeBytes,
            Sha256 = sha256,
            ContentStatus = PhotoContentStatus.Pending,
        };

    public void MarkUploaded(string storageKey, long storedBytes, DateTimeOffset at)
    {
        StorageKey = storageKey;
        SizeBytes = storedBytes;
        ContentStatus = PhotoContentStatus.Uploaded;
        UploadedAt = at;
    }
}
