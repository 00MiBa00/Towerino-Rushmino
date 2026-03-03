import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/services/settings_service.dart';
import '../data/datasources/task_local_datasource.dart';
import '../data/datasources/task_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/purchase_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import '../domain/entities/task.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/purchase_repository.dart';
import '../domain/repositories/task_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());
final inAppPurchaseProvider = Provider<InAppPurchase>((ref) => InAppPurchase.instance);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  );
});

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final box = Hive.box<String>(AppConstants.hiveTasksBox);
  return TaskLocalDataSource(box);
});

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource(ref.watch(firestoreProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    ref.watch(taskLocalDataSourceProvider),
    ref.watch(taskRemoteDataSourceProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepositoryImpl(ref.watch(inAppPurchaseProvider));
});

final settingsServiceProvider = FutureProvider<SettingsService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SettingsService(prefs);
});

final demoModeProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsServiceProvider);
  return settingsAsync.maybeWhen(
    data: (settings) => settings.demoDataEnabled,
    orElse: () => false,
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final taskListProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
});
