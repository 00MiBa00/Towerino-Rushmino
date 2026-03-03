import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task.dart';

class TaskRemoteDataSource {
  TaskRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  Future<List<Task>> fetchTasks(String userId) async {
    final snapshot = await _collection(userId).get();
    return snapshot.docs
        .map((doc) => Task.fromJson(doc.data()))
        .toList();
  }

  Stream<List<Task>> watchTasks(String userId) {
    return _collection(userId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Task.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> upsertTask(String userId, Task task) async {
    await _collection(userId).doc(task.id).set(task.toJson());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _collection(userId).doc(taskId).delete();
  }
}
