import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:synthinnotech/view_model/project_view_model.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  final Project project;
  const EditProjectScreen({super.key, required this.project});

  @override
  ConsumerState<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _clientCtrl;
  late final TextEditingController _budgetCtrl;
  late ProjectStatus _status;
  DateTime? _startDate;
  DateTime? _deadline;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.project.name);
    _descCtrl = TextEditingController(text: widget.project.description);
    _clientCtrl = TextEditingController(text: widget.project.clientName);
    _budgetCtrl = TextEditingController(
      text: widget.project.budget > 0
          ? widget.project.budget.toStringAsFixed(0)
          : '',
    );
    _status = widget.project.status;
    _startDate = widget.project.startDate;
    _deadline = widget.project.deadline;
  }

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
        title: Text('Edit Project',
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
            _SectionLabel('Timeline'),
            const SizedBox(height: 12),
            _DeadlinePicker(
              placeholder: 'Select Start Date (optional)',
              value: _startDate,
              onPick: () => _pickStartDate(context),
              onClear: _startDate != null
                  ? () => setState(() => _startDate = null)
                  : null,
            ),
            const SizedBox(height: 12),
            _DeadlinePicker(
              placeholder: 'Select Deadline (optional)',
              value: _deadline,
              onPick: () => _pickDeadline(context),
              onClear: _deadline != null
                  ? () => setState(() => _deadline = null)
                  : null,
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

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updated = Project(
      id: widget.project.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      clientName: _clientCtrl.text.trim(),
      status: _status,
      progress: widget.project.progress,
      budget: double.tryParse(_budgetCtrl.text.trim()) ?? 0,
      spent: widget.project.spent,
      startDate: _startDate,
      deadline: _deadline,
      teamMemberIds: widget.project.teamMemberIds,
      createdBy: widget.project.createdBy,
      createdAt: widget.project.createdAt,
    );

    await ref.read(projectsViewModelProvider.notifier).updateProject(updated);
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
    const statuses = [
      ProjectStatus.available,
      ProjectStatus.inProgress,
      ProjectStatus.review,
      ProjectStatus.pending,
      ProjectStatus.onTrack,
      ProjectStatus.delayed,
      ProjectStatus.done,
      ProjectStatus.completed,
      ProjectStatus.cancelled,
    ];

    return DropdownButtonFormField<ProjectStatus>(
      value: statuses.contains(value) ? value : ProjectStatus.available,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 15, color: colorScheme.onSurface),
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
  final String placeholder;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _DeadlinePicker({
    required this.placeholder,
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
            Icon(Icons.calendar_today_outlined,
                size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value == null
                    ? placeholder
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
                child:
                    Icon(Icons.close, size: 18, color: colorScheme.onSurface.withAlpha(120)),
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
