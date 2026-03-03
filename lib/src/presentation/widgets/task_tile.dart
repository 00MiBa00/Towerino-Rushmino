import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/extensions/date_time_x.dart';
import '../../domain/entities/task.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(taskRepositoryProvider);

    return Card(
      child: ListTile(
        title: Text(task.title),
        subtitle: Text('${task.category.name} • ${task.dueAt.formatShort()}'),
        trailing: Checkbox(
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
        onTap: () => context.push('/tasks/${task.id}/edit'),
      ),
    );
  }
}
