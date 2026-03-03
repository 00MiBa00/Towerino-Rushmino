import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInAnonymously();
  Future<void> signOut();
}
