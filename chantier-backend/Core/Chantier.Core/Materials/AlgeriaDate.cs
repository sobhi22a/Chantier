namespace Chantier.Core.Materials;

/// <summary>
/// Dates « du jour » en heure d'Algerie (UTC+1, pas d'heure d'ete) : retards, date de livraison « pas dans le futur », date de besoin par defaut
/// (H-MAT-12, H-MAT-22, H-ARCH-14). Le serveur decide : la date du telephone ne fait pas foi.
/// </summary>
public static class AlgeriaDate
{
    private static readonly TimeZoneInfo Zone = Resolve();

    public static DateOnly Today(TimeProvider time)
        => DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(time.GetUtcNow(), Zone).DateTime);

    /// <summary>Date de besoin proposee : aujourd'hui + <paramref name="days"/> jours calendaires (defaut 3, H-MAT-05).</summary>
    public static DateOnly DefaultNeededBy(DateOnly today, int days) => today.AddDays(days);

    private static TimeZoneInfo Resolve()
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById("Africa/Algiers");
        }
        catch (TimeZoneNotFoundException)
        {
            // Image sans base de fuseaux : l'Algerie n'a plus d'heure d'ete, un decalage fixe est exact.
            return TimeZoneInfo.CreateCustomTimeZone("Africa/Algiers", TimeSpan.FromHours(1), "Algérie", "Algérie");
        }
    }
}

/// <summary>Retard en jours calendaires : <c>max(0, aujourd'hui - echeance)</c>.</summary>
public static class OverdueCalculator
{
    public static int Days(DateOnly due, DateOnly today) => Math.Max(0, today.DayNumber - due.DayNumber);
}
