import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/model/home/dashboard_stats.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:synthinnotech/service/employee_service.dart';
import 'package:synthinnotech/service/finance_service.dart';
import 'package:synthinnotech/service/project_service.dart';

class HomeViewModel extends StateNotifier<AsyncValue<DashboardStats>> {
  HomeViewModel() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ProjectService.getProjects(),
        FinanceService.getTransactions(),
        EmployeeService.getEmployees(),
      ]);

      final projects = results[0] as List<Project>;
      final transactions = results[1] as List<Expense>;
      final employees = results[2];

      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (s, t) => s + t.amount);
      final expense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (s, t) => s + t.amount);

      final active = projects
          .where((p) =>
              p.status == ProjectStatus.inProgress ||
              p.status == ProjectStatus.onTrack ||
              p.status == ProjectStatus.review)
          .length;
      final completed = projects
          .where((p) =>
              p.status == ProjectStatus.done ||
              p.status == ProjectStatus.completed)
          .length;

      final overdue = projects
          .where((p) =>
              p.deadline != null &&
              p.deadline!.isBefore(DateTime.now()) &&
              p.status != ProjectStatus.done &&
              p.status != ProjectStatus.completed)
          .length;

      final pendingBudget = projects.fold<double>(
          0, (s, p) => s + (p.budget - p.spent).clamp(0, double.infinity));

      state = AsyncValue.data(DashboardStats(
        totalIncome: income,
        totalExpense: expense,
        netBalance: income - expense,
        totalProjects: projects.length,
        activeProjects: active,
        completedProjects: completed,
        totalEmployees: employees.length,
        pendingExpenses: pendingBudget,
        unreadMessages: 0,
        overdueTasks: overdue,
        recentProjects: projects.take(3).toList(),
        recentTransactions: transactions.take(5).toList(),
      ));
    } on AppException catch (error, st) {
      state = AsyncValue.error(error, st);
    } catch (error, st) {
      state = AsyncValue.error(AppException.from(error, st), st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, AsyncValue<DashboardStats>>(
  (ref) => HomeViewModel(),
);
