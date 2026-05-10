import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:synthinnotech/view_model/finance_view_model.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TransactionType _type = TransactionType.income;
  String _category = 'General';
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  static const _incomeCategories = [
    'General', 'Client Payment', 'Project Revenue', 'Investment', 'Refund', 'Other'
  ];

  static const _expenseCategories = [
    'General', 'Salary', 'Infrastructure', 'Marketing', 'Office', 'Travel', 'Tools', 'Other'
  ];

  List<String> get _categories =>
      _type == TransactionType.income ? _incomeCategories : _expenseCategories;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == TransactionType.income;
    final typeColor = isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction',
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
            _TypeToggle(
              value: _type,
              onChanged: (t) => setState(() {
                _type = t;
                _category = _categories.first;
              }),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Transaction Details'),
            const SizedBox(height: 12),
            _Field(
              controller: _titleCtrl,
              label: 'Title',
              icon: Icons.title,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _amountCtrl,
              label: 'Amount (₹)',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Enter valid amount';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _CategoryDropdown(
              value: _category,
              items: _categories,
              onChanged: (v) => setState(() => _category = v!),
              typeColor: typeColor,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _descCtrl,
              label: 'Note (optional)',
              icon: Icons.note_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Date'),
            const SizedBox(height: 12),
            _DatePicker(
              value: _date,
              onPick: () => _pickDate(context),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Text(
                        'Add ${isIncome ? 'Income' : 'Expense'}',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final expense = Expense(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _category,
      date: _date,
      type: _type,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );

    await ref.read(financeViewModelProvider.notifier).addTransaction(expense);
    setState(() => _isSaving = false);
    Get.back();
  }
}

class _TypeToggle extends StatelessWidget {
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Tab(
            label: 'Income',
            icon: Icons.arrow_downward_rounded,
            selected: value == TransactionType.income,
            color: const Color(0xFF4CAF50),
            onTap: () => onChanged(TransactionType.income),
          ),
          _Tab(
            label: 'Expense',
            icon: Icons.arrow_upward_rounded,
            selected: value == TransactionType.expense,
            color: const Color(0xFFF44336),
            onTap: () => onChanged(TransactionType.expense),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color typeColor;

  const _CategoryDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 15, color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: GoogleFonts.inter(fontSize: 14),
        prefixIcon:
            Icon(Icons.category_outlined, size: 20, color: typeColor),
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
      items: items
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: GoogleFonts.inter(fontSize: 14)),
              ))
          .toList(),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime value;
  final VoidCallback onPick;

  const _DatePicker({required this.value, required this.onPick});

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
              '${months[value.month - 1]} ${value.day}, ${value.year}',
              style: GoogleFonts.inter(fontSize: 15, color: colorScheme.onSurface),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: colorScheme.onSurface.withAlpha(80)),
          ],
        ),
      ),
    );
  }
}
