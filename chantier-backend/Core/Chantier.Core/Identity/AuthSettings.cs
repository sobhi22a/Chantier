namespace Chantier.Core.Identity;

/// <summary>Reglages d'authentification (section <c>Auth</c>) : tout est parametrable (H-04, ADR 0005).</summary>
public sealed class AuthSettings
{
    public const string SectionName = "Auth";

    /// <summary>Echecs de connexion toleres par identifiant avant blocage (H-04 : 5).</summary>
    public int MaxFailedAttempts { get; set; } = 5;

    /// <summary>Fenetre de comptage des echecs et duree du blocage, en minutes (H-04 : 15).</summary>
    public int LockoutMinutes { get; set; } = 15;

    /// <summary>Duree de vie du cache de l'etat « actif » d'un compte : un compte desactive est refuse au plus tard apres ce delai (CT-19 : 60 s).</summary>
    public int UserStatusCacheSeconds { get; set; } = 60;

    /// <summary>Duree de vie du cache des permissions d'un role (ADR 0005 : 5 minutes).</summary>
    public int PermissionCacheMinutes { get; set; } = 5;

    /// <summary>Duree d'une session web glissante, en heures (ADR 0005 : 8).</summary>
    public int CookieSessionHours { get; set; } = 8;

    /// <summary>
    /// Fenetre de grace du jeton de rafraichissement, en secondes (R1-05 : 30). Si la reponse d'un renouvellement est perdue (reseau faible), le telephone
    /// renvoie l'ancien jeton : tant qu'il a ete remplace depuis moins de ce delai et que son successeur n'a pas servi, un nouveau successeur est emis
    /// sans brûler la chaine. Au-dela, ou si le successeur a servi, c'est une reutilisation (vol presume).
    /// </summary>
    public int RefreshGraceSeconds { get; set; } = 30;

    /// <summary>Duree maximale absolue d'une session web, en heures, quelle que soit l'activite (R1-02 : 12). L'expiration glissante ne la prolonge pas.</summary>
    public int CookieAbsoluteHours { get; set; } = 12;
}
