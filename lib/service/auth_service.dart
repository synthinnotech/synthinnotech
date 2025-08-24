import 'package:synthinnotech/model/login/login_request.dart';

abstract class AuthService {
  Future<bool> login(LoginRequest request);
}

class AuthServiceImpl implements AuthService {
  @override
  Future<bool> login(LoginRequest request) async {
    await Future.delayed(const Duration(seconds: 2));
    if (request.email == "admin@example.com" &&
        request.password == "password123") {
      return true;
    }
    throw Exception("Invalid credentials");
  }
}
