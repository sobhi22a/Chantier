import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Reglages des demandes de materiaux lus sur `GET /settings/materials` a chaque synchronisation
/// et gardes en base (`app_settings`) pour le hors ligne : « parametrer plutot que coder en
/// dur ». Les valeurs par defaut ci-dessous sont celles du serveur (hypotheses H-MAT-05, 10, 13,
/// 18) ; elles ne servent qu'avant la premiere synchronisation reussie.
class MaterialSettings extends Equatable {
  const MaterialSettings({
    this.defaultNeededByDays = 3,
    this.deliveryTolerancePercent,
    this.maxPhotosPerDelivery = 5,
    this.maxPhotoBytes = 5242880,
    this.noteMaxLength = 200,
    this.reasons = defaultReasons,
  });

  /// Cle de `app_settings`.
  static const String storageKey = 'materials';

  /// Listes de motifs par cas (cles du contrat). Les codes sont ouverts : un code inconnu est
  /// affiche tel quel.
  static const Map<String, List<String>> defaultReasons = {
    'rejection': [
      'AlreadyOrdered',
      'StockSufficient',
      'QuantityToReview',
      'OverBudget',
      'Other',
    ],
    'requestCancellation': [
      'EntryError',
      'NoLongerNeeded',
      'Duplicate',
      'Other',
    ],
    'orderCancellation': ['SupplierUnavailable', 'PriceRefused', 'Other'],
    'settle': ['SupplierWillNotDeliver', 'QuantitySufficient', 'Other'],
    'deliveryCancellation': [
      'DoubleEntry',
      'QuantityError',
      'RefusedAtReception',
      'Other',
    ],
    'reserve': ['QuantityMissing', 'DamagedProduct', 'WrongProduct', 'Other'],
  };

  /// Date de besoin proposee = aujourd'hui + ce nombre de jours.
  final int defaultNeededByDays;

  /// Tolerance de « livraison complete » en % ; `null` = 0 %. Pas de constante en dur : c'est un
  /// reglage du serveur.
  final Decimal? deliveryTolerancePercent;
  final int maxPhotosPerDelivery;
  final int maxPhotoBytes;
  final int noteMaxLength;
  final Map<String, List<String>> reasons;

  Decimal get toleranceOrZero => deliveryTolerancePercent ?? Decimal.zero;

  /// Lit la reponse du serveur ; une cle absente ou illisible garde sa valeur par defaut (un
  /// champ ajoute cote serveur plus tard est ignore).
  factory MaterialSettings.fromJson(Map<String, Object?> json) {
    int intOf(String key, int fallback) {
      final value = json[key];
      return value is int ? value : fallback;
    }

    Decimal? tolerance;
    final rawTolerance = json['deliveryTolerancePercent'];
    if (rawTolerance is num || rawTolerance is String) {
      tolerance = Decimal.tryParse(rawTolerance.toString());
    }

    final parsedReasons = <String, List<String>>{...defaultReasons};
    final rawReasons = json['reasons'];
    if (rawReasons is Map<String, Object?>) {
      for (final entry in rawReasons.entries) {
        final list = entry.value;
        if (list is List && list.every((e) => e is String)) {
          parsedReasons[entry.key] = List<String>.unmodifiable(list.cast());
        }
      }
    }

    return MaterialSettings(
      defaultNeededByDays: intOf('defaultNeededByDays', 3),
      deliveryTolerancePercent: tolerance,
      maxPhotosPerDelivery: intOf('maxPhotosPerDelivery', 5),
      maxPhotoBytes: intOf('maxPhotoBytes', 5242880),
      noteMaxLength: intOf('noteMaxLength', 200),
      reasons: Map<String, List<String>>.unmodifiable(parsedReasons),
    );
  }

  /// Texte JSON stocke dans `app_settings`.
  String toStorage() => jsonEncode({
    'defaultNeededByDays': defaultNeededByDays,
    'deliveryTolerancePercent': deliveryTolerancePercent?.toString(),
    'maxPhotosPerDelivery': maxPhotosPerDelivery,
    'maxPhotoBytes': maxPhotoBytes,
    'noteMaxLength': noteMaxLength,
    'reasons': reasons,
  });

  /// Relit [toStorage] ; texte absent ou illisible : valeurs par defaut.
  factory MaterialSettings.fromStorage(String? text) {
    if (text == null) return const MaterialSettings();
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, Object?>) return const MaterialSettings();
      return MaterialSettings.fromJson(decoded);
    } on FormatException {
      return const MaterialSettings();
    }
  }

  @override
  List<Object?> get props => [
    defaultNeededByDays,
    deliveryTolerancePercent,
    maxPhotosPerDelivery,
    maxPhotoBytes,
    noteMaxLength,
    reasons,
  ];
}
