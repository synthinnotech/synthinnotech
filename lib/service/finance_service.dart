import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/demo/demo_data.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:uuid/uuid.dart';

class FinanceService {
  static const _uuid = Uuid();

  static Future<List<Expense>> getTransactions() async {
    if (!Db.enabled) return DemoData.transactions();
    return Db.guard(() async {
      final snap = await Db.transactions.get();
      final list =
          snap.docs.map((d) => Expense.fromJson(d.data(), d.id)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  static Stream<List<Expense>> watchTransactions() {
    if (!Db.enabled) return Stream.value(DemoData.transactions());
    return Db.guardStream(
      Db.transactions.snapshots().map((s) {
        final list =
            s.docs.map((d) => Expense.fromJson(d.data(), d.id)).toList();
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      }),
    );
  }

  static Future<Expense> addTransaction(Expense tx) async {
    final id = tx.id.isEmpty ? _uuid.v4() : tx.id;
    if (!Db.enabled) return Expense.fromJson(tx.toJson(), id);
    return Db.guard(() async {
      await Db.transactions.doc(id).set({
        ...tx.toJson(),
        'created_at': Db.now,
        'created_by': Db.uid,
      });
      final saved = await Db.transactions.doc(id).get();
      return Expense.fromJson(saved.data() ?? tx.toJson(), id);
    });
  }

  static Future<void> updateTransaction(Expense tx) async {
    if (!Db.enabled) return;
    return Db.guard(() async {
      await Db.transactions.doc(tx.id).set(
            {...tx.toJson(), 'updated_at': Db.now},
            SetOptions(merge: true),
          );
    });
  }

  static Future<void> deleteTransaction(String id) async {
    if (!Db.enabled) return;
    return Db.guard(() => Db.transactions.doc(id).delete());
  }
}
