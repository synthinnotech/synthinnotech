import 'package:synthinnotech/model/user/app_user.dart';

class LoginState {
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final AppUser? user;

  const LoginState({
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.errorMessage,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isPasswordVisible,
    String? errorMessage,
    AppUser? user,
  }) =>
      LoginState(
        isLoading: isLoading ?? this.isLoading,
        isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
        errorMessage: errorMessage,
        user: user ?? this.user,
      );
}
