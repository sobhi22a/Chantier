namespace Chantier.Core.Abstractions;

/// <summary>Auteur des ecritures faites hors requete (amorcage, migrations de donnees) : identifiant fixe, jamais un compte reel.</summary>
public static class SystemActor
{
    public static readonly Guid Id = new("00000000-0000-7000-8000-000000000001");
}
