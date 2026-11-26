using System.Text.RegularExpressions;
using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Specifications.Materials;
using Chantier.Infrastructure.Imaging;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// Photos des bons de livraison (ADR 0013). Deux temps : les metadonnees (idempotentes par <c>clientId</c>, creables hors ligne, 5 par livraison au plus), puis le fichier
/// JPEG, un a la fois : octets magiques, taille limitee, empreinte SHA-256 comparee a celle declaree, metadonnees EXIF retirees sans reencodage, ecriture dans un fichier
/// temporaire puis deplacement sous un nom aleatoire. Un envoi identique est sans effet (200), un contenu different sur une photo deja envoyee est refuse (409).
/// La lecture exige <c>DeliveryPhotos.View</c> : sans elle, ou pour un autre chantier, la photo est introuvable (404 indiscernable).
/// </summary>
public sealed partial class PhotoService(
    ApplicationDbContext db,
    IRepositoryBase<Photo> photos,
    IRepositoryBase<Delivery> deliveries,
    IRepositoryBase<Site> sites,
    IPhotoStorage storage,
    IRequestEventWriter events,
    IUserPermissions permissions,
    IOptions<MaterialsOptions> options,
    IOptions<PhotoStorageOptions> storageOptions,
    TimeProvider time) : IPhotoService
{
    private const string JpegContentType = Photo.JpegContentType;

    [GeneratedRegex("^[0-9a-fA-F]{64}$")]
    private static partial Regex Sha256Pattern();

    private long MaxBytes => storageOptions.Value.MaxPhotoBytes;

    public async Task<PhotoCreationResult> CreateAsync(Guid siteId, Guid deliveryId, CreatePhotoDto dto, RequestActionContext? context = null, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.DeliveryPhotosCreate, cancellationToken);

        var errors = new Core.Validation.ErrorCollector();
        if (dto.ClientId is null || dto.ClientId == Guid.Empty)
        {
            errors.Add("clientId", "L'identifiant client est obligatoire.");
        }

        if (dto.TakenAt is null)
        {
            errors.Add("takenAt", "La date de prise de vue est obligatoire.");
        }

        if (dto.SizeBytes is null or <= 0)
        {
            errors.Add("sizeBytes", "La taille du fichier est obligatoire.");
        }

        if (dto.Sha256 is null || !Sha256Pattern().IsMatch(dto.Sha256))
        {
            errors.Add("sha256", "L'empreinte SHA-256 est obligatoire (64 caractères hexadécimaux).");
        }

        errors.ThrowIfAny();

        if (!IsJpeg(dto.ContentType))
        {
            throw new UnsupportedFileTypeException();
        }

        if (dto.SizeBytes > MaxBytes)
        {
            throw new FileTooLargeException();
        }

        var clientId = dto.ClientId!.Value;

        // Renvoi du meme clientId : memes metadonnees, aucun effet (meme si la livraison a ete annulee depuis).
        if (await FindByClientIdAsync(siteId, clientId, cancellationToken) is { } existing)
        {
            return Existing(existing, deliveryId);
        }

        await EnsureSiteWritableAsync(siteId, cancellationToken);

        try
        {
            var created = await DbTransactions.RunAsync(db, async () =>
            {
                await AppLocks.AcquireAsync(db, MaterialLocks.Delivery(deliveryId), cancellationToken);
                return await MaterialLocks.RetryAsync(db, async () =>
                {
                    if (await FindByClientIdAsync(siteId, clientId, cancellationToken) is { } known)
                    {
                        return (Photo: known, Created: false);
                    }

                    var delivery = await deliveries.FirstOrDefaultAsync(new DeliveryBySiteAndIdSpecification(siteId, deliveryId), cancellationToken)
                        ?? throw new NotFoundException();
                    if (delivery.IsCancelled)
                    {
                        throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Une livraison annulée ne reçoit plus de photo.");
                    }

                    // R2-05 : les places sont les photos recues et les envois recents encore en attente ; une metadonnee dont le fichier n'est jamais arrive
                    // libere sa place apres PendingPhotoHoldHours (elle ne bloque plus la livraison a vie).
                    var holdSince = time.GetUtcNow().AddHours(-options.Value.PendingPhotoHoldHours);
                    var taken = await db.Photos.CountAsync(
                        photo => photo.DeliveryId == deliveryId && (photo.ContentStatus == PhotoContentStatus.Uploaded || photo.CreatedAt > holdSince), cancellationToken);
                    if (taken >= options.Value.MaxPhotosPerDelivery)
                    {
                        throw new DomainRuleException(ErrorCodes.PhotosTropNombreuses, "Le nombre maximal de photos pour cette livraison est atteint.");
                    }

                    var photo = Photo.Create(siteId, deliveryId, clientId, dto.ClientCreatedAt, dto.TakenAt!.Value, dto.SizeBytes!.Value, dto.Sha256!.ToLowerInvariant());
                    db.Photos.Add(photo);
                    await db.SaveChangesAsync(cancellationToken);
                    return (Photo: photo, Created: true);
                });
            }, cancellationToken);

            return new PhotoCreationResult(PhotoResponse.From(created.Photo), created.Created);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            // Deux envois du meme clientId en parallele : l'index unique tranche.
            db.ChangeTracker.Clear();
            if (await FindByClientIdAsync(siteId, clientId, cancellationToken) is { } winner)
            {
                return Existing(winner, deliveryId);
            }

            throw;
        }
    }

    public async Task<PhotoUploadResult> UploadAsync(Guid siteId, Guid photoId, Stream content, string? contentType, long? declaredLength, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.DeliveryPhotosCreate, cancellationToken);

        if (!IsJpeg(contentType))
        {
            throw new UnsupportedFileTypeException();
        }

        if (declaredLength > MaxBytes)
        {
            throw new FileTooLargeException();
        }

        var photo = await LoadAsync(siteId, photoId, cancellationToken);
        await using var metered = new MeteredStream(content, MaxBytes);

        // Deja envoyee : le meme contenu est un renvoi (200 sans effet), un autre contenu est refuse.
        if (photo.IsUploaded)
        {
            await metered.DrainAsync(cancellationToken);
            return metered.Sha256Hex() == photo.Sha256
                ? new PhotoUploadResult(PhotoResponse.From(photo), Stored: false)
                : throw new ConflictException(PhotoResponse.From(photo), ErrorCodes.PhotoDejaEnvoyee);
        }

        await EnsureSiteWritableAsync(siteId, cancellationToken);

        string key;
        long storedBytes;
        await using (var staged = await storage.StageAsync(cancellationToken))
        {
            storedBytes = await JpegMetadataStripper.StripAsync(metered, staged.Stream, cancellationToken);
            if (metered.Sha256Hex() != photo.Sha256)
            {
                throw new DomainRuleException(ErrorCodes.TypeFichierRefuse, "Le contenu ne correspond pas à l'empreinte déclarée.");
            }

            key = await storage.CommitAsync(staged, siteId, time.GetUtcNow(), cancellationToken);
        }

        try
        {
            return await DbTransactions.RunAsync(db, async () =>
            {

                // Ordre des verrous (MaterialLocks) : la livraison (dont la photo recue met a jour le compteur), puis la photo.
                await AppLocks.AcquireAsync(db, MaterialLocks.Delivery(photo.DeliveryId), cancellationToken);
                await AppLocks.AcquireAsync(db, MaterialLocks.Photo(photoId), cancellationToken);
                return await MaterialLocks.RetryAsync(db, async () =>
                {
                    // R2-04 : la photo lue plus haut est deja suivie par le contexte ; la relire sans vider le suivi rendrait l'etat perime (« en attente ») et
                    // l'ecriture perdrait sur le rowversion (409 pour un fichier pourtant recu). Apres le verrou, on repart d'une lecture neuve.
                    db.ChangeTracker.Clear();
                    var current = await LoadAsync(siteId, photoId, cancellationToken);

                    // Un autre envoi du meme fichier a gagne la course : le notre est sans effet (meme empreinte declaree par construction).
                    if (current.IsUploaded)
                    {
                        await storage.DeleteAsync(key, cancellationToken);
                        return new PhotoUploadResult(PhotoResponse.From(current), Stored: false);
                    }

                    current.MarkUploaded(key, storedBytes, time.GetUtcNow());

                    // La photo n'existe pour de bon qu'ici (R2-05) : le compteur de la livraison (« BL manquant ») et l'historique n'avancent qu'avec le fichier.
                    var delivery = await deliveries.FirstOrDefaultAsync(new DeliveryBySiteAndIdSpecification(siteId, current.DeliveryId), cancellationToken)
                        ?? throw new NotFoundException();
                    delivery.AddPhoto();
                    events.Add(delivery, MaterialEventType.PhotoAdded, RequestActionContext.Api);
                    await db.SaveChangesAsync(cancellationToken);
                    return new PhotoUploadResult(PhotoResponse.From(current), Stored: true);
                });
            }, cancellationToken);
        }
        catch
        {
            // Jamais de fichier orphelin si l'ecriture de la ligne echoue.
            await storage.DeleteAsync(key, CancellationToken.None);
            throw;
        }
    }

    public async Task<PhotoContent> OpenAsync(Guid siteId, Guid photoId, CancellationToken cancellationToken = default)
    {
        // Sans la permission : meme reponse qu'une photo inexistante ou d'un autre chantier.
        if (!await permissions.HasAsync(Permissions.DeliveryPhotosView, cancellationToken))
        {
            throw new NotFoundException();
        }

        var photo = await LoadAsync(siteId, photoId, cancellationToken);
        if (photo.StorageKey is not { } key || storage.OpenRead(key) is not { } stream)
        {
            throw new NotFoundException();
        }

        return new PhotoContent(stream, photo.ContentType, stream.Length);
    }

    // --- Outils ---

    private static PhotoCreationResult Existing(Photo existing, Guid deliveryId)
    {
        // Le meme clientId pour une autre livraison est une erreur de saisie, jamais la photo d'une autre livraison.
        if (existing.DeliveryId != deliveryId)
        {
            throw new Core.Exceptions.ValidationException("clientId", "Cet identifiant client est déjà utilisé.");
        }

        return new PhotoCreationResult(PhotoResponse.From(existing), Created: false);
    }

    private static bool IsJpeg(string? contentType)
        => string.Equals(contentType?.Split(';')[0].Trim(), JpegContentType, StringComparison.OrdinalIgnoreCase);

    private async Task<Photo> LoadAsync(Guid siteId, Guid photoId, CancellationToken cancellationToken)
        => await photos.FirstOrDefaultAsync(new PhotoBySiteAndIdSpecification(siteId, photoId), cancellationToken) ?? throw new NotFoundException();

    private async Task<Photo?> FindByClientIdAsync(Guid siteId, Guid clientId, CancellationToken cancellationToken)
        => await photos.FirstOrDefaultAsync(new PhotoByClientIdSpecification(siteId, clientId), cancellationToken);

    private async Task EnsureSiteWritableAsync(Guid siteId, CancellationToken cancellationToken)
    {
        var site = await sites.GetByIdAsync(siteId, cancellationToken) ?? throw new NotFoundException();
        site.EnsureWritable();
    }

    private async Task RequireAsync(string permission, CancellationToken cancellationToken)
    {
        if (!await permissions.HasAsync(permission, cancellationToken))
        {
            throw new ForbiddenException();
        }
    }
}
