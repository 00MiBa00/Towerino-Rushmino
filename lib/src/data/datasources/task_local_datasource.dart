import 'dart:convert';

import 'package:hive/hive.dart';

import '../../core/constants.dart';
import '../../domain/entities/task.dart';

class TaskLocalDataSource {
  static const String boxName = AppConstants.hiveTasksBox;

  final Box<String> _box;

  TaskLocalDataSource(this._box);

  Stream<List<Task>> watchTasks() async* {
    yield await fetchTasks();
    yield* _box.watch().asyncMap((_) => fetchTasks());
  }

  Future<List<Task>> fetchTasks() async {
    return _box.values
        .map((jsonStr) => Task.fromJson(json.decode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertTask(Task task) async {
    await _box.put(task.id, json.encode(task.toJson()));
  }

  Future<void> deleteTask(String taskId) async {
    await _box.delete(taskId);
  }

  Future<void> replaceAll(List<Task> tasks) async {
    await _box.clear();
    for (final task in tasks) {
      await upsertTask(task);
    }
  }
}
