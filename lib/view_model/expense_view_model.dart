import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/home/expense.dart';

class ExpensesViewModel extends StateNotifier<List<Expense>> {
  ExpensesViewModel() : super([]) {
    _loadRecentExpenses();
  }

  void _loadRecentExpenses() {
    state = [
      Expense(
        id: '1',
        title: 'Office Supplies',
        amount: 156.50,
        category: 'Office',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Expense(
        id: '2',
        title: 'Client Lunch',
        amount: 89.25,
        category: 'Meals',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  void addExpense(Expense expense) {
    state = [expense, ...state];
  }
}

final expensesViewModelProvider =
    StateNotifierProvider<ExpensesViewModel, List<Expense>>(
  (ref) => ExpensesViewModel(),
);
