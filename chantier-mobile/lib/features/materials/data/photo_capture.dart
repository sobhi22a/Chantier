import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Prise de vue du bon de livraison. Interface pour que les tests n'ouvrent jamais l'appareil
/// photo ; la production utilise `image_picker` (ADR 0013).
abstract interface class PhotoCapture {
  /// Ouvre l'appareil photo ; `null` si l'utilisateur annule. Leve une exception de plateforme si
  /// aucun appareil photo n'est disponible.
  Future<File?> takePhoto();
}

/// Appareil photo par `image_picker`, en un geste, **sans demande de permission** : l'application
/// ne declare pas la permission camera, la prise passe par l'application photo du telephone (rien
/// n'est lu dans la galerie, aucun stockage large). Reduction a la source : 1 920 px et JPEG de
/// qualite 80 pour viser 1 a 2 Mo sur 3G (CA-MAT-007.5).
class ImagePickerCapture implements PhotoCapture {
  ImagePickerCapture([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  static const double maxDimension = 1920;
  static const int jpegQuality = 80;

  final ImagePicker _picker;

  @override
  Future<File?> takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
      imageQuality: jpegQuality,
      requestFullMetadata: false,
    );
    return picked == null ? null : File(picked.path);
  }
}
