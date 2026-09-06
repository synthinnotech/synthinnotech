import 'package:flutter/material.dart';

/// The single source of truth for roles across the whole app.
///
/// The old code had two parallel enums (`EmployeeRole` and free-form `role`
/// strings on `AppUser`). This is the canonical one; the wire value is
/// [name] (e.g. `"admin"`), matching what Firestore stores and what the
/// security rules check.
enum AppRole { admin, manager, employee, intern }

extension AppRoleX on AppRole {
  String get wire => name;

  String get label {
    switch (this) {
      case AppRole.admin:
        return 'Admin';
      case AppRole.manager:
        return 'Manager';
      case AppRole.employee:
        return 'Employee';
      case AppRole.intern:
        return 'Intern';
    }
  }

  Color get color {
    switch (this) {
      case AppRole.admin:
        return const Color(0xFF9C27B0);
      case AppRole.manager:
        return const Color(0xFF2196F3);
      case AppRole.employee:
        return const Color(0xFF4CAF50);
      case AppRole.intern:
        return const Color(0xFFFF9800);
    }
  }

  /// Rank used for "at least this role" checks. Higher = more privileged.
  int get rank {
    switch (this) {
      case AppRole.admin:
        return 3;
      case AppRole.manager:
        return 2;
      case AppRole.employee:
        return 1;
      case AppRole.intern:
        return 0;
    }
  }

  bool get isManagerOrAbove => rank >= AppRole.manager.rank;
  bool get isAdmin => this == AppRole.admin;

  static AppRole fromWire(Object? value) {
    if (value is bool) return value ? AppRole.admin : AppRole.employee;
    final s = value?.toString().trim().toLowerCase();
    switch (s) {
      case 'admin':
      case '1':
      case 'true':
        return AppRole.admin;
      case 'manager':
      case 'lead':
      case 'tech lead':
        return AppRole.manager;
      case 'intern':
      case 'trainee':
        return AppRole.intern;
      default:
        return AppRole.employee;
    }
  }
}

/// Discrete capabilities the UI and services gate on. Keep this list aligned
/// with `firestore.rules` so the client never offers an action the backend
/// will reject.
enum Permission {
  manageEmployees, // create / edit / delete staff
  manageFinance, // create / edit / delete transactions
  manageProjects, // create / edit / delete projects
  manageAnnouncements, // post company announcements
  approveLeave, // approve / reject leave requests
  viewAllAttendance, // see everyone's attendance, not just your own
  seedDemoData, // one-tap sample data
}

class Rbac {
  const Rbac._();

  static bool can(AppRole role, Permission permission) {
    switch (permission) {
      case Permission.manageEmployees:
      case Permission.manageAnnouncements:
      case Permission.seedDemoData:
        return role == AppRole.admin;
      case Permission.manageFinance:
        return role.isManagerOrAbove;
      case Permission.manageProjects:
      case Permission.approveLeave:
      case Permission.viewAllAttendance:
        return role.isManagerOrAbove;
    }
  }
}
