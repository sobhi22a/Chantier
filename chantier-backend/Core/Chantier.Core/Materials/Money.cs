namespace Chantier.Core.Materials;

/// <summary>
/// Montants en DZD hors taxes (regle 4, H-MAT-14) : 2 decimales, arrondi au centime « loin de zero ».
/// L'arrondi par defaut de .NET est bancaire : 2,5 x 245,25 = 613,125 donnerait 613,12 au lieu de 613,13 (interdit).
/// </summary>
public static class Money
{
    public const int Decimals = 2;

    /// <summary>Plus grand montant stockable (colonne decimal(18,2)) : au-dela, un refus clair (<c>QUANTITE_INVALIDE</c>) et non une erreur du serveur.</summary>
    public const decimal MaxAmount = 9_999_999_999_999_999.99m;

    /// <summary>Plus grande quantite stockable (colonne decimal(18,3)).</summary>
    public const decimal MaxQuantity = 999_999_999_999_999.999m;

    /// <summary>D-1 : refuse (<c>QUANTITE_INVALIDE</c>, 422) une quantite convertie ou un montant qui ne tiendrait pas dans les colonnes (18,3) et (18,2).</summary>
    public static void EnsureStorable(decimal quantity, decimal? amount)
    {
        if (quantity > MaxQuantity || amount > MaxAmount)
        {
            throw new Chantier.Core.Exceptions.DomainRuleException(
                Chantier.Core.Exceptions.ErrorCodes.QuantiteInvalide,
                "La quantité reçue, convertie dans l'unité de la demande, dépasse la limite : vérifiez la quantité et l'unité.");
        }
    }

    public static decimal Round(decimal amount) => Math.Round(amount, Decimals, MidpointRounding.AwayFromZero);

    /// <summary>Montant = quantite x prix unitaire, arrondi : 300 sacs x 780,00 = 234 000,00.</summary>
    public static decimal Amount(decimal quantity, decimal unitPrice) => Round(quantity * unitPrice);

    /// <summary>Valeur recue = somme des montants <b>arrondis</b> de chaque livraison (3 x 0,5 kg a 245,25 = 367,89).</summary>
    public static decimal ReceivedValue(decimal unitPrice, IEnumerable<decimal> deliveredQuantities)
        => deliveredQuantities.Sum(quantity => Amount(quantity, unitPrice));
}
