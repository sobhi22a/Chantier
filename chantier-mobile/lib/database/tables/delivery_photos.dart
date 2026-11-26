import 'package:chantier_mobile/database/tables/sites.dart';
import 'package:drift/drift.dart';

/// Metadonnees des photos de bons de livraison (entite `photo`, ADR 0013). **Jamais les octets** :
/// l'image se charge a la demande, en ligne, et n'est pas gardee en base. Un role sans
/// `DeliveryPhotos.View` ne recoit aucune ligne.
///
/// Une photo prise hors ligne a d'abord ici `isPending = true`, `version = 0`, `id = clientId` ;
/// son fichier est dans `pending_photo_files` jusqu'a la confirmation de l'envoi.
@DataClassName('DeliveryPhotoRow')
@TableIndex(name: 'idx_delivery_photos_delivery', columns: {#deliveryId})
class DeliveryPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get siteId =>
      text().references(Sites, #id, onDelete: KeyAction.cascade)();

  /// Livraison portee (identifiant serveur, ou `clientId` d'une livraison encore en attente).
  TextColumn get deliveryId => text()();
  TextColumn get clientId => text().nullable()();
  DateTimeColumn get takenAt => dateTime()();
  TextColumn get contentType =>
      text().withDefault(const Constant('image/jpeg'))();
  IntColumn get sizeBytes => integer().nullable()();

  /// `Pending` (binaire pas encore recu par le serveur) ou `Uploaded`.
  TextColumn get contentStatus =>
      text().withDefault(const Constant('Pending'))();
  IntColumn get version => integer()();
  BoolColumn get isPending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {siteId, clientId},
  ];
}
