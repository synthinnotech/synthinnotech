// firebase_auth re-exports FirebaseException from firebase_core.
import 'package:firebase_auth/firebase_auth.dart';

/// A single, user-presentable error type used across every layer of the app.
///
/// Services translate low-level failures (FirebaseException, PlatformException,
/// SocketException, …) into an [AppException] with a clean [message] so the UI
/// can show something meaningful instead of silently falling back to fake data.
class AppException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const AppException(this.message, {this.code, this.cause});

  /// Whether the failure looks like it was caused by Firestore security rules.
  bool get isPermissionDenied => code == 'permission-denied';

  /// Whether the failure is a missing composite index (developer needs to
  /// deploy `firestore.indexes.json`).
  bool get isMissingIndex => code == 'failed-precondition';

  /// Whether the device just looks offline.
  bool get isNetwork =>
      code == 'unavailable' ||
      code == 'network-request-failed' ||
      code == 'deadline-exceeded';

  @override
  String toString() => 'AppException($code): $message';

  // ─────────────────────────────────────────────────────────────────────────
  // Factories
  // ─────────────────────────────────────────────────────────────────────────

  factory AppException.from(Object error, [StackTrace? _]) {
    if (error is AppException) return error;

    if (error is FirebaseAuthException) {
      return AppException(_authMessage(error.code), code: error.code, cause: error);
    }

    if (error is FirebaseException) {
      return AppException(_firestoreMessage(error.code, error.message),
          code: error.code, cause: error);
    }

    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('Failed host lookup') ||
        text.contains('Connection closed')) {
      return AppException(
        'You appear to be offline. Check your connection and try again.',
        code: 'unavailable',
        cause: error,
      );
    }

    return AppException('Something went wrong. Please try again.',
        code: 'unknown', cause: error);
  }

  static String _firestoreMessage(String code, String? raw) {
    switch (code) {
      case 'permission-denied':
        return 'You don\'t have permission to do that. '
            '(Deploy firestore.rules — see SETUP.md.)';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Can\'t reach the server right now. Check your connection.';
      case 'failed-precondition':
        return 'This query needs a database index. '
            'Deploy firestore.indexes.json (see SETUP.md).';
      case 'not-found':
        return 'That record no longer exists.';
      case 'already-exists':
        return 'That record already exists.';
      case 'resource-exhausted':
        return 'Usage limit reached. Try again later.';
      case 'unauthenticated':
        return 'Your session expired. Please sign in again.';
      default:
        return raw ?? 'Database error ($code).';
    }
  }

  static String _authMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact your administrator.';
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'requires-recent-login':
        return 'Please sign in again before making this change.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
