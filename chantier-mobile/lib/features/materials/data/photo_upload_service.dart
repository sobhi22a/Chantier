import 'dart:io';

import 'package:chantier_mobile/core/api/generated/export.dart'
    show PhotoResponse;
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/utils/sha256.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/delivery_photos_dao.dart';
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/data/photo_remote.dart';
import 'package:chantier_mobile/features/sites/data/sync_decoder.dart';
import 'package:logging/logging.dart';

/// Envoi des **fichiers** des photos de bons (ADR 0013), apres le push des metadonnees.
///
/// * **un fichier a la fois**, dans l'ordre de prise, par petits lots ; jamais en parallele ;
/// * seuls les fichiers dont les metadonnees sont deja confirmees par le serveur partent (le
///   resultat `applied` de `photo` / `create` donne l'identifiant de la photo) ;
/// * reprise apres coupure ou application tuee : le fichier est **toujours** la tant que le
///   serveur n'a pas confirme ; le renvoi complet est sans effet (200, meme empreinte) ;
/// * avant l'envoi, l'empreinte SHA-256 du fichier est recalculee et comparee a celle declaree ;
/// * le fichier est supprime **apres** la confirmation du serveur seulement ;
/// * panne reseau, serveur ou session : l'erreur remonte au moteur (delai exponentiel) ; refus
///   definitif d'un fichier (taille, type, empreinte, photo introuvable) : le fichier est garde,
///   signale dans « Envois en attente », et n'empeche pas les autres de partir.
class PhotoUploadService {
  PhotoUploadService({
    required AppDatabase database,
    required PhotoRemote remote,
    required PhotoFiles files,
    DateTime Function()? now,
    this.batchSize = 20,
  }) : _db = database,
       _remote = remote,
       _files = files,
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final PhotoRemote _remote;
  final PhotoFiles _files;
  final DateTime Function() _now;

  /// Rejeux immediats apres un `409 CONFLIT_VERSION` du `PUT` (R2-04).
  static const int retriesOnConflict = 2;

  /// Fichiers lus par requete : l'envoi se fait par petits lots, un fichier a la fois.
  final int batchSize;

  static final Logger _log = Logger('PhotoUpload');

  /// Envoie les fichiers prets de [ownerUserId] ; retourne le nombre de fichiers confirmes.
  /// Leve une `ApiException` des qu'un envoi echoue pour une raison **passagere** (reseau,
  /// delai, serveur, session) : les fichiers restants repartiront a la prochaine synchronisation.
  Future<int> uploadPending(String ownerUserId) async {
    await _removeOrphans(ownerUserId);
    var uploaded = 0;
    while (true) {
      final ready = await _db.deliveryPhotosDao.readyFilesFor(
        ownerUserId,
        limit: batchSize,
      );
      if (ready.isEmpty) return uploaded;
      for (final item in ready) {
        if (await _uploadOne(ownerUserId, item.file, item.photo)) uploaded++;
      }
    }
  }

  Future<bool> _uploadOne(
    String ownerUserId,
    PendingPhotoFileRow pending,
    DeliveryPhotoRow photo,
  ) async {
    final file = await _files.fileFor(ownerUserId, pending.relativePath);
    if (!await file.exists()) {
      await _fail(pending, 'INTROUVABLE');
      return false;
    }
    if (await Sha256.hexOfFile(file) != pending.sha256) {
      // Fichier altere depuis la prise : le serveur le refuserait (empreinte differente).
      await _fail(pending, 'TYPE_FICHIER_REFUSE');
      return false;
    }

    try {
      final response = await _uploadWithRetry(pending, photo, file);
      // Ligne construite champ par champ : le fichier est bien arrive (le serveur dit `Uploaded`).
      final confirmed = DeliveryPhotoRow(
        id: response.id,
        siteId: response.siteId,
        deliveryId: response.deliveryId,
        clientId: response.clientId ?? photo.clientId,
        takenAt: response.takenAt.toUtc(),
        contentType: response.contentType,
        sizeBytes: response.sizeBytes,
        contentStatus: response.contentStatus.json ?? 'Uploaded',
        version: _versionOf(response.version),
        isPending: false,
      );
      await _db.transaction(() async {
        await _db.deliveryPhotosDao.upsertIfNewer(confirmed, overwrite: true);
        await _db.deliveryPhotosDao.deleteFile(pending.clientId);
      });
      // Apres la ligne : une interruption laisse un fichier orphelin (nettoye plus tard), jamais
      // une ligne qui designe un fichier disparu.
      await _files.delete(ownerUserId, pending.relativePath);
      return true;
    } on ApiException catch (error) {
      final permanent = _permanentCode(error);
      if (permanent == null) {
        await _db.deliveryPhotosDao.markFileAttempt(
          pending.clientId,
          errorCode: error.code,
        );
        rethrow;
      }
      _log.warning('Photo refusee par le serveur ($permanent).');
      await _fail(pending, permanent);
      return false;
    }
  }

  /// Un `PUT` identique envoye pendant que le premier est encore en cours peut recevoir `409
  /// CONFLIT_VERSION` alors que la photo est bien arrivee (R2-04) : ce n'est ni un refus ni une
  /// perte, c'est « a relire puis reessayer ». Le meme envoi est donc rejoue, deux fois au plus,
  /// avant de laisser le moteur reprendre plus tard (delai exponentiel). Le renvoi complet est
  /// sans effet cote serveur (200, meme empreinte).
  Future<PhotoResponse> _uploadWithRetry(
    PendingPhotoFileRow pending,
    DeliveryPhotoRow photo,
    File file,
  ) async {
    for (var attempt = 0; ; attempt++) {
      try {
        return await _remote.upload(
          siteId: pending.siteId,
          photoId: photo.id,
          file: file,
        );
      } on ConflictApiException catch (error) {
        if (error.code != 'CONFLIT_VERSION' || attempt >= retriesOnConflict) {
          rethrow;
        }
      }
    }
  }

  Future<void> _fail(PendingPhotoFileRow pending, String code) =>
      _db.deliveryPhotosDao.markFileAttempt(pending.clientId, errorCode: code);

  /// Code definitif (de `PhotoFileErrors.permanent`) d'un refus du serveur, ou `null` si l'echec
  /// est passager : reseau, delai, serveur, trop de requetes, session.
  static String? _permanentCode(ApiException error) {
    final code = error.code;
    return switch (error.status) {
      400 => 'VALIDATION',
      404 => 'INTROUVABLE',
      // `CONFLIT_VERSION` n'est jamais definitif : « a relire puis reessayer » (R2-04).
      409 when code == 'CONFLIT_VERSION' => null,
      409 => 'PHOTO_DEJA_ENVOYEE',
      413 => 'FICHIER_TROP_GROS',
      415 => 'TYPE_FICHIER_REFUSE',
      422 => PhotoFileErrors.isPermanent(code) ? code : 'TYPE_FICHIER_REFUSE',
      _ => null,
    };
  }

  static int _versionOf(String version) {
    final parsed = int.tryParse(version);
    if (parsed == null) throw const SyncDecodeException('photo');
    return parsed;
  }

  Future<void> _removeOrphans(String ownerUserId) async {
    final known = await _db.deliveryPhotosDao.knownRelativePaths(ownerUserId);
    final removed = await _files.removeOrphans(ownerUserId, known, now: _now());
    if (removed > 0) _log.info('$removed fichier(s) de photo orphelin(s).');
  }
}
