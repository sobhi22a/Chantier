namespace Chantier.Infrastructure.SeedData.Demo;

/// <summary>
/// Image fictive d'un bon de livraison (JPEG de 160 x 100 pixels, mention « BL fictif DEMO », 2 Ko), liee a LIV-006 par la demonstration (US-MAT-016).
/// Aucune donnee reelle : un rectangle et deux mots. En base64 pour ne dependre d'aucun fichier a copier.
/// </summary>
internal static class DemoDeliveryNoteImage
{
    public static byte[] Bytes() => Convert.FromBase64String(Base64);

    private const string Base64 = """
        /9j/4AAQSkZJRgABAQEAYABgAAD/2wBDABQODxIPDRQSERIXFhQYHzMhHxwcHz8tLyUzSkFOTUlBSEZSXHZkUldvWEZIZoxob3p9
        hIWET2ORm4+AmnaBhH//2wBDARYXFx8bHzwhITx/VEhUf39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/
        f39/f39/f3//wAARCABkAKADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUF
        BAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVW
        V1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi
        4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAEC
        AxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVm
        Z2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq
        8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDobi4uvtwtrYQ/6rzCZM+uO1H/ABNP+nP/AMeo/wCY5/27f+zVZnuIbZN9xNHEhON0jBRn
        8aAK3/E0/wCnP/x6j/iaf9Of/j1WIru2mhaaK4ieJM7nVwVGPU1KCCAQcg96AKX/ABNP+nP/AMeo/wCJp/05/wDj1WpriGDb50sc
        e87V3sBk+gzTkdJEDxsrowyGU5BoAp/8TT/pz/8AHqP+Jp/05/8Aj1XHdI1LOyqqgkknAA9aY1xAkkcbTRh5PuKWGW+g70AVv+Jp
        /wBOf/j1H/E0/wCnP/x6r1FAFH/iaf8ATn/49R/xNP8Apz/8eq9RQBR/4mn/AE5/+PUf8TT/AKc//HqvUUAUf+Jp/wBOf/j1H/E0
        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
        RRQB/9k=
        """;
}
