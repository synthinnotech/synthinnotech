import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/model/login/login_state.dart';
import 'package:synthinnotech/model/user/app_user.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/auth/data/auth_repository.dart';

/// Compatibility bridge.
///
/// The real auth engine now lives in `lib/modules/auth`. This keeps the
/// long-standing `loginViewModelProvider` / `LoginState.user` API that the
/// existing screens read, but wires it to [AuthRepository] +
/// [authUserProvider] so `state.user` always reflects the live Firebase auth
/// state.
class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel(this._repo) : super(const LoginState());

  final AuthRepository _repo;

  void setUser(AppUser? user) {
    state = LoginState(
      user: user,
      isLoading: false,
      isPasswordVisible: state.isPasswordVisible,
    );
  }

  /// Legacy entry point kept for callers that pre-loaded a cached user.
  void loadUser(AppUser user) => setUser(user);

  void togglePasswordVisibility() =>
      state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);

  void clearError() {
    if (state.errorMessage != null) {
      state = LoginState(
        isLoading: state.isLoading,
        isPasswordVisible: state.isPasswordVisible,
        user: state.user,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = LoginState(isLoading: true, isPasswordVisible: state.isPasswordVisible);
    try {
      final user = await _repo.signIn(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Sign in failed. Please try again.');
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
    state = const LoginState();
  }
}

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  final vm = LoginViewModel(ref.watch(authRepositoryProvider));
  ref.listen<AsyncValue<AppUser?>>(
    authUserProvider,
    (_, next) => vm.setUser(next.valueOrNull),
    fireImmediately: true,
  );
  return vm;
});
