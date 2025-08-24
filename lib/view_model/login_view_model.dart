import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/login/login_request.dart';
import 'package:synthinnotech/model/login/login_state.dart';
import 'package:synthinnotech/service/auth_service.dart';

final authRepositoryProvider = Provider<AuthService>((ref) {
  return AuthServiceImpl();
});

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthService _authRepository;

  LoginViewModel(this._authRepository) : super(const LoginState());

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: "Please fill in all fields!");
      return;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(errorMessage: "Please enter a valid email!");
      return;
    }

    if (password.length < 6) {
      state = state.copyWith(
          errorMessage: "Password should have atleast 6 characters!");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final request = LoginRequest(email: email, password: password);
      await _authRepository.login(request);
      state = state.copyWith(isLoading: false, isLoggedIn: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(ref.read(authRepositoryProvider));
});
