// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurrenceImpl _$$RecurrenceImplFromJson(Map<String, dynamic> json) =>
    _$RecurrenceImpl(
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      unit:
          $enumDecodeNullable(_$RecurrenceUnitEnumMap, json['unit']) ??
          RecurrenceUnit.week,
    );

Map<String, dynamic> _$$RecurrenceImplToJson(_$RecurrenceImpl instance) =>
    <String, dynamic>{
      'interval': instance.interval,
      'unit': _$RecurrenceUnitEnumMap[instance.unit]!,
    };

const _$RecurrenceUnitEnumMap = {
  RecurrenceUnit.day: 'day',
  RecurrenceUnit.week: 'week',
  RecurrenceUnit.month: 'month',
};
