using System.Buffers.Binary;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Chantier.Infrastructure.Persistence;

/// <summary>
/// <c>rowversion</c> SQL Server (8 octets) lu en <see cref="ulong"/> <b>gros-boutiste</b>.
/// Le <c>NumberToBytesConverter</c> d'EF est petit-boutiste : les comparaisons binaires de SQL Server
/// (« RowVersion &gt; @since ») ne suivraient plus l'ordre numerique et le curseur de synchronisation serait faux (ADR 0003).
/// Ce point est verifie par un test d'integration sur une vraie base (voir RowVersionTests).
/// </summary>
public sealed class RowVersionConverter()
    : ValueConverter<ulong, byte[]>(value => ToBytes(value), bytes => ToNumber(bytes))
{
    public static byte[] ToBytes(ulong value)
    {
        var bytes = new byte[8];
        BinaryPrimitives.WriteUInt64BigEndian(bytes, value);
        return bytes;
    }

    public static ulong ToNumber(byte[] bytes)
        => bytes is { Length: 8 } ? BinaryPrimitives.ReadUInt64BigEndian(bytes) : 0UL;
}
