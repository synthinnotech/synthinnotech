import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/demo/demo_data.dart';
import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:uuid/uuid.dart';

/// Reads/writes the staff directory (`users` collection).
///
/// Behaviour change from the original: failures are no longer swallowed. When
/// Firebase is configured, a Firestore error propagates as an [AppException]
/// so the UI can show it. Demo data is returned *only* when Firebase itself
/// is not initialised.
class EmployeeService {
  static const _uuid = Uuid();

  static Future<List<EmployeeModel>> getEmployees() async {
    if (!Db.enabled) return DemoData.employees();
    return Db.guard(() async {
      final snap = await Db.users.orderBy('name').get();
      return snap.docs
          .map((d) => EmployeeModel.fromJson(d.data(), d.id))
          .toList();
    });
  }

  /// Live directory updates.
  static Stream<List<EmployeeModel>> watchEmployees() {
    if (!Db.enabled) return Stream.value(DemoData.employees());
    return Db.guardStream(
      Db.users.orderBy('name').snapshots().map(
            (s) => s.docs
                .map((d) => EmployeeModel.fromJson(d.data(), d.id))
                .toList(),
          ),
    );
  }

  static Future<EmployeeModel> addEmployee(EmployeeModel emp) async {
    final id = emp.id.isEmpty ? _uuid.v4() : emp.id;
    if (!Db.enabled) {
      return EmployeeModel.fromJson(emp.toJson(), id);
    }
    return Db.guard(() async {
      await Db.users.doc(id).set(
            {...emp.toJson(), 'created_at': Db.now},
            SetOptions(merge: true),
          );
      final saved = await Db.users.doc(id).get();
      return EmployeeModel.fromJson(saved.data() ?? emp.toJson(), id);
    });
  }

  static Future<void> updateEmployee(EmployeeModel emp) async {
    if (!Db.enabled) return;
    return Db.guard(() async {
      await Db.users.doc(emp.id).set(
            {...emp.toJson(), 'updated_at': Db.now},
            SetOptions(merge: true),
          );
    });
  }

  static Future<void> deleteEmployee(String id) async {
    if (!Db.enabled) return;
    return Db.guard(() => Db.users.doc(id).delete());
  }
}
