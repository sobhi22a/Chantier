import 'dart:convert';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:equatable/equatable.dart';

/// Commande incorporee a une demande (`order_json`, sans aucun champ commercial : ni prix, ni
/// montant, ni n° de bon de commande, ADR 0012). Lue a la demande, jamais stockee ailleurs.
class OrderInfo extends Equatable {
  const OrderInfo({
    this.supplierId,
    this.supplierName,
    this.expectedDeliveryDate,
    this.orderDate,
  });

  final String? supplierId;
  final String? supplierName;

  /// Date de livraison prevue (jour d'Algerie, UTC a minuit).
  final DateTime? expectedDeliveryDate;
  final DateTime? orderDate;

  @override
  List<Object?> get props => [
    supplierId,
    supplierName,
    expectedDeliveryDate,
    orderDate,
  ];

  /// Lit `order_json` ; `null` sans commande ou si le texte est illisible.
  static OrderInfo? parse(String? json) {
    if (json == null) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;
    return OrderInfo(
      supplierId: decoded['supplierId'] as String?,
      supplierName: decoded['supplierName'] as String?,
      expectedDeliveryDate: _date(decoded['expectedDeliveryDate']),
      orderDate: _date(decoded['orderDate']),
    );
  }

  static DateTime? _date(Object? value) {
    if (value is! String) return null;
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
    if (match == null) return null;
    return DateTime.utc(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }
}

extension OrderInfoRow on MaterialRequestRow {
  OrderInfo? get order => OrderInfo.parse(orderJson);
}
