import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/auth/presentation/forgot_password_screen.dart';
import 'package:synthinnotech/service/theme_service.dart';
import 'package:synthinnotech/widget/login/custom_text_field.dart';
import 'package:synthinnotech/widget/login/login_error_widget.dart';
import 'package:synthinnotech/widget/simple_badge.dart';

/// Sign-in screen. Navigation on success is handled centrally by [AuthGate]
/// (which listens to the auth stream) — this screen just submits credentials.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _floatingController;
  late final Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref.read(signInControllerProvider.notifier).submit(
          _emailController.text.trim(),
          _passwordController.text,
        );
    // AuthGate reacts to the auth stream — no manual navigation here.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInControllerProvider);
    final controller = ref.read(signInControllerProvider.notifier);
    final isDark = ref.watch(ThemeService.isDarkTheme);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _floatingAnimation.value),
                        child: child,
                      ),
                      child: Container(
                        width: 85,
                        height: 85,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: baseColor1,
                          border: Border.all(color: baseColor1, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: baseColor1.withAlpha(80),
                              blurRadius: 5,
                              spreadRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/logo.png'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              baseColor1,
                              isDark ? baseColor2 : baseColor3
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'SynthInnoTech',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Synthesizing Innovation in Tech',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.withAlpha(50) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: baseColor2.withAlpha(50),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.login,
                                      color: baseColor1, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Sign In',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? baseColor2 : baseColor3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'Enter your email',
                              icon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) => controller.clearError(),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.key,
                              isPassword: true,
                              isPasswordVisible: state.passwordVisible,
                              onTogglePassword:
                                  controller.togglePasswordVisibility,
                              onChanged: (_) => controller.clearError(),
                            ),
                            if (state.error != null) ...[
                              const SizedBox(height: 16),
                              FadeIn(
                                  child:
                                      LoginErrorWidget(message: state.error!)),
                            ],
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Get.to(
                                  () => const ForgotPasswordScreen(),
                                  transition: Transition.rightToLeft,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.inter(
                                    color: baseColor1,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: state.isSubmitting ? null : _submit,
                                child: _ButtonLabel(loading: state.isSubmitting),
                              ),
                            ),
                            if (!Db.enabled) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Demo mode — Firebase isn\'t configured. '
                                  'Any email + a 6+ char password works. '
                                  'Use an email containing "admin" for admin access.',
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: Colors.brown[700]),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SimpleBadge(
                                icon: Icons.shield_outlined, label: 'Secure'),
                            SizedBox(width: 20),
                            SimpleBadge(icon: Icons.speed, label: 'Fast'),
                            SizedBox(width: 20),
                            SimpleBadge(
                                icon: Icons.verified_user, label: 'Trusted'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '© ${DateTime.now().year} SynthInnoTech. All rights reserved.',
                          style: GoogleFonts.inter(
                              color: Colors.grey[500], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.loading});
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          ),
          const SizedBox(width: 16),
          Text('Authenticating…',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.login, color: Colors.white, size: 22),
        const SizedBox(width: 12),
        Text('Sign In Securely',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5)),
      ],
    );
  }
}
