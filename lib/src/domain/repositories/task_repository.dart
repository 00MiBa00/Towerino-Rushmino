import '../entities/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks();
  Future<List<Task>> fetchTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> syncFromRemote();
}
