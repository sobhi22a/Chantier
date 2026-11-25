using System.Globalization;

namespace Chantier.Core.Entities.Common;

/// <summary>
/// Base de toutes les entites metier (ADR 0003) : identifiant GUID v7 genere par le code (jamais par la base),
/// audit (qui, quand), suppression logique et jeton de version.
/// Les champs d'audit sont poses <b>uniquement</b> par l'intercepteur d'audit a partir du jeton de l'utilisateur
/// et de l'horloge du serveur : le client ne les fournit jamais (CT-6).
/// </summary>
public abstract class BasicEntity
{
    public Guid Id { get; protected set; } = Guid.CreateVersion7();

    public DateTimeOffset CreatedAt { get; private set; }

    public Guid CreatedBy { get; private set; }

    public DateTimeOffset? UpdatedAt { get; private set; }

    public Guid? UpdatedBy { get; private set; }

    public DateTimeOffset? DeletedAt { get; private set; }

    public Guid? DeletedBy { get; private set; }

    /// <summary>Jeton de concurrence et curseur de synchronisation (<c>rowversion</c> SQL Server, lu en entier non signe).</summary>
    public ulong RowVersion { get; private set; }

    public bool IsDeleted => DeletedAt is not null;

    /// <summary>Valeur exposee par l'API (<c>version</c>) : l'entier en decimal, sous forme de chaine.</summary>
    public string Version => RowVersion.ToString(CultureInfo.InvariantCulture);

    /// <summary>Reserve a l'intercepteur d'audit.</summary>
    public void MarkCreated(Guid by, DateTimeOffset at)
    {
        CreatedBy = by;
        CreatedAt = at;
    }

    /// <summary>Reserve a l'intercepteur d'audit.</summary>
    public void MarkUpdated(Guid by, DateTimeOffset at)
    {
        UpdatedBy = by;
        UpdatedAt = at;
    }

    /// <summary>Reserve a l'intercepteur d'audit : suppression logique (rien n'est supprime physiquement).</summary>
    public void MarkDeleted(Guid by, DateTimeOffset at)
    {
        DeletedBy = by;
        DeletedAt = at;
        UpdatedBy = by;
        UpdatedAt = at;
    }

    /// <summary>Lit la version envoyee par un client ; <c>false</c> si elle n'est pas un entier positif.</summary>
    public static bool TryParseVersion(string? value, out ulong version)
        => ulong.TryParse(value, NumberStyles.None, CultureInfo.InvariantCulture, out version);
}
