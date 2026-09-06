import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/rbac/app_role.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/service/notification_center.dart';
import 'package:synthinnotech/view_model/employee_view_model.dart';

/// Admin-only: create a real sign-in account for a new team member.
/// Uses a throw-away secondary Firebase app so the admin stays signed in.
class RegisterStaffScreen extends ConsumerStatefulWidget {
  const RegisterStaffScreen({super.key});

  @override
  ConsumerState<RegisterStaffScreen> createState() =>
      _RegisterStaffScreenState();
}

class _RegisterStaffScreenState extends ConsumerState<RegisterStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _department = TextEditingController();
  final _jobTitle = TextEditingController();
  final _salary = TextEditingController();
  AppRole _role = AppRole.employee;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _password,
      _phone,
      _department,
      _jobTitle,
      _salary
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final profile = <String, dynamic>{
        'name': _name.text.trim(),
        'role': _role.wire,
        'phone': _phone.text.trim(),
        'department':
            _department.text.trim().isEmpty ? null : _department.text.trim(),
        'job_title':
            _jobTitle.text.trim().isEmpty ? null : _jobTitle.text.trim(),
        'salary': double.tryParse(_salary.text.trim()) ?? 0,
        'is_active': true,
      };
      await ref.read(authRepositoryProvider).createStaffAccount(
            email: _email.text.trim(),
            tempPassword: _password.text,
            profile: profile,
          );
      await ref.read(employeesViewModelProvider.notifier).load();
      NotificationCenter.broadcast(
        title: 'New Team Member',
        body: '${_name.text.trim()} joined as ${_role.label}',
        type: 'employee',
      );
      Snack.success('${_name.text.trim()}\'s account created');
      Get.back();
    } on AppException catch (e) {
      Snack.error(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('New Team Member',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This creates a login. Share the temporary password with '
                      'them — they can change it from Settings.',
                      style: GoogleFonts.inter(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _field(_name, 'Full name', Icons.person_outline,
                validator: _required),
            const SizedBox(height: 14),
            _field(_email, 'Work email', Icons.alternate_email,
                keyboard: TextInputType.emailAddress, validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            }),
            const SizedBox(height: 14),
            _field(_password, 'Temporary password', Icons.key_outlined,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'At least 6 characters' : null),
            const SizedBox(height: 14),
            DropdownButtonFormField<AppRole>(
              initialValue: _role,
              decoration: InputDecoration(
                labelText: 'Role',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: AppRole.values
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Row(children: [
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: r.color, shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                          Text(r.label),
                        ]),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _role = v ?? AppRole.employee),
            ),
            const SizedBox(height: 14),
            _field(_phone, 'Phone (optional)', Icons.phone_outlined,
                keyboard: TextInputType.phone),
            const SizedBox(height: 14),
            _field(_department, 'Department (optional)', Icons.business_outlined),
            const SizedBox(height: 14),
            _field(_jobTitle, 'Job title (optional)', Icons.work_outline),
            const SizedBox(height: 14),
            _field(_salary, 'Monthly salary ₹ (optional)', Icons.currency_rupee,
                keyboard: TextInputType.number),
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
                    : Text('Create account',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboard, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
