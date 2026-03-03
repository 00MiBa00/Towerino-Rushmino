import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_priority.dart';

class TowerWidget extends StatelessWidget {
  const TowerWidget({super.key, required this.tasks});

  final List<Task> tasks;

  double _blockHeight(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 18;
      case TaskPriority.medium:
        return 26;
      case TaskPriority.high:
        return 34;
    }
  }

  Color _blockColor(BuildContext context, TaskCategory category) {
    final scheme = Theme.of(context).colorScheme;
    switch (category) {
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
  Widget build(BuildContext context) {
    final blocks = tasks
        .map(
          (task) => Container(
            height: _blockHeight(task.priority),
            decoration: BoxDecoration(
              color: _blockColor(context, task.category),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: task.wasOverdue
                    ? Theme.of(context).colorScheme.error
                    : Colors.transparent,
                width: task.wasOverdue ? 2 : 1,
              ),
            ),
          ),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.4),
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ...blocks,
                  const SizedBox(height: 8),
                  Container(
                    width: constraints.maxWidth * 0.7,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.08),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
