import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:uuid/uuid.dart';

class EmployeeService {
  static bool get _ready => Firebase.apps.isNotEmpty;
  static const _col = 'users';

  static Future<List<EmployeeModel>> getEmployees() async {
    if (_ready) {
      try {
        final snap =
            await FirebaseFirestore.instance.collection(_col).get();
        return snap.docs
            .map((d) => EmployeeModel.fromJson(d.data(), d.id))
            .toList();
      } catch (_) {}
    }
    return _mockEmployees();
  }

  static Future<EmployeeModel> addEmployee(EmployeeModel emp) async {
    final id = emp.id.isEmpty ? const Uuid().v4() : emp.id;
    final data = {
      ...emp.toJson(),
      'created_at': DateTime.now().toIso8601String()
    };
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).set(data);
      } catch (_) {}
    }
    return EmployeeModel.fromJson(data, id);
  }

  static Future<void> updateEmployee(EmployeeModel emp) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance
            .collection(_col)
            .doc(emp.id)
            .update(emp.toJson());
      } catch (_) {}
    }
  }

  static Future<void> deleteEmployee(String id) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).delete();
      } catch (_) {}
    }
  }

  static List<EmployeeModel> _mockEmployees() => [
        EmployeeModel(
          id: 'e1',
          name: 'Vinoth A',
          email: 'vinoth@synthinnotech.com',
          phone: '+91 98765 43210',
          role: EmployeeRole.admin,
          department: 'Management',
          jobTitle: 'CEO & Founder',
          salary: 150000,
          isActive: true,
          joinDate: DateTime(2022, 1, 1),
        ),
        EmployeeModel(
          id: 'e2',
          name: 'Priya Sharma',
          email: 'priya@synthinnotech.com',
          phone: '+91 98765 43211',
          role: EmployeeRole.manager,
          department: 'Technology',
          jobTitle: 'Tech Lead',
          salary: 95000,
          isActive: true,
          joinDate: DateTime(2022, 3, 15),
        ),
        EmployeeModel(
          id: 'e3',
          name: 'Arjun Kumar',
          email: 'arjun@synthinnotech.com',
          phone: '+91 98765 43212',
          role: EmployeeRole.employee,
          department: 'Technology',
          jobTitle: 'Flutter Developer',
          salary: 70000,
          isActive: true,
          joinDate: DateTime(2022, 6, 1),
        ),
        EmployeeModel(
          id: 'e4',
          name: 'Sneha Patel',
          email: 'sneha@synthinnotech.com',
          phone: '+91 98765 43213',
          role: EmployeeRole.employee,
          department: 'Design',
          jobTitle: 'UI/UX Designer',
          salary: 65000,
          isActive: true,
          joinDate: DateTime(2022, 8, 10),
        ),
        EmployeeModel(
          id: 'e5',
          name: 'Rahul Singh',
          email: 'rahul@synthinnotech.com',
          phone: '+91 98765 43214',
          role: EmployeeRole.admin,
          department: 'Operations',
          jobTitle: 'Operations Manager',
          salary: 85000,
          isActive: true,
          joinDate: DateTime(2022, 2, 20),
        ),
        EmployeeModel(
          id: 'e6',
          name: 'Kavya Reddy',
          email: 'kavya@synthinnotech.com',
          phone: '+91 98765 43215',
          role: EmployeeRole.intern,
          department: 'Technology',
          jobTitle: 'Backend Intern',
          salary: 15000,
          isActive: true,
          joinDate: DateTime(2024, 1, 15),
        ),
      ];
}
