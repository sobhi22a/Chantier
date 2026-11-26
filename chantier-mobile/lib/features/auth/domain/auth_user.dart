import 'package:equatable/equatable.dart';

/// Permissions du serveur (catalogue `PermissionResources` du backend). L'interface n'affiche
/// que ce que le serveur autorise ; le serveur refuse de toute facon (CA-003).
abstract final class Permissions {
  static const String zonesCreate = 'Zones.Create';
  static const String contractAmountView = 'ContractAmount.View';

  // Demandes de materiaux (ADR 0012) : le serveur refuse de toute facon, l'interface masque.
  static const String requestsView = 'Requests.View';
  static const String requestsCreate = 'Requests.Create';
  static const String requestsUpdate = 'Requests.Update';
  static const String requestsUpdateAny = 'Requests.UpdateAny';
  static const String requestsApprove = 'Requests.Approve';
  static const String requestsCancel = 'Requests.Cancel';
  static const String requestsCancelAny = 'Requests.CancelAny';
  static const String requestsReceive = 'Requests.Receive';

  // Livraisons, photos des bons et contact fournisseur (ADR 0012, 0013).
  static const String deliveriesView = 'Deliveries.View';
  static const String deliveriesCreate = 'Deliveries.Create';
  static const String deliveriesUpdate = 'Deliveries.Update';
  static const String deliveriesAttach = 'Deliveries.Attach';
  static const String deliveryPhotosCreate = 'DeliveryPhotos.Create';
  static const String deliveryPhotosView = 'DeliveryPhotos.View';
  static const String supplierPhoneView = 'SupplierPhone.View';
}

/// Utilisateur connecte, tel que memorise sur le telephone pour la session hors ligne.
///
/// Ne contient **jamais** de telephone ni de jeton : le telephone n'est renvoye qu'a son
/// titulaire par `GET /auth/me` et n'est pas conserve (CA-017.4).
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.role,
    required this.language,
    required this.mustChangePassword,
    required this.permissions,
    required this.permissionsVersion,
  });

  factory AuthUser.fromJson(Map<String, Object?> json) => AuthUser(
    id: json['id']! as String,
    userName: json['userName']! as String,
    fullName: json['fullName']! as String,
    role: json['role']! as String,
    language: json['language']! as String,
    mustChangePassword: json['mustChangePassword']! as bool,
    permissions: List<String>.from(json['permissions']! as List),
    permissionsVersion: json['permissionsVersion']! as String,
  );

  final String id;
  final String userName;
  final String fullName;

  /// Nom stable du role (`ChefChantier`...) ; traduit par l'interface.
  final String role;

  /// `fr` ou `ar` : langue du compte.
  final String language;
  final bool mustChangePassword;
  final List<String> permissions;
  final String permissionsVersion;

  bool can(String permission) => permissions.contains(permission);

  AuthUser copyWith({bool? mustChangePassword}) => AuthUser(
    id: id,
    userName: userName,
    fullName: fullName,
    role: role,
    language: language,
    mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    permissions: permissions,
    permissionsVersion: permissionsVersion,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'userName': userName,
    'fullName': fullName,
    'role': role,
    'language': language,
    'mustChangePassword': mustChangePassword,
    'permissions': permissions,
    'permissionsVersion': permissionsVersion,
  };

  @override
  List<Object?> get props => [
    id,
    userName,
    fullName,
    role,
    language,
    mustChangePassword,
    permissions,
    permissionsVersion,
  ];

  /// Journaux : identifiant technique seulement, jamais le nom (CT-14).
  @override
  String toString() => 'AuthUser($id)';
}

/// Pourquoi l'utilisateur doit se (re)connecter.
enum SessionEnd {
  /// Jetons refuses ou session hors ligne trop ancienne (> 14 jours) : saisies conservees.
  expired,

  /// Compte desactive (`ACCES_RETIRE`) : donnees chantier effacees.
  accessRevoked,
}

/// Resultat de la restauration de session au demarrage.
class RestoredSession extends Equatable {
  const RestoredSession.signedIn(AuthUser this.user) : ended = null;

  const RestoredSession.signedOut([this.ended]) : user = null;

  final AuthUser? user;
  final SessionEnd? ended;

  @override
  List<Object?> get props => [user, ended];
}
