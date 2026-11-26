import 'package:chantier_mobile/core/api/api_clients.dart';
import 'package:url_launcher/url_launcher.dart';

/// Numero d'un fournisseur, lu **en ligne seulement** (`GET /suppliers/{id}`, permission
/// `SupplierPhone.View`). Le numero n'est **jamais** ecrit sur le telephone : ni base, ni cache,
/// ni journal (ADR 0012, CA-MAT-009.4) ; il vit le temps de l'affichage et de l'appel.
abstract interface class SupplierContactSource {
  /// Numero du fournisseur, ou `null` s'il n'en a pas (ou si le role n'a pas le droit : la cle est
  /// alors absente de la reponse). Leve une `ApiException` typee (reseau, session...).
  Future<String?> phoneOf(String supplierId);
}

class SupplierContactRemote implements SupplierContactSource {
  SupplierContactRemote(this._clients);

  final ApiClients _clients;

  @override
  Future<String?> phoneOf(String supplierId) async {
    final supplier = await ApiClients.guard(
      () => _clients.suppliers.suppliersGet(supplierId: supplierId),
    );
    final phone = supplier.phone?.trim();
    return phone == null || phone.isEmpty ? null : phone;
  }
}

/// Lance l'application Telephone sur un numero (`tel:`). Interface pour que les tests n'ouvrent
/// jamais le telephone.
abstract interface class PhoneDialer {
  /// `false` si aucune application ne sait composer un numero.
  Future<bool> dial(String phone);
}

/// Composeur par `url_launcher` : ouvre le composeur du telephone (`ACTION_DIAL`), sans la
/// permission `CALL_PHONE` : l'utilisateur confirme l'appel lui-meme.
class UrlLauncherDialer implements PhoneDialer {
  @override
  Future<bool> dial(String phone) {
    final number = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return launchUrl(Uri(scheme: 'tel', path: number));
  }
}
