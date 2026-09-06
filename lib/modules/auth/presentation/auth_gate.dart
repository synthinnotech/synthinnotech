import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/auth/presentation/sign_in_screen.dart';
import 'package:synthinnotech/view/initial_page.dart';
import 'package:synthinnotech/view/main_navigation_screen.dart';

/// The single routing brain of the app. Replaces the old SplashScreen that
/// hand-rolled routing from a SharedPreferences JSON blob. Reacts live to
/// `FirebaseAuth` state.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _minSplashDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _minSplashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);
    final policy = ref.watch(policyAcceptedProvider);

    final resolving = authUser.isLoading || policy.isLoading || !_minSplashDone;
    if (resolving) return const _SplashView();

    // Auth errors (rare) — fall through to sign-in rather than trapping the
    // user on a spinner.
    final user = authUser.valueOrNull;
    if (user != null) {
      return const MainNavigationScreen();
    }

    final accepted = policy.valueOrNull ?? false;
    return accepted ? const SignInScreen() : const InitialPage();
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9FB),
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/images/reveal.gif',
            errorBuilder: (_, __, ___) => const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
