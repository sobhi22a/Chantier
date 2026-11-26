namespace Chantier.Core.Materials;

/// <summary>Un total par famille d'unites : <see cref="MassEquivalent"/> est la masse en tonnes d'un total en sacs (400 sacs = 20 T), sinon <c>null</c>.</summary>
public sealed record AggregateLine(Quantity Total, Quantity? MassEquivalent);

/// <summary>
/// Totaux d'un tableau de suivi (regle 1, H-MAT-08) : on n'additionne que des unites convertibles entre elles, dans l'unite par defaut
/// du produit ; le reste forme des lignes separees (24 m3 et 10 T de sable ne s'additionnent jamais).
/// </summary>
public static class QuantityAggregator
{
    public static IReadOnlyList<AggregateLine> Aggregate(IEnumerable<Quantity> items, MeasureUnit defaultUnit, decimal? bagMassKg)
    {
        // Le groupe de l'unite par defaut est toujours le premier ; les autres suivent dans l'ordre d'apparition.
        var totals = new List<Quantity>();

        foreach (var item in items)
        {
            if (UnitConverter.TryConvert(item, defaultUnit, bagMassKg, out var inDefault))
            {
                AddToDefaultGroup(totals, inDefault);
                continue;
            }

            var added = false;
            for (var index = 0; index < totals.Count && !added; index++)
            {
                if (UnitConverter.TryConvert(item, totals[index].Unit, bagMassKg, out var inGroup))
                {
                    totals[index] = new Quantity(totals[index].Value + inGroup.Value, totals[index].Unit);
                    added = true;
                }
            }

            if (!added)
            {
                totals.Add(item);
            }
        }

        return totals.Select(total => new AggregateLine(Quantity.Of(total.Value, total.Unit), MassEquivalent(total, bagMassKg))).ToList();
    }

    private static void AddToDefaultGroup(List<Quantity> totals, Quantity inDefault)
    {
        var index = totals.FindIndex(total => total.Unit == inDefault.Unit);
        if (index >= 0)
        {
            totals[index] = new Quantity(totals[index].Value + inDefault.Value, inDefault.Unit);
        }
        else
        {
            totals.Insert(0, inDefault);
        }
    }

    private static Quantity? MassEquivalent(Quantity total, decimal? bagMassKg)
        => total.Unit == MeasureUnit.Bag && UnitConverter.TryConvert(total, MeasureUnit.Tonne, bagMassKg, out var tonnes)
            ? Quantity.Of(tonnes.Value, MeasureUnit.Tonne)
            : null;
}
