import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Recu cumule, reste, ecart et statut d'une commande, tous **dans l'unite de la commande**
/// (resultat de [QuantityMirror.computeStatus]).
class ReceptionState extends Equatable {
  const ReceptionState({
    required this.unit,
    required this.received,
    required this.remaining,
    required this.variance,
    required this.variancePercent,
    required this.status,
    required this.isProvisional,
  });

  final MeasureUnit unit;
  final Decimal received;

  /// Jamais negatif.
  final Decimal remaining;

  /// Negatif = manque, positif = surplus.
  final Decimal variance;

  /// Deux decimales, arrondi « loin de zero ».
  final Decimal variancePercent;

  /// `validated` (livraisons retenues avant commande), `ordered`, `partiallyDelivered` ou
  /// `delivered`.
  final RequestStatus status;

  /// Vrai quand le calcul tient compte d'une saisie **en attente d'envoi** : a afficher « a
  /// confirmer » jusqu'a la reponse du serveur, qui recalcule et remplace toujours cette valeur.
  final bool isProvisional;

  Quantity get receivedQuantity => Quantity(received, unit);
  Quantity get remainingQuantity => Quantity(remaining, unit);
  Quantity get varianceQuantity => Quantity(variance, unit);

  @override
  List<Object?> get props => [
    unit,
    received,
    remaining,
    variance,
    variancePercent,
    status,
    isProvisional,
  ];
}

/// Une livraison vue par le calcul de statut : sa quantite (dans son unite de saisie), si elle
/// est annulee (hors totaux) et si elle attend encore son envoi.
class DeliveryFact extends Equatable {
  const DeliveryFact({
    required this.quantity,
    this.isCancelled = false,
    this.isPending = false,
  });

  final Quantity quantity;
  final bool isCancelled;
  final bool isPending;

  @override
  List<Object?> get props => [quantity, isCancelled, isPending];
}

/// Une ligne de total (resultat de [QuantityMirror.aggregate]).
class AggregateLine extends Equatable {
  const AggregateLine({required this.total, this.massEquivalent});

  final Quantity total;

  /// « 400 sacs = 20 T » ; `null` hors d'un total en sacs avec masse de sac connue.
  final Quantity? massEquivalent;

  @override
  List<Object?> get props => [total, massEquivalent];
}

/// **Miroir d'affichage** des regles de calcul des quantites (ADR 0014, option B).
///
/// Le **serveur fait foi** (regle 3) : ce miroir ne sert qu'a montrer, sans reseau, « 300 sacs =
/// 15 T » pendant la frappe et le statut **provisoire** d'une demande apres une livraison saisie
/// hors ligne. Il se limite a la conversion, au cumul et au statut ; il n'ecrit **aucun montant**
/// (aucun prix n'existe sur le telephone, ADR 0012) ni total de chantier. Les arrondis monetaires
/// du fichier de vecteurs ne sont donc verifies que par la primitive [roundAwayFromZero].
///
/// Il est teste par les memes vecteurs que le serveur et le web (`docs/api/vecteurs-materiaux.json`).
/// Toute regle modifiee change d'abord ce fichier. Aucun `double` : `Decimal` seulement.
abstract final class QuantityMirror {
  /// Decimales d'une quantite.
  static const int quantityScale = 3;

  /// Decimales d'un pourcentage d'ecart.
  static const int percentScale = 2;

  static final Decimal _kilosPerTonne = Decimal.fromInt(1000);
  static final Decimal _zero = Decimal.zero;
  static final Decimal _hundred = Decimal.fromInt(100);

  /// `numerateur / denominateur` arrondi a [scale] decimales **« loin de zero »**
  /// (`MidpointRounding.AwayFromZero` du serveur) : 613,125 -> 613,13, jamais l'arrondi bancaire
  /// (613,12). Calcul exact sur des fractions, sans passer par un `double`.
  static Decimal roundAwayFromZero(
    Decimal numerator,
    Decimal denominator,
    int scale,
  ) {
    // Fraction exacte, arrondie une seule fois (pas de double arrondi) : `Rational.round` arrondit
    // la moitie en s'eloignant de zero, y compris pour les valeurs negatives.
    final scaled = numerator.shift(scale) / denominator;
    return Decimal.fromBigInt(scaled.round()).shift(-scale);
  }

  /// Masse en kg d'une unite de la famille `sac` / `kg` / `t`.
  static Decimal _kilosPerUnit(MeasureUnit unit, Decimal? bagMassKg) {
    switch (unit) {
      case MeasureUnit.kilogram:
        return Decimal.one;
      case MeasureUnit.tonne:
        return _kilosPerTonne;
      case MeasureUnit.bag:
        if (bagMassKg == null || bagMassKg <= _zero) {
          throw const QuantityException('UNITES_INCOMPATIBLES');
        }
        return bagMassKg;
      default:
        throw const QuantityException('UNITES_INCOMPATIBLES');
    }
  }

