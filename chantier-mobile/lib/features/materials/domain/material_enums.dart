// Valeurs stables du contrat `docs/api/demandes-materiaux-livraisons.md` (chaines en anglais,
// jamais d'entier). Les tables gardent le **texte recu** : une valeur ajoutee par le serveur apres
// cette version ne doit pas faire echouer la lecture ; ces enumerations servent aux regles locales
// et `tryParse` rend `null` pour une valeur inconnue (affichee alors telle que recue).

/// Statut d'une demande de materiaux. Calcule et change par le serveur seulement : le telephone
/// n'affiche qu'un statut **provisoire**, marque « a confirmer » (ADR 0014).
enum RequestStatus {
  requested('Requested'),
  validated('Validated'),
  rejected('Rejected'),
  ordered('Ordered'),
  partiallyDelivered('PartiallyDelivered'),
  delivered('Delivered'),
  received('Received'),
  cancelled('Cancelled');

  const RequestStatus(this.code);

  final String code;

  static RequestStatus? tryParse(String? code) {
    for (final status in values) {
      if (status.code == code) return status;
    }
    return null;
  }

  /// Statuts de la vue « A suivre » (CA-MAT-002.1).
  static const Set<RequestStatus> toFollow = {
    requested,
    validated,
    ordered,
    partiallyDelivered,
    delivered,
  };

  /// Statuts de la vue « Refusees et annulees ».
  static const Set<RequestStatus> closed = {rejected, cancelled};

  /// Une demande de ces statuts peut etre en retard : « pour le » depasse et pas encore livree
  /// (CA-MAT-002.4).
  bool get canBeOverdue =>
      this == requested ||
      this == validated ||
      this == ordered ||
      this == partiallyDelivered;
}

/// Urgence d'une demande (defaut `normal`). [rank] : plus petit = plus urgent (tri de « A suivre »).
enum RequestPriority {
  blocking('Blocking', 0),
  urgent('Urgent', 1),
  normal('Normal', 2);

  const RequestPriority(this.code, this.rank);

  final String code;
  final int rank;

  static RequestPriority? tryParse(String? code) {
    for (final priority in values) {
      if (priority.code == code) return priority;
    }
    return null;
  }
}

/// Etat d'une livraison : une livraison annulee reste visible mais n'entre dans aucun total.
enum DeliveryStatus {
  recorded('Recorded'),
  cancelled('Cancelled');

  const DeliveryStatus(this.code);

  final String code;

  static DeliveryStatus? tryParse(String? code) {
    for (final status in values) {
      if (status.code == code) return status;
    }
    return null;
  }
}

/// Conformite a la reception ; `withReserve` exige un motif de reserve.
enum Conformity {
  conform('Conform'),
  withReserve('WithReserve');

  const Conformity(this.code);

  final String code;

  static Conformity? tryParse(String? code) {
    for (final value in values) {
      if (value.code == code) return value;
    }
    return null;
  }
}

/// Etat d'envoi du binaire d'une photo (`contentStatus`).
abstract final class PhotoContentStatus {
  static const String pending = 'Pending';
  static const String uploaded = 'Uploaded';
}
