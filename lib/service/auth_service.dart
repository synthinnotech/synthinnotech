import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synthinnotech/model/login/login_request.dart';
import 'package:synthinnotech/model/user/app_user.dart';

abstract class AuthService {
  Future<AppUser> login(LoginRequest request);
  Future<void> logout();
}

final authServiceProvider = Provider<AuthService>((ref) => AuthServiceImpl());

class AuthServiceImpl implements AuthService {
  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  @override
  Future<AppUser> login(LoginRequest request) async {
    if (_firebaseReady) {
      return _firebaseLogin(request);
    }
    return _mockLogin(request);
  }

  Future<AppUser> _firebaseLogin(LoginRequest request) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );
      final uid = credential.user!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      AppUser user;
      if (doc.exists && doc.data() != null) {
        user = AppUser.fromJson({...doc.data()!, 'uid': uid});
      } else {
        user = AppUser(
          uid: uid,
          name: credential.user!.displayName ?? request.email.split('@').first,
          email: request.email,
          role: 'employee',
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(user.toJson());
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    }
  }

  Future<AppUser> _mockLogin(LoginRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    if (request.email.isEmpty || request.password.length < 6) {
      throw Exception('Invalid credentials');
    }
    final user = AppUser(
      uid: 'mock_uid_001',
      name: 'Vinoth A',
      email: request.email,
      phone: '+91 98765 43210',
      role: request.email.contains('admin') ? 'admin' : 'employee',
      department: 'Technology',
      jobTitle: 'Software Engineer',
      salary: 75000,
      isActive: true,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<void> logout() async {
    if (_firebaseReady) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Sign out error: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('policy');
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
