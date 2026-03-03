import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/extensions/date_time_x.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task});

  final Task task;

  IconData _categoryIcon() {
    switch (task.category) {
      case TaskCategory.work:
        return Icons.work_rounded;
      case TaskCategory.study:
        return Icons.menu_book_rounded;
      case TaskCategory.personal:
        return Icons.person_rounded;
      case TaskCategory.health:
        return Icons.favorite_rounded;
      case TaskCategory.custom:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _categoryColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (task.category) {
      case TaskCategory.work:
        return scheme.primaryContainer;
      case TaskCategory.study:
        return scheme.secondaryContainer;
      case TaskCategory.personal:
        return scheme.tertiaryContainer;
      case TaskCategory.health:
        return scheme.errorContainer;
      case TaskCategory.custom:
        return scheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(taskRepositoryProvider);
    final scheme = Theme.of(context).colorScheme;
    final accent = _categoryColor(context);

    return Card(
      child: InkWell(
        onTap: () => context.push('/tasks/${task.id}/edit'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _categoryIcon(),
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${task.category.name} • ${task.dueAt.formatShort()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) async {
                  final updated = task.copyWith(
                    isCompleted: value ?? false,
                    completedAt: value == true ? DateTime.now() : null,
                    updatedAt: DateTime.now(),
                  );
                  await repo.updateTask(updated);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
