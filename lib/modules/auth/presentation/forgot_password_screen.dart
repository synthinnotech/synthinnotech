import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Snack.error('Enter the email address for your account.');
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      setState(() => _sent = true);
    } on AppException catch (e) {
      Snack.error(e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? _SentView(email: _emailCtrl.text.trim())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_reset, size: 56, color: baseColor1),
                  const SizedBox(height: 16),
                  Text('Forgot your password?',
                      style: GoogleFonts.inter(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your account email and we\'ll send you a secure link '
                    'to choose a new password.',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        color: cs.onSurface.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _send,
                      child: _sending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text('Send reset link',
                              style: GoogleFonts.inter(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SentView extends StatelessWidget {
  const _SentView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_read_outlined,
              size: 72, color: Color(0xFF2E7D32)),
          const SizedBox(height: 16),
          Text('Check your inbox',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'If an account exists for $email, a password reset link is on its '
            'way. It may take a minute to arrive.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }
}
