import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/rbac/app_role.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';

/// Lets the signed-in user edit their own profile. Role / salary / active flag
/// are read-only here (only an admin can change those — enforced by the rules).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _department;
  late final TextEditingController _jobTitle;
  late final TextEditingController _address;
  String? _gender;
  bool _saving = false;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
    _department = TextEditingController();
    _jobTitle = TextEditingController();
    _address = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _department, _jobTitle, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updateMyProfile({
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'department':
            _department.text.trim().isEmpty ? null : _department.text.trim(),
        'job_title':
            _jobTitle.text.trim().isEmpty ? null : _jobTitle.text.trim(),
        'address': _address.text.trim().isEmpty ? null : _address.text.trim(),
        'gender': _gender,
      });
      Snack.success('Profile updated');
      Get.back();
    } on AppException catch (e) {
      Snack.error(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user != null && !_init) {
      _init = true;
      _name.text = user.name;
      _phone.text = user.phone;
      _department.text = user.department ?? '';
      _jobTitle.text = user.jobTitle ?? '';
      _address.text = user.address ?? '';
      _gender = user.gender;
    }
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: user.appRole.color.withValues(alpha: 0.15),
                      child: Text(user.initial,
                          style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: user.appRole.color)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text('${user.email}  ·  ${user.appRole.label}',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.6))),
                  ),
                  const SizedBox(height: 24),
                  _field(_name, 'Full name', Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required'
                          : null),
                  const SizedBox(height: 14),
                  _field(_phone, 'Phone', Icons.phone_outlined,
                      keyboard: TextInputType.phone),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: const ['Male', 'Female', 'Other', 'Prefer not to say']
                            .contains(_gender)
                        ? _gender
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.wc_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const ['Male', 'Female', 'Other', 'Prefer not to say']
                        .map((g) =>
                            DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 14),
                  _field(_jobTitle, 'Job title', Icons.work_outline),
                  const SizedBox(height: 14),
                  _field(_department, 'Department', Icons.business_outlined),
                  const SizedBox(height: 14),
                  _field(_address, 'Address', Icons.location_on_outlined,
                      maxLines: 2),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text('Save changes',
                              style: GoogleFonts.inter(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboard,
      int maxLines = 1,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
