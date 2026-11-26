namespace Chantier.Core.Sync;

/// <summary>Resultat d'une comparaison a trois valeurs (ADR 0011) : champs inchanges, a appliquer, en desaccord.</summary>
/// <param name="AlreadyApplied">Valeur actuelle = valeur proposee : rien a faire (un renvoi ou une saisie identique d'un autre telephone).</param>
/// <param name="ToApply">Valeur actuelle = valeur de depart du telephone : la modification s'applique.</param>
/// <param name="Conflicts">Quelqu'un d'autre a deja change le champ vers une autre valeur : conflit.</param>
public sealed record FieldMergeResult(IReadOnlyList<string> AlreadyApplied, IReadOnlyList<string> ToApply, IReadOnlyList<string> Conflicts)
{
    public bool HasConflict => Conflicts.Count > 0;
}

/// <summary>
/// Comparaison <b>a trois valeurs par champ</b> d'une modification faite hors ligne (ADR 0011) : valeur de depart (vue par le telephone), valeur actuelle
/// (serveur) et valeur proposee. Champs differents : les deux modifications s'appliquent ; meme champ change des deux cotes : <b>la premiere arrivee est retenue</b>,
/// l'autre est un conflit. Tout ou rien : un seul champ en conflit refuse toute l'operation. Pure : les valeurs sont des formes canoniques (chaines).
/// Reutilisee par les modifications de demandes puis de livraisons.
/// </summary>
public static class FieldMergeEvaluator
{
    public static FieldMergeResult Evaluate(
        IReadOnlyDictionary<string, string?> current,
        IReadOnlyDictionary<string, string?> baseValues,
        IReadOnlyDictionary<string, string?> proposed)
    {
        var alreadyApplied = new List<string>();
        var toApply = new List<string>();
        var conflicts = new List<string>();

        foreach (var (field, wanted) in proposed)
        {
            current.TryGetValue(field, out var actual);
            baseValues.TryGetValue(field, out var start);

            if (string.Equals(actual, wanted, StringComparison.Ordinal))
            {
                alreadyApplied.Add(field);
            }
            else if (string.Equals(actual, start, StringComparison.Ordinal))
            {
                toApply.Add(field);
            }
            else
            {
                conflicts.Add(field);
            }
        }

        return new FieldMergeResult(alreadyApplied, toApply, conflicts);
    }
}
