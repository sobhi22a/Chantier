using Microsoft.AspNetCore.Identity;

namespace Chantier.Core.Entities.Identity;

/// <summary>
/// Compte utilisateur (ASP.NET Identity, cle GUID). Jamais supprime : desactive (H-13).
/// <see cref="IdentityUser{TKey}.PhoneNumber"/> est une donnee personnelle : jamais journalisee, renvoyee seulement a son titulaire.
/// </summary>
public class AppUser : IdentityUser<Guid>
{
    public const string French = "fr";
    public const string Arabic = "ar";

    public string FullName { get; set; } = string.Empty;

    /// <summary><c>fr</c> ou <c>ar</c> ; defaut <c>fr</c> (CA-014.2).</summary>
    public string Language { get; set; } = French;

    /// <summary>Mot de passe provisoire : changement obligatoire avant toute autre action (CA-001.7).</summary>
    public bool MustChangePassword { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTimeOffset? DeactivatedAt { get; set; }

    public static bool IsSupportedLanguage(string? language)
        => language is French or Arabic;

    public static AppUser Create(string userName, string fullName, string language = French, string? phoneNumber = null, bool mustChangePassword = false)
        => new()
        {
            Id = Guid.CreateVersion7(),
            UserName = userName,
            FullName = fullName,
            Language = language,
            PhoneNumber = phoneNumber,
            MustChangePassword = mustChangePassword,
            IsActive = true,
        };
}
