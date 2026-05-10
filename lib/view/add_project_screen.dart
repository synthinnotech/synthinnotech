import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:synthinnotech/view_model/project_view_model.dart';

class AddProjectScreen extends ConsumerStatefulWidget {
  const AddProjectScreen({super.key});

  @override
  ConsumerState<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends ConsumerState<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  ProjectStatus _status = ProjectStatus.available;
  DateTime? _deadline;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _clientCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Project',
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
            _SectionLabel('Project Info'),
            const SizedBox(height: 12),
            _Field(
              controller: _nameCtrl,
              label: 'Project Name',
              icon: Icons.folder_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _descCtrl,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _clientCtrl,
              label: 'Client Name',
              icon: Icons.business_outlined,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Budget & Status'),
            const SizedBox(height: 12),
            _Field(
              controller: _budgetCtrl,
              label: 'Budget (₹)',
              icon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _StatusDropdown(
              value: _status,
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Deadline'),
            const SizedBox(height: 12),
            _DeadlinePicker(
              value: _deadline,
              onPick: () => _pickDeadline(context),
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
                    : Text('Create Project',
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

  Future<void> _pickDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final project = Project(
      id: '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      clientName: _clientCtrl.text.trim(),
      status: _status,
      budget: double.tryParse(_budgetCtrl.text.trim()) ?? 0,
      deadline: _deadline,
      createdAt: DateTime.now(),
    );

    await ref.read(projectsViewModelProvider.notifier).addProject(project);
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

class _StatusDropdown extends StatelessWidget {
  final ProjectStatus value;
  final ValueChanged<ProjectStatus?> onChanged;

  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statuses = [
      ProjectStatus.available,
      ProjectStatus.inProgress,
      ProjectStatus.review,
      ProjectStatus.pending,
    ];

    return DropdownButtonFormField<ProjectStatus>(
      value: value,
      onChanged: onChanged,
      style: GoogleFonts.inter(
          fontSize: 15, color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: GoogleFonts.inter(fontSize: 14),
        prefixIcon:
            Icon(Icons.flag_outlined, size: 20, color: colorScheme.primary),
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
      items: statuses
          .map((s) => DropdownMenuItem(
                value: s,
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: s.color, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(s.label, style: GoogleFonts.inter(fontSize: 14)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _DeadlinePicker extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onPick;

  const _DeadlinePicker({required this.value, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
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
            Icon(Icons.calendar_today_outlined,
                size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              value == null
                  ? 'Select Deadline (optional)'
                  : '${months[value!.month - 1]} ${value!.day}, ${value!.year}',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  color: value == null
                      ? colorScheme.onSurface.withAlpha(100)
                      : colorScheme.onSurface),
            ),
            const Spacer(),
            Icon(Icons.chevron_right,
                color: colorScheme.onSurface.withAlpha(80)),
          ],
        ),
      ),
    );
  }
}
