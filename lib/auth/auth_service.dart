// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // For ChangeNotifier

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user (can be null)
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign up with Email and Password
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // You can do additional setup here, like creating a user document in Firestore
      notifyListeners(); // Notify listeners if needed (e.g., for UI updates after signup)
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., email-already-in-use, weak-password)
      print('Firebase Auth Exception (Sign Up): ${e.message}');
      throw e; // Re-throw to handle in UI
    }
  }

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      notifyListeners(); // Notify listeners if needed
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., user-not-found, wrong-password)
      print('Firebase Auth Exception (Sign In): ${e.message}');
      throw e; // Re-throw to handle in UI
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      notifyListeners(); // Notify listeners if needed
    } catch (e) {
      print('Error signing out: $e');
      // Handle sign-out errors
    }
  }

// You can add more methods here like:
// - Password reset
// - Linking accounts
// - Handling user profile updates (though some might be directly on User object or Firestore)
}