  /// Convertit [from] vers [to]. Seules conversions : `sac` <-> `kg` <-> `t`, via la masse du sac
  /// du produit [bagMassKg]. Resultat a 3 decimales, arrondi « loin de zero ».
  ///
  /// Toute autre paire (m³ <-> T, L <-> kg), ou `sac` sans masse de sac, leve
  /// `QuantityException('UNITES_INCOMPATIBLES')` : aucune conversion implicite.
  static Quantity convert(Quantity from, MeasureUnit to, {Decimal? bagMassKg}) {
    if (from.unit == to) return from;
    if (!from.unit.isMass || !to.isMass) {
      throw const QuantityException('UNITES_INCOMPATIBLES');
    }
    final kilos = from.value * _kilosPerUnit(from.unit, bagMassKg);
    final result = roundAwayFromZero(
      kilos,
      _kilosPerUnit(to, bagMassKg),
      quantityScale,
    );
    return Quantity(result, to);
  }

  /// Equivalence affichee sous la quantite tapee (CA-MAT-001.3), ou `null` :
  /// * sacs -> tonnes (a partir d'une tonne) ou kilogrammes : 300 sacs = 15 T, 15 sacs = 750 kg ;
  /// * tonnes ou kilogrammes -> sacs (si la masse du sac est connue) : 17,5 T = 350 sacs ;
  /// * jamais pour m³, u, L (aucune conversion autorisee).
  static Quantity? equivalence(Quantity quantity, {Decimal? bagMassKg}) {
    if (!quantity.unit.isMass || quantity.value <= _zero) return null;
    final hasBagMass = bagMassKg != null && bagMassKg > _zero;
    if (quantity.unit == MeasureUnit.bag) {
      if (!hasBagMass) return null;
      final kilos = convert(
        quantity,
        MeasureUnit.kilogram,
        bagMassKg: bagMassKg,
      );
      return kilos.value >= _kilosPerTonne
          ? convert(quantity, MeasureUnit.tonne, bagMassKg: bagMassKg)
          : kilos;
    }
    return hasBagMass
        ? convert(quantity, MeasureUnit.bag, bagMassKg: bagMassKg)
        : null;
  }

  /// Code d'erreur d'une quantite saisie, ou `null` si elle est valide :
  /// `QUANTITE_INVALIDE` (<= 0 ou plus de 3 decimales), `QUANTITE_ENTIERE_REQUISE` (decimale avec
  /// `sac` ou `u`). L'unite manquante (`UNITE_OBLIGATOIRE`) se controle dans le formulaire : une
  /// [Quantity] porte toujours son unite.
  static String? check(Quantity quantity) {
    if (quantity.value <= _zero) return 'QUANTITE_INVALIDE';
    if (quantity.value.scale > quantityScale) return 'QUANTITE_INVALIDE';
    if (quantity.unit.integerOnly && !quantity.value.isInteger) {
      return 'QUANTITE_ENTIERE_REQUISE';
    }
    return null;
  }

  /// Quantite tapee au clavier numerique : « 2,5 » et « 2.5 » sont acceptes. `null` tant que le
  /// texte n'est pas un nombre complet (vide, « 2, », lettres). Le signe `-` est lu pour que
  /// [check] refuse ensuite la valeur negative (`QUANTITE_INVALIDE`).
  static Decimal? parseInput(String text) {
    final trimmed = text.trim();
    if (!RegExp(r'^-?\d+([.,]\d+)?$').hasMatch(trimmed)) return null;
    return Decimal.tryParse(trimmed.replaceFirst(',', '.'));
  }

  /// Recu cumule, reste, ecart et statut d'une commande de [ordered], d'apres les livraisons
  /// **non annulees** [deliveries] (chacune convertie dans l'unite de la commande).
  ///
  /// * recu = 0 : `ordered` ; recu < commande : `partiallyDelivered` ; recu >= commande :
  ///   `delivered` ;
  /// * un manque dont le pourcentage **exact** ne depasse pas [tolerancePercent] (0 par defaut) ou
  ///   une demande soldee [isSettled] compte aussi comme livree ;
  /// * une livraison dans une unite non convertible leve `UNITES_INCOMPATIBLES`.
  ///
  /// [isProvisional] marque un calcul qui tient compte d'une saisie en attente d'envoi.
  static ReceptionState computeStatus({
    required Quantity ordered,
    required Iterable<Quantity> deliveries,
    Decimal? bagMassKg,
    Decimal? tolerancePercent,
    bool isSettled = false,
    bool isProvisional = false,
  }) {
    if (ordered.value <= _zero) {
      throw const QuantityException('QUANTITE_INVALIDE');
    }
    var received = _zero;
    for (final delivery in deliveries) {
      received += convert(delivery, ordered.unit, bagMassKg: bagMassKg).value;
    }
    final variance = received - ordered.value;
    final remaining = variance < _zero ? -variance : _zero;
    final percent = roundAwayFromZero(
      variance * _hundred,
      ordered.value,
      percentScale,
    );

    final tolerance = tolerancePercent ?? _zero;
    // Comparaison exacte (sans passer par le pourcentage arrondi) : avec 0 %, un manque minuscule
    // (-0,004 %) n'est pas « complet ».
    final withinTolerance =
        variance < _zero && (-variance * _hundred) <= tolerance * ordered.value;
    final complete = variance >= _zero || isSettled || withinTolerance;

    final status = received == _zero
        ? RequestStatus.ordered
        : complete
        ? RequestStatus.delivered
        : RequestStatus.partiallyDelivered;
    return ReceptionState(
      unit: ordered.unit,
      received: received,
      remaining: remaining,
      variance: variance,
      variancePercent: percent,
      status: status,
      isProvisional: isProvisional,
    );
  }

