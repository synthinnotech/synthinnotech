import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:synthinnotech/view/add_transaction_screen.dart';
import 'package:synthinnotech/view_model/finance_view_model.dart';
import 'package:synthinnotech/widget/common/app_empty_state.dart';
import 'package:synthinnotech/widget/common/app_loading.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final fmt = NumberFormat('#,##0', 'en_IN');

    return Scaffold(
      appBar: AppBar(
        title: Text('Finance',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => Get.to(
              () => const AddTransactionScreen(),
              transition: Transition.downToUp,
            ),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 65),
        child: FloatingActionButton.extended(
          onPressed: () => Get.to(
            () => const AddTransactionScreen(),
            transition: Transition.downToUp,
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text('Add', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ),
      body: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: AppLoadingList(count: 5),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(financeViewModelProvider.notifier).load(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 450),
                      child: _SummaryCard(state: state, fmt: fmt),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 400),
                      child: _ChartCard(state: state),
                    ),
                    const SizedBox(height: 20),
                    _FilterRow(
                      selected: state.filter,
                      onSelect: (f) =>
                          ref.read(financeViewModelProvider.notifier).setFilter(f),
                    ),
                    const SizedBox(height: 12),
                    if (state.filtered.isEmpty)
                      const AppEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Transactions',
                        subtitle: 'Add your first transaction',
                      )
                    else
                      ...state.filtered.asMap().entries.map(
                            (e) => FadeInLeft(
                              delay: Duration(milliseconds: e.key * 50),
                              duration: const Duration(milliseconds: 300),
                              child: _TransactionCard(tx: e.value),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final FinanceState state;
  final NumberFormat fmt;
  const _SummaryCard({required this.state, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isProfit = state.netBalance >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isProfit
              ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
              : [const Color(0xFFC62828), const Color(0xFFF44336)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isProfit
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336))
                .withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NET BALANCE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${isProfit ? '+' : '-'}₹${fmt.format(state.netBalance.abs())}',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _FinanceTile(
                  label: 'Total Income',
                  value: '₹${fmt.format(state.totalIncome)}',
                  icon: Icons.arrow_downward_rounded,
                  color: Colors.greenAccent.shade100,
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                  margin: const EdgeInsets.symmetric(horizontal: 12)),
              Expanded(
                child: _FinanceTile(
                  label: 'Total Expense',
                  value: '₹${fmt.format(state.totalExpense)}',
                  icon: Icons.arrow_upward_rounded,
                  color: Colors.redAccent.shade100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinanceTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _FinanceTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final FinanceState state;
  const _ChartCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (state.totalIncome == 0 && state.totalExpense == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: colorScheme.onSurface.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 36,
                sections: [
                  PieChartSectionData(
                    value: state.totalIncome,
                    color: const Color(0xFF4CAF50),
                    radius: 36,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: state.totalExpense,
                    color: const Color(0xFFF44336),
                    radius: 36,
                    title: '',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                const SizedBox(height: 16),
                _Legend(color: const Color(0xFF4CAF50), label: 'Income',
                    percent: state.totalIncome + state.totalExpense > 0
                        ? (state.totalIncome /
                                (state.totalIncome + state.totalExpense) *
                                100)
                            .toStringAsFixed(0)
                        : '0'),
                const SizedBox(height: 8),
                _Legend(color: const Color(0xFFF44336), label: 'Expenses',
                    percent: state.totalIncome + state.totalExpense > 0
                        ? (state.totalExpense /
                                (state.totalIncome + state.totalExpense) *
                                100)
                            .toStringAsFixed(0)
                        : '0'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label, percent;
  const _Legend({required this.color, required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
        const Spacer(),
        Text('$percent%',
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String selected;
  final Function(String) onSelect;
  const _FilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: ['all', 'income', 'expense'].map((f) {
        final isSelected = selected == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withAlpha(30)),
              ),
              child: Text(
                f[0].toUpperCase() + f.substring(1),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TransactionCard extends ConsumerWidget {
  final Expense tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = tx.type == TransactionType.income;
    final color =
        isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final fmt = NumberFormat('#,##0.00', 'en_IN');

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(financeViewModelProvider.notifier).deleteTransaction(tx.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withAlpha(15)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface)),
                  Text(tx.category,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha(130))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}₹${fmt.format(tx.amount)}',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700, color: color),
                ),
                Text(
                  _date(tx.date),
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colorScheme.onSurface.withAlpha(110)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime d) {
    final m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}';
  }
}
