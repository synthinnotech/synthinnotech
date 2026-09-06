import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/model/user/app_user.dart';
import 'package:synthinnotech/modules/auth/application/onboarding_prefs.dart';
import 'package:synthinnotech/modules/auth/data/auth_repository.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

/// Whether this device has completed onboarding / accepted the policy.
/// Invalidate after the user accepts so [AuthGate] re-evaluates.
final policyAcceptedProvider =
    FutureProvider<bool>((ref) => OnboardingPrefs.policyAccepted());

/// Merged Auth + Firestore-profile stream. This is the single source of truth
/// for "who is signed in".
final authUserProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).changes();
});

/// Synchronous accessor for the current user (null while loading or signed out).
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authUserProvider).valueOrNull;
});

/// True once we know for sure whether someone is signed in.
final authResolvedProvider = Provider<bool>((ref) {
  return !ref.watch(authUserProvider).isLoading;
});

// ── Sign-in form controller ─────────────────────────────────────────────

class SignInState {
  final bool isSubmitting;
  final bool passwordVisible;
  final String? error;

  const SignInState({
    this.isSubmitting = false,
    this.passwordVisible = false,
    this.error,
  });

  SignInState copyWith({
    bool? isSubmitting,
    bool? passwordVisible,
    Object? error = _sentinel,
  }) =>
      SignInState(
        isSubmitting: isSubmitting ?? this.isSubmitting,
        passwordVisible: passwordVisible ?? this.passwordVisible,
        error: identical(error, _sentinel) ? this.error : error as String?,
      );

  static const _sentinel = Object();
}

class SignInController extends StateNotifier<SignInState> {
  SignInController(this._repo) : super(const SignInState());
  final AuthRepository _repo;

  static final _emailRe =
      RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');

  void togglePasswordVisibility() =>
      state = state.copyWith(passwordVisible: !state.passwordVisible);

  void clearError() {
    if (state.error != null) state = state.copyWith(error: null);
  }

  Future<bool> submit(String email, String password) async {
    final e = email.trim();
    if (e.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields.');
      return false;
    }
    if (!_emailRe.hasMatch(e)) {
      state = state.copyWith(error: 'Please enter a valid email address.');
      return false;
    }
    if (password.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters.');
      return false;
    }
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _repo.signIn(email: e, password: password);
      state = state.copyWith(isSubmitting: false);
      return true;
    } on AppException catch (err) {
      state = state.copyWith(isSubmitting: false, error: err.message);
      return false;
    } catch (err) {
      state = state.copyWith(
          isSubmitting: false, error: 'Sign in failed. Please try again.');
      return false;
    }
  }
}

final signInControllerProvider =
    StateNotifierProvider<SignInController, SignInState>(
  (ref) => SignInController(ref.watch(authRepositoryProvider)),
);
