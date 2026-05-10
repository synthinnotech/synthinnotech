import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:synthinnotech/service/finance_service.dart';

class ExpensesViewModel extends StateNotifier<List<Expense>> {
  ExpensesViewModel() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final txns = await FinanceService.getTransactions();
      state = txns;
    } catch (_) {}
  }

  void addExpense(Expense expense) {
    state = [expense, ...state];
  }
}

final expensesViewModelProvider =
    StateNotifierProvider<ExpensesViewModel, List<Expense>>(
  (ref) => ExpensesViewModel(),
);
