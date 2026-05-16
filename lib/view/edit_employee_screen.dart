import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:synthinnotech/view_model/employee_view_model.dart';

class EditEmployeeScreen extends ConsumerStatefulWidget {
  final EmployeeModel employee;
  const EditEmployeeScreen({super.key, required this.employee});

  @override
  ConsumerState<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends ConsumerState<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _departmentCtrl;
  late final TextEditingController _jobTitleCtrl;
  late final TextEditingController _salaryCtrl;
  late final TextEditingController _addressCtrl;
  late EmployeeRole _role;
  late bool _isActive;
  String? _gender;
  DateTime? _dateOfBirth;
  DateTime? _joinDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.employee.name);
    _emailCtrl = TextEditingController(text: widget.employee.email);
    _phoneCtrl = TextEditingController(text: widget.employee.phone);
    _addressCtrl =
        TextEditingController(text: widget.employee.address ?? '');
    _departmentCtrl =
        TextEditingController(text: widget.employee.department ?? '');
    _jobTitleCtrl =
        TextEditingController(text: widget.employee.jobTitle ?? '');
    _salaryCtrl = TextEditingController(
      text: widget.employee.salary > 0
          ? widget.employee.salary.toStringAsFixed(0)
          : '',
    );
    _role = widget.employee.role;
    _isActive = widget.employee.isActive;
    _gender = widget.employee.gender;
    _dateOfBirth = widget.employee.dateOfBirth;
    _joinDate = widget.employee.joinDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _departmentCtrl.dispose();
    _jobTitleCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            _SectionLabel('Personal Info'),
            const SizedBox(height: 12),
            _Field(
              controller: _nameCtrl,
              label: 'Full Name',
              icon: Icons.person_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.contains('@')) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _phoneCtrl,
              label: 'Phone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _GenderDropdown(
              value: _gender,
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 14),
            _DatePickerTile(
              label: 'Date of Birth',
              value: _dateOfBirth,
              onPick: () => _pickDateOfBirth(context),
              onClear: _dateOfBirth != null
                  ? () => setState(() => _dateOfBirth = null)
                  : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _addressCtrl,
              label: 'Address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Work Info'),
            const SizedBox(height: 12),
            _RoleDropdown(
              value: _role,
              onChanged: (v) => setState(() => _role = v!),
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _departmentCtrl,
              label: 'Department',
              icon: Icons.business_outlined,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _jobTitleCtrl,
              label: 'Job Title',
              icon: Icons.work_outlined,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _salaryCtrl,
              label: 'Salary (₹ per month)',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _DatePickerTile(
              label: 'Joining Date',
              value: _joinDate,
              onPick: () => _pickJoinDate(context),
              onClear: _joinDate != null
                  ? () => setState(() => _joinDate = null)
                  : null,
            ),
            const SizedBox(height: 20),
            _ActiveToggle(
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Text('Save Changes',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _pickJoinDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _joinDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updated = EmployeeModel(
      id: widget.employee.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _role,
      department: _departmentCtrl.text.trim().isEmpty
          ? null
          : _departmentCtrl.text.trim(),
      jobTitle: _jobTitleCtrl.text.trim().isEmpty
          ? null
          : _jobTitleCtrl.text.trim(),
      salary: double.tryParse(_salaryCtrl.text.trim()) ?? 0,
      profileImageUrl: widget.employee.profileImageUrl,
      isActive: _isActive,
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      gender: _gender,
      dateOfBirth: _dateOfBirth,
      joinDate: _joinDate,
      createdAt: widget.employee.createdAt,
    );

    await ref.read(employeesViewModelProvider.notifier).updateEmployee(updated);
    setState(() => _isSaving = false);
    Get.back();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
            letterSpacing: 0.5));
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final EmployeeRole value;
  final ValueChanged<EmployeeRole?> onChanged;

  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<EmployeeRole>(
      value: value,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 15, color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Role',
        labelStyle: GoogleFonts.inter(fontSize: 14),
        prefixIcon:
            Icon(Icons.badge_outlined, size: 20, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: EmployeeRole.values
          .map((r) => DropdownMenuItem(
                value: r,
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: r.color, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(r.label, style: GoogleFonts.inter(fontSize: 14)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _ActiveToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ActiveToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Employee',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface)),
                Text('Currently working at the company',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurface.withAlpha(130))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _GenderDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const options = ['Male', 'Female', 'Other', 'Prefer not to say'];

    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : null,
      hint: Text('Select Gender', style: GoogleFonts.inter(fontSize: 14)),
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 15, color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: GoogleFonts.inter(fontSize: 14),
        prefixIcon:
            Icon(Icons.person_outline, size: 20, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: options
          .map((g) => DropdownMenuItem(
                value: g,
                child: Text(g, style: GoogleFonts.inter(fontSize: 14)),
              ))
          .toList(),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withAlpha(30)),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value == null
                    ? label
                    : '${months[value!.month - 1]} ${value!.day}, ${value!.year}',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    color: value == null
                        ? colorScheme.onSurface.withAlpha(100)
                        : colorScheme.onSurface),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close,
                    size: 18,
                    color: colorScheme.onSurface.withAlpha(120)),
              )
            else
              Icon(Icons.chevron_right,
                  color: colorScheme.onSurface.withAlpha(80)),
          ],
        ),
      ),
    );
  }
}
