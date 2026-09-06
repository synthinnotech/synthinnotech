import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:synthinnotech/service/finance_service.dart';

/// Lightweight read-only feed of recent transactions for the dashboard.
/// Writes go through [FinanceViewModel]; this just mirrors the latest data.
class ExpensesViewModel extends StateNotifier<List<Expense>> {
  ExpensesViewModel() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = await FinanceService.getTransactions();
    } catch (_) {
      // Dashboard tile — a failure here is already surfaced by the finance
      // screen, so stay quiet and just show nothing.
    }
  }

  Future<void> refresh() => _load();
}

final expensesViewModelProvider =
    StateNotifierProvider<ExpensesViewModel, List<Expense>>(
  (ref) => ExpensesViewModel(),
);
