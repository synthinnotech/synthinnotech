import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:synthinnotech/service/finance_service.dart';
import 'package:synthinnotech/service/notification_center.dart';

class FinanceState {
  final bool isLoading;
  final List<Expense> transactions;
  final String? error;
  final String filter; // 'all', 'income', 'expense'

  const FinanceState({
    this.isLoading = false,
    this.transactions = const [],
    this.error,
    this.filter = 'all',
  });

  FinanceState copyWith({
    bool? isLoading,
    List<Expense>? transactions,
    Object? error = _sentinel,
    String? filter,
  }) =>
      FinanceState(
        isLoading: isLoading ?? this.isLoading,
        transactions: transactions ?? this.transactions,
        error: identical(error, _sentinel) ? this.error : error as String?,
        filter: filter ?? this.filter,
      );

  static const _sentinel = Object();

  List<Expense> get filtered {
    if (filter == 'income') {
      return transactions
          .where((t) => t.type == TransactionType.income)
          .toList();
    } else if (filter == 'expense') {
      return transactions
          .where((t) => t.type == TransactionType.expense)
          .toList();
    }
    return transactions;
  }

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get netBalance => totalIncome - totalExpense;
}

class FinanceViewModel extends StateNotifier<FinanceState> {
  FinanceViewModel() : super(const FinanceState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final txns = await FinanceService.getTransactions();
      state = state.copyWith(isLoading: false, transactions: txns);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) => state = state.copyWith(filter: filter);

  Future<bool> addTransaction(Expense tx) async {
    try {
      final created = await FinanceService.addTransaction(tx);
      state = state.copyWith(transactions: [created, ...state.transactions]);
      final isIncome = tx.type == TransactionType.income;
      NotificationCenter.push(
        title: isIncome ? 'Income Added' : 'Expense Recorded',
        body: '${_fmt(tx.amount)} — ${tx.title}',
        type: 'finance',
      );
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    // Optimistic remove with rollback so a Dismissible can't leave the UI and
    // the database out of sync.
    final previous = state.transactions;
    state = state.copyWith(
        transactions: previous.where((t) => t.id != id).toList());
    try {
      await FinanceService.deleteTransaction(id);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(transactions: previous);
      Snack.error(e);
      return false;
    }
  }

  static String _fmt(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹${v.toStringAsFixed(0)}';
  }
}

final financeViewModelProvider =
    StateNotifierProvider<FinanceViewModel, FinanceState>(
  (ref) => FinanceViewModel(),
);
