using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// Noms des verrous applicatifs (<see cref="AppLocks"/>) et ordre dans lequel les prendre. <b>Regle</b> : toutes les ressources d'une action sont verrouillees
/// <b>avant la premiere ecriture</b>, toujours dans l'ordre livraison puis demande ; un verrou ne se prend jamais en attente d'une ligne deja ecrite. Ainsi
/// deux ecritures concurrentes de la meme demande (valider, commander, recevoir, corriger, annuler) se mettent en file au lieu de se bloquer mutuellement (SQL 1205).
/// </summary>
internal static class MaterialLocks
{
    public static string Request(Guid requestId) => $"material-request:{requestId:N}";

    public static string Delivery(Guid deliveryId) => $"material-delivery:{deliveryId:N}";

    public static string Photo(Guid photoId) => $"material-photo:{photoId:N}";

    /// <summary>Nombre d'essais d'une ecriture dont la ligne a ete modifiee entre la lecture et l'ecriture (<c>rowversion</c>) : la ligne est relue.</summary>
    public const int MaxAttempts = 3;

    /// <summary>
    /// Rejoue le corps (relecture complete) si une ligne a ete modifiee par une autre transaction entre sa lecture et son ecriture. L'echec d'un
    /// <c>SaveChanges</c> dans une transaction est annule jusqu'a son point de sauvegarde : rien n'est ecrit a moitie.
    /// </summary>
    public static async Task<T> RetryAsync<T>(ApplicationDbContext db, Func<Task<T>> body)
    {
        for (var attempt = 1; ; attempt++)
        {
            try
            {
                return await body();
            }
            catch (DbUpdateConcurrencyException) when (attempt < MaxAttempts)
            {
                db.ChangeTracker.Clear();
            }
        }
    }
}
