import 'package:flutter_test/flutter_test.dart';
import 'package:towerino_rushmino/src/domain/entities/task.dart';
import 'package:towerino_rushmino/src/domain/entities/task_category.dart';
import 'package:towerino_rushmino/src/domain/entities/task_priority.dart';

void main() {
  test('task is overdue when due date is in the past and not completed', () {
    final task = Task(
      id: '1',
      title: 'Past task',
      category: TaskCategory.work,
      priority: TaskPriority.medium,
      dueAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now(),
    );
    expect(task.isOverdue, isTrue);
  });
}
