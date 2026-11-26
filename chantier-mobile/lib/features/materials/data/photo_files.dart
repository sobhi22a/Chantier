import 'dart:io';

import 'package:chantier_mobile/core/utils/sha256.dart';
import 'package:equatable/equatable.dart';

/// Pourquoi un fichier de photo est refuse a la prise (CA-MAT-007.5).
enum PhotoFileProblem {
  /// Pas une image JPEG (octets magiques `FF D8 FF`).
  notAnImage,

  /// Plus lourd que `maxPhotoBytes` du serveur apres reduction.
  tooLarge,

  /// Fichier illisible ou disparu.
  unreadable,
}

class PhotoFileException implements Exception {
  const PhotoFileException(this.problem);

  final PhotoFileProblem problem;

  @override
  String toString() => 'PhotoFileException(${problem.name})';
}

/// Photo prise et rangee dans le dossier prive de l'application, **pas encore enregistree** avec
/// sa livraison : si le formulaire est abandonne, le fichier est supprime.
class CapturedPhoto extends Equatable {
  const CapturedPhoto({
    required this.clientId,
    required this.relativePath,
    required this.file,
    required this.sizeBytes,
    required this.sha256,
    required this.takenAt,
  });

  /// `clientId` de la photo, cree a la prise (anti-doublon, pas a l'envoi).
  final String clientId;

  /// Chemin relatif au dossier prive du proprietaire (`pending_photos/<clientId>.jpg`).
  final String relativePath;
  final File file;
  final int sizeBytes;
  final String sha256;
  final DateTime takenAt;

  @override
  List<Object?> get props => [
    clientId,
    relativePath,
    sizeBytes,
    sha256,
    takenAt,
  ];
}

/// Fichiers des photos en attente d'envoi (ADR 0013).
///
/// Rangement : `<dossier prive de l'application>/<ownerUserId>/pending_photos/<clientId>.jpg`. Le
/// dossier prive est exclu de la sauvegarde Android (`backup_rules.xml`) ; les fichiers d'un compte
/// ne sont ni vus ni envoyes par un autre compte du meme telephone. Un fichier n'est supprime
/// qu'apres la confirmation du serveur, ou sur decision de l'utilisateur.
class PhotoFiles {
  PhotoFiles({required Future<Directory> Function() rootProvider})
    : _rootProvider = rootProvider;

  final Future<Directory> Function() _rootProvider;

  /// Dossier des photos en attente du proprietaire (cree au besoin).
  Future<Directory> ownerDirectory(String ownerUserId) async {
    final root = await _rootProvider();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}$ownerUserId'
      '${Platform.pathSeparator}pending_photos',
    );
    return directory.create(recursive: true);
  }

  Future<File> fileFor(String ownerUserId, String relativePath) async {
    final root = await _rootProvider();
    return File(
      '${root.path}${Platform.pathSeparator}$ownerUserId'
      '${Platform.pathSeparator}$relativePath',
    );
  }

  /// Range la photo prise ([source], dossier temporaire de l'appareil photo) dans le dossier prive :
  /// controle JPEG et taille, copie, empreinte SHA-256 (dans un isolat), puis supprime la source.
  ///
  /// Leve [PhotoFileException] : le fichier n'est alors **pas** garde.
  Future<CapturedPhoto> importCaptured({
    required File source,
    required String ownerUserId,
    required String clientId,
    required DateTime takenAt,
    required int maxBytes,
  }) async {
    final int length;
    try {
      length = await source.length();
      if (!await _isJpeg(source)) {
        throw const PhotoFileException(PhotoFileProblem.notAnImage);
      }
    } on FileSystemException {
      throw const PhotoFileException(PhotoFileProblem.unreadable);
    }
    if (length > maxBytes) {
      throw const PhotoFileException(PhotoFileProblem.tooLarge);
    }

    final directory = await ownerDirectory(ownerUserId);
    final relativePath = 'pending_photos/$clientId.jpg';
    final target = File(
      '${directory.path}${Platform.pathSeparator}$clientId.jpg',
    );
    try {
      await source.copy(target.path);
      final digest = await Sha256.hexOfFile(target);
      await _deleteQuietly(source);
      return CapturedPhoto(
        clientId: clientId,
        relativePath: relativePath,
        file: target,
        sizeBytes: length,
        sha256: digest,
        takenAt: takenAt,
      );
    } on FileSystemException {
      await _deleteQuietly(target);
      throw const PhotoFileException(PhotoFileProblem.unreadable);
    }
  }

  /// Supprime un fichier du dossier prive (apres confirmation du serveur ou abandon).
  Future<void> delete(String ownerUserId, String relativePath) async =>
      _deleteQuietly(await fileFor(ownerUserId, relativePath));

  /// Supprime les fichiers du dossier du proprietaire que **aucune ligne** ne reference
  /// ([knownRelativePaths]) et plus anciens que [grace] : photo prise dans un formulaire jamais
  /// enregistre, fichier d'une saisie abandonnee, envoi confirme dont la suppression a ete
  /// interrompue. Retourne le nombre de fichiers supprimes.
  Future<int> removeOrphans(
    String ownerUserId,
    Set<String> knownRelativePaths, {
    required DateTime now,
    Duration grace = const Duration(hours: 24),
  }) async {
    final directory = await ownerDirectory(ownerUserId);
    var removed = 0;
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (knownRelativePaths.contains('pending_photos/$name')) continue;
      final modified = (await entity.lastModified()).toUtc();
      if (now.toUtc().difference(modified) < grace) continue;
      await _deleteQuietly(entity);
      removed++;
    }
    return removed;
  }

  Future<bool> _isJpeg(File file) async {
    final reader = await file.open();
    try {
      final head = await reader.read(3);
      return head.length == 3 &&
          head[0] == 0xFF &&
          head[1] == 0xD8 &&
          head[2] == 0xFF;
    } finally {
      await reader.close();
    }
  }

  static Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Un fichier qui ne se supprime pas sera retente (orphelin) : jamais une erreur a l'ecran.
    }
  }
}
