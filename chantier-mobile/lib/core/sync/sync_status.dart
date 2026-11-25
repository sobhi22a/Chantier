import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:equatable/equatable.dart';

/// Phase du moteur de synchronisation.
enum SyncPhase {
  /// Rien en cours.
  idle,

  /// Une execution est en cours (push puis pull).
  syncing,

  /// Pas de reseau, ou serveur injoignable : les saisies restent en file d'envoi.
  offline,

  /// Session a renouveler (jetons refuses) ou mot de passe provisoire a changer :
  /// aucune donnee n'est perdue, la reconnexion relance l'envoi.
  authRequired,

  /// Echec du serveur (5xx, 429, reponse illisible) : reprise avec delai exponentiel.
  failed,
}

/// Etat interne du moteur.
class SyncEngineState extends Equatable {
  const SyncEngineState({
    this.phase = SyncPhase.idle,
    this.itemsReceived = 0,
    this.lastError,
    this.nextRetryAt,
    this.consecutiveFailures = 0,
  });

  final SyncPhase phase;

  /// Lignes recues pendant l'execution en cours (« Preparation de vos chantiers... », CA-012.2).
  final int itemsReceived;
  final ApiException? lastError;

  /// Heure (telephone) de la prochaine reprise automatique apres un echec.
  final DateTime? nextRetryAt;
  final int consecutiveFailures;

  @override
  List<Object?> get props => [
    phase,
    itemsReceived,
    lastError,
    nextRetryAt,
    consecutiveFailures,
  ];
}

/// Issue d'une execution.
enum SyncOutcome {
  /// Push et pull termines.
  completed,

  /// Reseau absent ou serveur injoignable.
  offline,

  /// Reconnexion necessaire.
  authRequired,

  /// Echec du serveur ou reponse illisible : reprise plus tard.
  failed,

  /// Aucun utilisateur connecte.
  notSignedIn,
}

/// Les cinq etats de l'indicateur (US-SOCLE-013) + la reconnexion.
/// Toujours affiches avec une icone **et** un texte (jamais la couleur seule).
enum SyncIndicator {
  /// A jour (avec l'heure de la derniere synchronisation reussie).
  upToDate,

  /// Hors ligne.
  offline,

  /// En attente : N saisies a envoyer.
  pending,

  /// Synchronisation en cours.
  syncing,

  /// Probleme : N saisies a verifier (refusees ou en conflit), ou echec du serveur.
  problem,

  /// Reconnexion necessaire.
  authRequired,
}

/// Ce que montrent la barre d'etat et le bandeau (CA-013.1, CA-012.5).
class SyncStatusSnapshot extends Equatable {
  const SyncStatusSnapshot({
    required this.indicator,
    this.toSend = 0,
    this.toCheck = 0,
    this.lastSuccessAt,
    this.initialSyncDone = false,
    this.itemsReceived = 0,
    this.isStale = false,
    this.error,
  });

  final SyncIndicator indicator;

  /// Saisies a envoyer (`pending` + `sending`), de l'utilisateur connecte seulement.
  final int toSend;

  /// Saisies a verifier (`rejected` + `conflict`).
  final int toCheck;

  /// Derniere synchronisation reussie (UTC).
  final DateTime? lastSuccessAt;
  final bool initialSyncDone;

  /// Lignes recues pendant la preparation initiale.
  final int itemsReceived;

  /// Plus de 24 h sans synchronisation : bandeau « Donnees du JJ/MM/AAAA HH:MM » (H-12).
  final bool isStale;
  final ApiException? error;

  /// Premiere synchronisation pas encore terminee (ecran « Preparation de vos chantiers... »).
  bool get isPreparing => !initialSyncDone;

  @override
  List<Object?> get props => [
    indicator,
    toSend,
    toCheck,
    lastSuccessAt,
    initialSyncDone,
    itemsReceived,
    isStale,
    error,
  ];
}

/// Calcule l'indicateur a partir de l'etat du moteur et des compteurs exacts de la file.
/// Priorite : en cours > reconnexion > probleme > hors ligne > en attente > a jour.
SyncIndicator deriveIndicator({
  required SyncPhase phase,
  required int toSend,
  required int toCheck,
}) {
  if (phase == SyncPhase.syncing) return SyncIndicator.syncing;
  if (phase == SyncPhase.authRequired) return SyncIndicator.authRequired;
  if (toCheck > 0 || phase == SyncPhase.failed) return SyncIndicator.problem;
  if (phase == SyncPhase.offline) return SyncIndicator.offline;
  if (toSend > 0) return SyncIndicator.pending;
  return SyncIndicator.upToDate;
}
