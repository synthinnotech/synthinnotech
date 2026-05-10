import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/login/login_request.dart';
import 'package:synthinnotech/model/login/login_state.dart';
import 'package:synthinnotech/model/user/app_user.dart';
import 'package:synthinnotech/service/auth_service.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginViewModel(this._authService) : super(const LoginState());

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = LoginState(
        isLoading: state.isLoading,
        isPasswordVisible: state.isPasswordVisible,
        user: state.user,
      );
    }
  }

  void loadUser(AppUser user) {
    state = state.copyWith(user: user, isLoading: false);
  }

  void logout() {
    state = const LoginState();
    _authService.logout();
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill in all fields!');
      return;
    }
    if (!_isValidEmail(email)) {
      state = state.copyWith(errorMessage: 'Please enter a valid email!');
      return;
    }
    if (password.length < 6) {
      state = state.copyWith(
          errorMessage: 'Password must be at least 6 characters!');
      return;
    }
    state = LoginState(
      isLoading: true,
      isPasswordVisible: state.isPasswordVisible,
      user: state.user,
    );
    try {
      final request = LoginRequest(email: email, password: password);
      final user = await _authService.login(request);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(ref.read(authServiceProvider));
});
