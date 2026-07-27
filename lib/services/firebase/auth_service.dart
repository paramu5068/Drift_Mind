import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': credential.user!.uid,
        }, SetOptions(merge: true));
        
        // Update local display name for immediate UI feedback
        await credential.user!.updateDisplayName(name);
      }
      return credential;
    } catch (e) {
      debugPrint('SignUp Error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('SignIn Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> getUserName() async {
    if (currentUser == null) return null;
    
    // Priority 1: Check Display Name
    if (currentUser!.displayName != null && currentUser!.displayName!.isNotEmpty) {
      return currentUser!.displayName;
    }

    // Priority 2: Fetch from Firestore
    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      return doc.data()?['name'] as String?;
    } catch (e) {
      return null;
    }
  }
}
