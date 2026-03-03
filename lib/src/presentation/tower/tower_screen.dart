import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/task_category.dart';
import '../widgets/demo_notice_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/tower_widget.dart';

class TowerScreen extends ConsumerWidget {
  const TowerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tower'),
      ),
      body: taskListAsync.when(
        data: (tasks) {
          final completed = tasks.where((t) => t.isCompleted).toList()
            ..sort((a, b) =>
                (a.completedAt ?? a.createdAt).compareTo(b.completedAt ?? b.createdAt));
          final total = tasks.length;
          final completedCount = completed.length;
          final completionRate = total == 0
              ? 0
              : ((completedCount / total) * 100).round();
          final recentCompleted = completed.reversed.take(3).toList();
          final lastCompleted = recentCompleted.isNotEmpty ? recentCompleted.first : null;
          final nextMilestone = _nextMilestone(completedCount);
          final milestoneProgress = nextMilestone == 0
              ? 0.0
              : (completedCount / nextMilestone).clamp(0.0, 1.0);
          if (completed.isEmpty) {
            return const EmptyState(
              title: 'No completed tasks',
              subtitle: 'Complete tasks to build your tower blocks.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const DemoNoticeBanner(padding: EdgeInsets.only(bottom: 12)),
              SectionHeader(
                title: 'Your tower grows',
                subtitle: 'Each completed task adds a new block to your tower.',
                icon: Icons.domain,
                gradient: const [
                  Color(0xFF1F8A70),
                  Color(0xFF37A97A),
                  Color(0xFF6EDC9D),
                ],
                trailing: Text(
                  '${completed.length} blocks',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Milestone chase',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nextMilestone == 0
                            ? 'Keep building to unlock your next milestone.'
                            : 'Next milestone at $nextMilestone blocks.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: milestoneProgress,
                          minHeight: 10,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completedCount of $nextMilestone blocks',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What you’re seeing',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Blocks represent completed tasks. Taller blocks mean higher priority. '
                        'Colors show task categories.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _LegendDot(
                            label: 'Work',
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          const SizedBox(width: 12),
                          _LegendDot(
                            label: 'Study',
                            color: Theme.of(context).colorScheme.secondaryContainer,
                          ),
                          const SizedBox(width: 12),
                          _LegendDot(
                            label: 'Personal',
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _LegendDot(
                            label: 'Health',
                            color: Theme.of(context).colorScheme.errorContainer,
                          ),
                          const SizedBox(width: 12),
                          _LegendDot(
                            label: 'Custom',
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 420,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TowerWidget(tasks: completed),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent wins',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (lastCompleted != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _categoryColor(
                              context,
                              lastCompleted.category,
                            ),
                            child: Icon(
                              _categoryIcon(lastCompleted.category),
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          title: Text(lastCompleted.title),
                          subtitle: Text('Latest completed task'),
                        ),
                      const Divider(height: 24),
                      ...recentCompleted.map(
                        (task) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _categoryColor(context, task.category),
                            child: Icon(
                              _categoryIcon(task.category),
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          title: Text(task.title),
                          subtitle: Text(task.category.name),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completion rate',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completionRate%',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completed tasks',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completedCount / $total',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

int _nextMilestone(int completedCount) {
  const milestones = [5, 10, 20, 35, 50, 75, 100];
  for (final milestone in milestones) {
    if (completedCount < milestone) return milestone;
  }
  return milestones.last + 25;
}

IconData _categoryIcon(TaskCategory category) {
  switch (category) {
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

Color _categoryColor(BuildContext context, TaskCategory category) {
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
