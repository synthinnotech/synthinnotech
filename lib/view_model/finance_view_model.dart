import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:synthinnotech/service/finance_service.dart';
import 'package:synthinnotech/service/notification_service.dart';

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
    String? error,
    String? filter,
  }) =>
      FinanceState(
        isLoading: isLoading ?? this.isLoading,
        transactions: transactions ?? this.transactions,
        error: error,
        filter: filter ?? this.filter,
      );

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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> addTransaction(Expense tx) async {
    final created = await FinanceService.addTransaction(tx);
    state = state.copyWith(transactions: [created, ...state.transactions]);
    final isIncome = tx.type == TransactionType.income;
    NotificationService.showNotification(
      title: isIncome ? 'Income Added' : 'Expense Recorded',
      body: '${_fmt(tx.amount)} – ${tx.title}',
      channelKey: 'finance_channel',
      withActions: false,
    );
  }

  static String _fmt(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹${v.toStringAsFixed(0)}';
  }

  Future<void> deleteTransaction(String id) async {
    await FinanceService.deleteTransaction(id);
    state = state.copyWith(
        transactions: state.transactions.where((t) => t.id != id).toList());
  }
}

final financeViewModelProvider =
    StateNotifierProvider<FinanceViewModel, FinanceState>(
  (ref) => FinanceViewModel(),
);
