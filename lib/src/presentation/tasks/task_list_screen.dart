import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/constants.dart';
import '../widgets/demo_notice_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/task_tile.dart';

final rushModeProvider = Provider<bool>((ref) {
  final tasks = ref.watch(taskListProvider).value ?? [];
  final overdueCount = tasks.where((task) => task.isOverdue).length;
  return overdueCount >= AppConstants.rushModeOverdueThreshold;
});

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListAsync = ref.watch(taskListProvider);
    final rushMode = ref.watch(rushModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          if (rushMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: const Text('Rush Mode'),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
            ),
        ],
      ),
      body: taskListAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const EmptyState(
              title: 'No tasks yet',
              subtitle: 'Create a task to start building your tower.',
            );
          }
          final completedCount = tasks.where((task) => task.isCompleted).length;
          final overdueCount = tasks.where((task) => task.isOverdue).length;
          final sorted = [...tasks]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Today’s focus',
                    subtitle: 'Stay on track and grow your tower daily.',
                    icon: Icons.bolt,
                    gradient: const [
                      Color(0xFF7F5CFF),
                      Color(0xFF5B6CFF),
                      Color(0xFF2EC4FF),
                    ],
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$completedCount / ${tasks.length}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          overdueCount == 0
                              ? 'All clear'
                              : '$overdueCount overdue',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: DemoNoticeBanner(
                    padding: const EdgeInsets.only(bottom: 12),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = sorted[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskTile(task: task),
                      );
                    },
                    childCount: sorted.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/new'),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
    );
  }
}
