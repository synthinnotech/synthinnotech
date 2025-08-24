import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/service/theme_service.dart';
import 'package:synthinnotech/view/home_page.dart';
import 'package:synthinnotech/view_model/login_view_model.dart';
import 'package:synthinnotech/widget/login/custom_text_field.dart';
import 'package:synthinnotech/widget/login/login_error_widget.dart';
import 'package:synthinnotech/widget/simple_badge.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final loginViewModel = ref.read(loginViewModelProvider.notifier);
    bool isDark = ref.watch(ThemeService.isDarkTheme);

    ref.listen(loginViewModelProvider, (previous, next) {
      if (next.isLoggedIn) {
        Get.offAll(() => HomePage(), transition: Transition.zoom);
      }
    });

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
                  SizedBox(height: 15),
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
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
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  AssetImage('assets/images/logo.png'),
                            ),
                          ),
                        );
                      },
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
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Theme.of(context)
                                .scaffoldBackgroundColor
                                .withAlpha(100)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: baseColor2.withAlpha(65), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: baseColor1.withAlpha(50),
                            blurRadius: 30,
                            spreadRadius: 0,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 5),
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
                              onChanged: (_) => loginViewModel.clearError(),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.key,
                              isPassword: true,
                              isPasswordVisible: loginState.isPasswordVisible,
                              onTogglePassword: () =>
                                  loginViewModel.togglePasswordVisibility(),
                              onChanged: (_) => loginViewModel.clearError(),
                            ),
                            if (loginState.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              FadeIn(
                                child: LoginErrorWidget(
                                    message: loginState.errorMessage!),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.inter(
                                      color: baseColor1,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: loginState.isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          loginViewModel.login(
                                            _emailController.text.trim(),
                                            _passwordController.text,
                                          );
                                        }
                                      },
                                child: btn(loginState.isLoading),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SimpleBadge(
                                icon: Icons.shield_outlined, label: 'Secure'),
                            const SizedBox(width: 20),
                            SimpleBadge(icon: Icons.speed, label: 'Fast'),
                            const SizedBox(width: 20),
                            SimpleBadge(
                                icon: Icons.verified_user, label: 'Trusted'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '© 2024 SynthInnoTech. All rights reserved.',
                          style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
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

  Widget btn(isLoading) => Container(
        alignment: Alignment.center,
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Authenticating...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Sign In Securely',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      );
}
