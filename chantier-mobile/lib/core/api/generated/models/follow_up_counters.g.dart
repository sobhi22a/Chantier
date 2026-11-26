// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_up_counters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowUpCounters _$FollowUpCountersFromJson(Map<String, dynamic> json) =>
    _FollowUpCounters(
      toApprove: (json['toApprove'] as num).toInt(),
      toOrder: (json['toOrder'] as num).toInt(),
      expected: (json['expected'] as num).toInt(),
      lateValue: (json['late'] as num).toInt(),
      toReceive: (json['toReceive'] as num).toInt(),
    );

Map<String, dynamic> _$FollowUpCountersToJson(_FollowUpCounters instance) =>
    <String, dynamic>{
      'toApprove': instance.toApprove,
      'toOrder': instance.toOrder,
      'expected': instance.expected,
      'late': instance.lateValue,
      'toReceive': instance.toReceive,
    };
