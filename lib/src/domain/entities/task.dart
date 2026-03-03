import 'package:freezed_annotation/freezed_annotation.dart';

import 'recurrence.dart';
import 'task_category.dart';
import 'task_priority.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const Task._();

  const factory Task({
    required String id,
    required String title,
    String? description,
    required TaskCategory category,
    required TaskPriority priority,
    required DateTime dueAt,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    @Default(<String>[]) List<String> tags,
    Recurrence? recurrence,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Task;

  bool get isOverdue => !isCompleted && dueAt.isBefore(DateTime.now());
  bool get wasOverdue => completedAt != null && completedAt!.isAfter(dueAt);

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
