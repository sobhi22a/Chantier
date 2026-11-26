import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';

/// Dates metier d'Algerie pour l'affichage des demandes : « aujourd'hui », retard, date de besoin
/// par defaut. Fuseau fixe UTC+1 sans heure d'ete ([Formatters.algiersOffset]).
///
/// Les dates metier sont des `DateTime` UTC a minuit (comme `DateOnlyTextConverter`) : seuls
/// annee, mois et jour comptent. L'heure du telephone ne sert qu'a **choisir le jour affiche** ;
/// le serveur reste seul juge (livraison « dans le futur », retard enregistre).
abstract final class AlgeriaDate {
  /// Jour calendaire en Algerie a l'instant [now].
  static DateTime today(DateTime now) {
    final local = now.toUtc().add(Formatters.algiersOffset);
    return DateTime.utc(local.year, local.month, local.day);
  }

  /// Date de besoin par defaut : [today] + [days] jours (3 par defaut cote serveur, parametre
  /// `defaultNeededByDays`). 30/12/2026 + 3 = 02/01/2027 ; 28/02/2028 + 3 = 02/03/2028.
  static DateTime defaultNeededBy(DateTime today, int days) =>
      DateTime.utc(today.year, today.month, today.day + days);

  /// Jours de retard : `max(0, today - due)` en jours calendaires. Une echeance du jour n'est pas
  /// en retard.
  static int overdueDays(DateTime due, DateTime today) {
    final dueDay = DateTime.utc(due.year, due.month, due.day);
    final todayDay = DateTime.utc(today.year, today.month, today.day);
    final days = todayDay.difference(dueDay).inDays;
    return days > 0 ? days : 0;
  }

  /// Retard d'une demande : seulement pour un statut encore ouvert (`Requested`, `Validated`,
  /// `Ordered`, `PartiallyDelivered`) ; 0 sinon (CA-MAT-002.4). Un statut inconnu (`null`) n'est
  /// jamais en retard.
  static int requestOverdueDays({
    required RequestStatus? status,
    required DateTime neededBy,
    required DateTime today,
  }) =>
      status != null && status.canBeOverdue ? overdueDays(neededBy, today) : 0;
}
