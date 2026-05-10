import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synthinnotech/model/user/app_user.dart';
import 'package:synthinnotech/view/initial_page.dart';
import 'package:synthinnotech/view/login_page.dart';
import 'package:synthinnotech/view/main_navigation_screen.dart';
import 'package:synthinnotech/view_model/login_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    final accepted = prefs.getBool('policy') ?? false;

    if (userStr != null) {
      try {
        final user = AppUser.fromJson(jsonDecode(userStr));
        ref.read(loginViewModelProvider.notifier).loadUser(user);
        Get.offAll(() => const MainNavigationScreen());
      } catch (_) {
        Get.offAll(() => const LoginPage());
      }
    } else if (accepted) {
      Get.offAll(() => const LoginPage());
    } else {
      Get.offAll(() => const InitialPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9FB),
      body: SafeArea(
        child: Center(
          child: Image.asset('assets/images/reveal.gif'),
        ),
      ),
    );
  }
}
