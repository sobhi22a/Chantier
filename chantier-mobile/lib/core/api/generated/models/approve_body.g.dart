// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approve_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApproveBody _$ApproveBodyFromJson(Map<String, dynamic> json) => _ApproveBody(
  quantity: json['quantity'] == null
      ? null
      : QuantityBody.fromJson(json['quantity'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApproveBodyToJson(_ApproveBody instance) =>
    <String, dynamic>{'quantity': instance.quantity};
