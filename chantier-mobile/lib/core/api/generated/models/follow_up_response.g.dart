// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_up_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowUpResponse _$FollowUpResponseFromJson(Map<String, dynamic> json) =>
    _FollowUpResponse(
      counters: FollowUpCounters.fromJson(
        json['counters'] as Map<String, dynamic>,
      ),
      toOrderTotals: (json['toOrderTotals'] as List<dynamic>)
          .map((e) => ToOrderTotalLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      commercial: json['commercial'] == null
          ? null
          : FollowUpCommercialResponse.fromJson(
              json['commercial'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$FollowUpResponseToJson(_FollowUpResponse instance) =>
    <String, dynamic>{
      'counters': instance.counters,
      'toOrderTotals': instance.toOrderTotals,
      'commercial': instance.commercial,
    };
