import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrors {
  static String getMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Invalid email or password.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        default:
          return 'An unexpected authentication error occurred.';
      }
    }
    return error.toString();
  }
}
