import 'package:synthinnotech/model/home/expense.dart';
import 'package:synthinnotech/model/home/project.dart';

class DashboardStats {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final int totalProjects;
  final int activeProjects;
  final int completedProjects;
  final int totalEmployees;
  final double pendingExpenses;
  final int unreadMessages;
  final int overdueTasks;
  final List<Project> recentProjects;
  final List<Expense> recentTransactions;

  DashboardStats({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.netBalance = 0,
    this.totalProjects = 0,
    this.activeProjects = 0,
    this.completedProjects = 0,
    this.totalEmployees = 0,
    this.pendingExpenses = 0,
    this.unreadMessages = 0,
    this.overdueTasks = 0,
    this.recentProjects = const [],
    this.recentTransactions = const [],
  });

  double get profit => totalIncome - totalExpense;
}
