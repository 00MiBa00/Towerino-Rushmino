import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._auth,
  );

  final TaskLocalDataSource _localDataSource;
  final TaskRemoteDataSource _remoteDataSource;
  final FirebaseAuth _auth;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Stream<List<Task>> watchTasks() {
    return _localDataSource.watchTasks();
  }

  @override
  Future<List<Task>> fetchTasks() async {
    return _localDataSource.fetchTasks();
  }

  @override
  Future<void> addTask(Task task) async {
    await _localDataSource.upsertTask(task);
    final userId = _userId;
    if (userId != null) {
      await _remoteDataSource.upsertTask(userId, task);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    await _localDataSource.upsertTask(task);
    final userId = _userId;
    if (userId != null) {
      await _remoteDataSource.upsertTask(userId, task);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _localDataSource.deleteTask(taskId);
    final userId = _userId;
    if (userId != null) {
      await _remoteDataSource.deleteTask(userId, taskId);
    }
  }

  @override
  Future<void> syncFromRemote() async {
    final userId = _userId;
    if (userId == null) return;
    final remote = await _remoteDataSource.fetchTasks(userId);
    await _localDataSource.replaceAll(remote);
  }
}
