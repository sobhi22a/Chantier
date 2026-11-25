using System.ComponentModel.DataAnnotations;

namespace Chantier.WebApi.Models.Auth;

public sealed class LoginRequest
{
    /// <summary>Identifiant de connexion.</summary>
    /// <example>chef.dev</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(256, ErrorMessage = "Trop long (256 caractères au maximum).")]
    public string? UserName { get; set; }

    /// <summary>Mot de passe.</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(256, ErrorMessage = "Trop long (256 caractères au maximum).")]
    public string? Password { get; set; }

    /// <summary><c>true</c> : jetons (mobile) ; <c>false</c> : cookie de session (web).</summary>
    public bool IsAppMobile { get; set; }
}

/// <summary>Renouvellement des jetons (mobile).</summary>
public sealed class RefreshRequest
{
    /// <summary>Jeton de rafraîchissement reçu à la connexion ou au dernier renouvellement (il n'est valable qu'une fois).</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? RefreshToken { get; set; }
}

/// <summary>Déconnexion : le corps est facultatif.</summary>
public sealed class LogoutRequest
{
    /// <summary>Jeton de rafraîchissement à révoquer (mobile).</summary>
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? RefreshToken { get; set; }
}

/// <summary>Changement de mot de passe (8 caractères au moins, dont un chiffre).</summary>
public sealed class ChangePasswordRequest
{
    /// <summary>Mot de passe actuel (ou provisoire).</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(256, ErrorMessage = "Trop long (256 caractères au maximum).")]
    public string? CurrentPassword { get; set; }

    /// <summary>Nouveau mot de passe ; sinon 422 <c>MOT_DE_PASSE_FAIBLE</c>.</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(256, ErrorMessage = "Trop long (256 caractères au maximum).")]
    public string? NewPassword { get; set; }
}

/// <summary>Langue de l'interface.</summary>
public sealed class UpdateLanguageRequest
{
    /// <summary><c>fr</c> ou <c>ar</c>.</summary>
    /// <example>ar</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(2, ErrorMessage = "La langue doit être « fr » ou « ar ».")]
    public string? Language { get; set; }
}
