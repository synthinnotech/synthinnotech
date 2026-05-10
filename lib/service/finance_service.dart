import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:uuid/uuid.dart';

class FinanceService {
  static bool get _ready => Firebase.apps.isNotEmpty;
  static const _col = 'transactions';

  static Future<List<Expense>> getTransactions() async {
    if (_ready) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(_col)
            .orderBy('date', descending: true)
            .get();
        return snap.docs
            .map((d) => Expense.fromJson(d.data(), d.id))
            .toList();
      } catch (_) {}
    }
    return _mockTransactions();
  }

  static Future<Expense> addTransaction(Expense tx) async {
    final id = tx.id.isEmpty ? const Uuid().v4() : tx.id;
    final data = {...tx.toJson(), 'created_at': DateTime.now().toIso8601String()};
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).set(data);
      } catch (_) {}
    }
    return Expense.fromJson(data, id);
  }

  static Future<void> updateTransaction(Expense tx) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance
            .collection(_col)
            .doc(tx.id)
            .update(tx.toJson());
      } catch (_) {}
    }
  }

  static Future<void> deleteTransaction(String id) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).delete();
      } catch (_) {}
    }
  }

  static List<Expense> _mockTransactions() => [
        Expense(
          id: 't1',
          title: 'Client Payment - TechCorp',
          amount: 25000,
          category: 'Project Revenue',
          date: DateTime.now().subtract(const Duration(days: 1)),
          type: TransactionType.income,
        ),
        Expense(
          id: 't2',
          title: 'Office Rent',
          amount: 8500,
          category: 'Rent',
          date: DateTime.now().subtract(const Duration(days: 3)),
          type: TransactionType.expense,
        ),
        Expense(
          id: 't3',
          title: 'Project Payment - RetailMax',
          amount: 18000,
          category: 'Project Revenue',
          date: DateTime.now().subtract(const Duration(days: 5)),
          type: TransactionType.income,
        ),
        Expense(
          id: 't4',
          title: 'Software Subscriptions',
          amount: 1200,
          category: 'Software',
          date: DateTime.now().subtract(const Duration(days: 7)),
          type: TransactionType.expense,
        ),
        Expense(
          id: 't5',
          title: 'Team Salaries',
          amount: 45000,
          category: 'Payroll',
          date: DateTime.now().subtract(const Duration(days: 8)),
          type: TransactionType.expense,
        ),
        Expense(
          id: 't6',
          title: 'Consulting Fee',
          amount: 5500,
          category: 'Consulting',
          date: DateTime.now().subtract(const Duration(days: 10)),
          type: TransactionType.income,
        ),
        Expense(
          id: 't7',
          title: 'Office Supplies',
          amount: 650,
          category: 'Office',
          date: DateTime.now().subtract(const Duration(days: 12)),
          type: TransactionType.expense,
        ),
        Expense(
          id: 't8',
          title: 'New Project Advance',
          amount: 12000,
          category: 'Project Revenue',
          date: DateTime.now().subtract(const Duration(days: 14)),
          type: TransactionType.income,
        ),
        Expense(
          id: 't9',
          title: 'Marketing & Ads',
          amount: 3500,
          category: 'Marketing',
          date: DateTime.now().subtract(const Duration(days: 16)),
          type: TransactionType.expense,
        ),
        Expense(
          id: 't10',
          title: 'Client Payment - StartupXYZ',
          amount: 9000,
          category: 'Project Revenue',
          date: DateTime.now().subtract(const Duration(days: 18)),
          type: TransactionType.income,
        ),
      ];
}
