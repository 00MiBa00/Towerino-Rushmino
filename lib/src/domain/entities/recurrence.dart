import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurrence.freezed.dart';
part 'recurrence.g.dart';

enum RecurrenceUnit { day, week, month }

@freezed
class Recurrence with _$Recurrence {
  const factory Recurrence({
    @Default(1) int interval,
    @Default(RecurrenceUnit.week) RecurrenceUnit unit,
  }) = _Recurrence;

  factory Recurrence.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceFromJson(json);
}
