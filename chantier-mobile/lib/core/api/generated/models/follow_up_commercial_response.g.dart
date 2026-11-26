// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_up_commercial_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowUpCommercialResponse _$FollowUpCommercialResponseFromJson(
  Map<String, dynamic> json,
) => _FollowUpCommercialResponse(
  orderedAmount: (json['orderedAmount'] as num).toDouble(),
  receivedValue: (json['receivedValue'] as num).toDouble(),
);

Map<String, dynamic> _$FollowUpCommercialResponseToJson(
  _FollowUpCommercialResponse instance,
) => <String, dynamic>{
  'orderedAmount': instance.orderedAmount,
  'receivedValue': instance.receivedValue,
};
