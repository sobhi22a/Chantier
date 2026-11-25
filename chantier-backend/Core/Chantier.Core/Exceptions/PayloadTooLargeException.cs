namespace Chantier.Core.Exceptions;

/// <summary>Lot de synchronisation trop volumineux (plus de 100 operations) : 413 <c>LOT_TROP_GRAND</c>.</summary>
public sealed class PayloadTooLargeException : DomainException
{
    public PayloadTooLargeException() : base(ErrorCodes.LotTropGrand, "Le lot envoyé est trop volumineux.")
    {
    }
}
