using System.Globalization;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Chantier.WebApi.Json;

/// <summary>Date metier incomplete ou impossible (« ../08/2026 ») : traduite en 400 <c>DATE_INVALIDE</c>.</summary>
public sealed class InvalidDateJsonException : JsonException
{
    public InvalidDateJsonException() : base("DATE_INVALIDE")
    {
    }
}

/// <summary>
/// <c>DateOnly</c> au format strict <c>yyyy-MM-dd</c> (date complete, sans fuseau). Toute autre forme leve
/// <see cref="InvalidDateJsonException"/>, que la reponse d'erreur du modele convertit en code <c>DATE_INVALIDE</c>.
/// </summary>
public sealed class StrictDateOnlyJsonConverter : JsonConverter<DateOnly>
{
    private const string Format = "yyyy-MM-dd";

    public override DateOnly Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.String
            && DateOnly.TryParseExact(reader.GetString(), Format, CultureInfo.InvariantCulture, DateTimeStyles.None, out var date))
        {
            return date;
        }

        throw new InvalidDateJsonException();
    }

    public override void Write(Utf8JsonWriter writer, DateOnly value, JsonSerializerOptions options)
        => writer.WriteStringValue(value.ToString(Format, CultureInfo.InvariantCulture));
}
