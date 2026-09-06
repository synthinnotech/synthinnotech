import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: _currentCtrl.text,
            newPassword: _newCtrl.text,
          );
      Snack.success('Password updated');
      Get.back();
    } on AppException catch (e) {
      Snack.error(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: !Db.enabled
          ? const _Unavailable()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _field(_currentCtrl, 'Current password',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null),
                  const SizedBox(height: 14),
                  _field(_newCtrl, 'New password', validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'At least 6 characters';
                    }
                    return null;
                  }),
                  const SizedBox(height: 14),
                  _field(_confirmCtrl, 'Confirm new password', validator: (v) {
                    if (v != _newCtrl.text) return 'Passwords don\'t match';
                    return null;
                  }),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text('Update password',
                              style: GoogleFonts.inter(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      obscureText: _obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Password management is available once Firebase is configured.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ),
    );
  }
}
