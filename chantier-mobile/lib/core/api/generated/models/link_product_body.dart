// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'link_product_body.freezed.dart';
part 'link_product_body.g.dart';

/// Rattachement d'un produit du catalogue à une demande en nom libre.
@Freezed()
abstract class LinkProductBody with _$LinkProductBody {
  const factory LinkProductBody({required String productId}) = _LinkProductBody;

  factory LinkProductBody.fromJson(Map<String, Object?> json) =>
      _$LinkProductBodyFromJson(json);
}