  /// Etat **provisoire** d'une demande dont on connait les livraisons, y compris celles saisies
  /// hors ligne et pas encore envoyees (« a confirmer », CA-MAT-006.7, CA-MAT-010.11).
  ///
  /// Meme regle que le serveur (`RequestStatusCalculator`) :
  /// * `ordered`, `partiallyDelivered`, `delivered` : statut recalcule **dans les deux sens**
  ///   d'apres les livraisons non annulees (annuler une livraison fait redescendre le statut) ;
  /// * `validated` : les livraisons sont **retenues** (le recu s'affiche) mais le statut reste
  ///   `validated` tant que les Achats n'ont pas commande ;
  /// * tout autre statut (demandee, refusee, annulee, receptionnee) : `null`, aucun recalcul ;
  /// * livraison dans une unite non convertible : `null` (le serveur la refusera, rien d'invente).
  ///
  /// Le resultat est marque provisoire des qu'une livraison en attente d'envoi y contribue.
  static ReceptionState? provisionalReception({
    required RequestStatus status,
    required Quantity ordered,
    required Iterable<DeliveryFact> deliveries,
    Decimal? bagMassKg,
    Decimal? tolerancePercent,
    bool isSettled = false,
  }) {
    final recalculated =
        status == RequestStatus.ordered ||
        status == RequestStatus.partiallyDelivered ||
        status == RequestStatus.delivered;
    if (!recalculated && status != RequestStatus.validated) return null;

    final active = [
      for (final delivery in deliveries)
        if (!delivery.isCancelled) delivery,
    ];
    final ReceptionState state;
    try {
      state = computeStatus(
        ordered: ordered,
        deliveries: [for (final delivery in active) delivery.quantity],
        bagMassKg: bagMassKg,
        tolerancePercent: tolerancePercent,
        isSettled: isSettled,
        isProvisional: active.any((delivery) => delivery.isPending),
      );
    } on QuantityException {
      return null;
    }
    if (recalculated) return state;
    return ReceptionState(
      unit: state.unit,
      received: state.received,
      remaining: state.remaining,
      variance: state.variance,
      variancePercent: state.variancePercent,
      status: RequestStatus.validated,
      isProvisional: state.isProvisional,
    );
  }

  /// Totaux d'un produit **sans jamais melanger les unites** (vecteurs `aggregates`).
  ///
  /// Les quantites de la famille convertible de [defaultUnit] (`sac` / `kg` / `t`, avec la masse du
  /// sac pour les sacs) sont additionnees **dans l'unite par defaut** ; toute autre unite forme sa
  /// propre ligne (24 m³ et 10 T restent deux lignes). La ligne de l'unite par defaut vient en
  /// premier, les autres dans l'ordre de leur premiere apparition. Un total en sacs porte son
  /// equivalent en masse (400 sacs = 20 T).
  static List<AggregateLine> aggregate(
    Iterable<Quantity> items, {
    required MeasureUnit defaultUnit,
    Decimal? bagMassKg,
  }) {
    final hasBagMass = bagMassKg != null && bagMassKg > _zero;
    bool inDefaultFamily(MeasureUnit unit) {
      if (unit == defaultUnit) return true;
      if (!defaultUnit.isMass || !unit.isMass) return false;
      // Un sac (par defaut ou saisi) n'est convertible que si sa masse est connue.
      return hasBagMass ||
          (unit != MeasureUnit.bag && defaultUnit != MeasureUnit.bag);
    }

    var defaultTotal = _zero;
    var hasDefault = false;
    final others = <MeasureUnit, Decimal>{};
    for (final item in items) {
      if (inDefaultFamily(item.unit)) {
        defaultTotal += convert(item, defaultUnit, bagMassKg: bagMassKg).value;
        hasDefault = true;
      } else {
        others[item.unit] = (others[item.unit] ?? _zero) + item.value;
      }
    }

    final lines = <AggregateLine>[];
    if (hasDefault) {
      final total = Quantity(defaultTotal, defaultUnit);
      lines.add(
        AggregateLine(
          total: total,
          massEquivalent: defaultUnit == MeasureUnit.bag
              ? equivalence(total, bagMassKg: bagMassKg)
              : null,
        ),
      );
    }
    for (final entry in others.entries) {
      lines.add(AggregateLine(total: Quantity(entry.value, entry.key)));
    }
    return lines;
  }
}
