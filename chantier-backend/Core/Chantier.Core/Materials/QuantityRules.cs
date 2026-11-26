using Chantier.Core.Exceptions;

namespace Chantier.Core.Materials;

/// <summary>Regles d'une quantite saisie : strictement positive, 3 decimales au plus, nombre entier pour <c>sac</c> et <c>u</c> (H-MAT-07).</summary>
public static class QuantityRules
{
    /// <summary>Borne haute : garde un montant (18,2) calculable sans depassement.</summary>
    public const decimal MaxValue = 1_000_000_000m;

    /// <summary>Code d'erreur de la quantite, ou <c>null</c> si elle est valide.</summary>
    public static string? Check(decimal value, MeasureUnit unit)
    {
        if (value <= 0m || value > MaxValue || Math.Round(value, UnitConverter.Decimals, MidpointRounding.AwayFromZero) != value)
        {
            return ErrorCodes.QuantiteInvalide;
        }

        if (MeasureUnits.IsWholeOnly(unit) && value != decimal.Truncate(value))
        {
            return ErrorCodes.QuantiteEntiereRequise;
        }

        return null;
    }

    /// <summary>Leve <c>QUANTITE_INVALIDE</c> ou <c>QUANTITE_ENTIERE_REQUISE</c> (422).</summary>
    public static void Validate(decimal value, MeasureUnit unit)
    {
        switch (Check(value, unit))
        {
            case ErrorCodes.QuantiteInvalide:
                throw new DomainRuleException(ErrorCodes.QuantiteInvalide, "La quantité doit être supérieure à 0, avec 3 décimales au plus.");
            case ErrorCodes.QuantiteEntiereRequise:
                throw new DomainRuleException(ErrorCodes.QuantiteEntiereRequise, "Nombre entier requis pour cette unité.");
        }
    }
}
