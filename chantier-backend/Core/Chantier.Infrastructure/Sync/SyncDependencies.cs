using System.Text.Json;
using Chantier.Core.Sync;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Ressources qu'une operation de push touche ou reference (R3-01) : son propre <c>clientId</c> (une creation porte celui de la ressource) et les identifiants du
/// <c>payload</c> qui designent une demande, une livraison ou une zone, par id serveur ou par <c>clientId</c> de la meme batch. Deux operations qui partagent une cle sont dependantes :
/// si la premiere est a rejouer, la seconde l'est aussi.
/// </summary>
public static class SyncDependencies
{
    private static readonly string[] ReferenceFields =
        ["requestId", "requestClientId", "deliveryId", "deliveryClientId", "zoneId", "zoneClientId"];

    public static HashSet<string> KeysOf(SyncOperation operation)
    {
        var keys = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { operation.ClientId.ToString("D") };

        if (operation.Payload is { ValueKind: JsonValueKind.Object } payload)
        {
            foreach (var property in payload.EnumerateObject())
            {
                if (property.Value.ValueKind == JsonValueKind.String
                    && ReferenceFields.Contains(property.Name, StringComparer.OrdinalIgnoreCase)
                    && Guid.TryParse(property.Value.GetString(), out var id))
                {
                    keys.Add(id.ToString("D"));
                }
            }
        }

        return keys;
    }
}
