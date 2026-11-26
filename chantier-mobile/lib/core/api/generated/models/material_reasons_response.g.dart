// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_reasons_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaterialReasonsResponse _$MaterialReasonsResponseFromJson(
  Map<String, dynamic> json,
) => _MaterialReasonsResponse(
  rejection: (json['rejection'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requestCancellation: (json['requestCancellation'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  orderCancellation: (json['orderCancellation'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  settle: (json['settle'] as List<dynamic>).map((e) => e as String).toList(),
  deliveryCancellation: (json['deliveryCancellation'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  reserve: (json['reserve'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$MaterialReasonsResponseToJson(
  _MaterialReasonsResponse instance,
) => <String, dynamic>{
  'rejection': instance.rejection,
  'requestCancellation': instance.requestCancellation,
  'orderCancellation': instance.orderCancellation,
  'settle': instance.settle,
  'deliveryCancellation': instance.deliveryCancellation,
  'reserve': instance.reserve,
};
