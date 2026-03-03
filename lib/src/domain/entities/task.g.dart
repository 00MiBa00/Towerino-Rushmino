// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  category: $enumDecode(_$TaskCategoryEnumMap, json['category']),
  priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
  dueAt: DateTime.parse(json['dueAt'] as String),
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  recurrence: json['recurrence'] == null
      ? null
      : Recurrence.fromJson(json['recurrence'] as Map<String, dynamic>),
  isArchived: json['isArchived'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': _$TaskCategoryEnumMap[instance.category]!,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'dueAt': instance.dueAt.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'tags': instance.tags,
      'recurrence': instance.recurrence,
      'isArchived': instance.isArchived,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$TaskCategoryEnumMap = {
  TaskCategory.work: 'work',
  TaskCategory.study: 'study',
  TaskCategory.personal: 'personal',
  TaskCategory.health: 'health',
  TaskCategory.custom: 'custom',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
};
