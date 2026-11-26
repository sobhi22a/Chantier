namespace Chantier.Core.Entities.Common;

/// <summary>
/// Identifiant GUID v7 <b>strictement croissant dans le processus</b> : <c>Guid.CreateVersion7()</c> ne garantit pas l'ordre de deux identifiants
/// crees dans la meme milliseconde. Sert aux evenements d'historique, que l'on relit dans l'ordre ou ils ont ete ecrits (plusieurs evenements
/// peuvent partager la meme heure d'audit dans une meme ecriture ; EF insere par ordre d'identifiant).
/// </summary>
public static class MonotonicGuid
{
    private static long _lastMilliseconds;

    public static Guid Next()
    {
        long previous;
        long next;
        do
        {
            previous = Interlocked.Read(ref _lastMilliseconds);
            next = Math.Max(DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(), previous + 1);
        }
        while (Interlocked.CompareExchange(ref _lastMilliseconds, next, previous) != previous);

        return Guid.CreateVersion7(DateTimeOffset.FromUnixTimeMilliseconds(next));
    }
}
