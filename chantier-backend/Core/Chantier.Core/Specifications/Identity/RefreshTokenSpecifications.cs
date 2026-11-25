using Ardalis.Specification;
using Chantier.Core.Entities.Identity;

namespace Chantier.Core.Specifications.Identity;

/// <summary>Un jeton de rafraichissement a partir de l'empreinte du jeton brut, quel que soit son etat.</summary>
public sealed class RefreshTokenByHashSpecification : Specification<RefreshToken>, ISingleResultSpecification<RefreshToken>
{
    public RefreshTokenByHashSpecification(string tokenHash)
    {
        Query.Where(token => token.TokenHash == tokenHash);
    }
}
