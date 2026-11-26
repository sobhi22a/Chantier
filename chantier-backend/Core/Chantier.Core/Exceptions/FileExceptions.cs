namespace Chantier.Core.Exceptions;

/// <summary>Fichier plus gros que la limite (<c>Storage:MaxPhotoBytes</c>) : 413 <c>FICHIER_TROP_GROS</c>.</summary>
public sealed class FileTooLargeException : DomainException
{
    public FileTooLargeException() : base(ErrorCodes.FichierTropGros, "Le fichier est trop volumineux.")
    {
    }
}

/// <summary>Fichier qui n'est pas un JPEG (octets magiques ou type annonce) : 415 <c>TYPE_FICHIER_REFUSE</c>.</summary>
public sealed class UnsupportedFileTypeException : DomainException
{
    public UnsupportedFileTypeException() : base(ErrorCodes.TypeFichierRefuse, "Seules les images JPEG sont acceptées.")
    {
    }
}
