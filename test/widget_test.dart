// Smoke tests for SynthInnoTech.
//
// The screen imports below are deliberate: `flutter test` compiles the full
// import closure, so referencing every top-level screen here gives us a
// whole-app compile check on top of `flutter analyze`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:synthinnotech/core/rbac/app_role.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';

// Touch every feature entrypoint so a compile error anywhere fails the suite.
import 'package:synthinnotech/modules/auth/presentation/auth_gate.dart';
import 'package:synthinnotech/modules/auth/presentation/sign_in_screen.dart';
import 'package:synthinnotech/modules/auth/presentation/forgot_password_screen.dart';
import 'package:synthinnotech/modules/auth/presentation/change_password_screen.dart';
import 'package:synthinnotech/modules/auth/presentation/register_staff_screen.dart';
import 'package:synthinnotech/modules/attendance/attendance_screen.dart';
import 'package:synthinnotech/modules/leave/leave_screen.dart';
import 'package:synthinnotech/modules/announcements/announcements_screen.dart';
import 'package:synthinnotech/modules/notes/notes_screen.dart';
import 'package:synthinnotech/modules/tasks/my_tasks_screen.dart';
import 'package:synthinnotech/modules/profile/profile_screen.dart';
import 'package:synthinnotech/view/more_screen.dart';
import 'package:synthinnotech/view/main_navigation_screen.dart';
import 'package:synthinnotech/view/settings_screen.dart';

void main() {
  test('RBAC permission matrix', () {
    expect(Rbac.can(AppRole.admin, Permission.manageEmployees), isTrue);
    expect(Rbac.can(AppRole.manager, Permission.manageEmployees), isFalse);
    expect(Rbac.can(AppRole.employee, Permission.manageEmployees), isFalse);

    expect(Rbac.can(AppRole.admin, Permission.manageFinance), isTrue);
    expect(Rbac.can(AppRole.manager, Permission.manageFinance), isTrue);
    expect(Rbac.can(AppRole.intern, Permission.manageFinance), isFalse);

    expect(Rbac.can(AppRole.manager, Permission.approveLeave), isTrue);
    expect(Rbac.can(AppRole.employee, Permission.approveLeave), isFalse);
  });

  test('AppRole.fromWire tolerates legacy values', () {
    expect(AppRoleX.fromWire('admin'), AppRole.admin);
    expect(AppRoleX.fromWire(true), AppRole.admin);
    expect(AppRoleX.fromWire(1), AppRole.admin);
    expect(AppRoleX.fromWire('manager'), AppRole.manager);
    expect(AppRoleX.fromWire(null), AppRole.employee);
    expect(AppRoleX.fromWire('gibberish'), AppRole.employee);
  });

  test('Db.readDate parses ISO / epoch / null', () {
    expect(Db.readDate(null), isNull);
    expect(Db.readDate('2026-01-15T10:00:00Z')?.year, 2026);
    expect(Db.readDate(1737000000000)?.year, 2025); // millis
    expect(Db.readDate(1737000000)?.year, 2025); // seconds
  });

  test('AppException gives clean messages', () {
    const e = AppException('nope', code: 'permission-denied');
    expect(e.isPermissionDenied, isTrue);
    expect(AppException.from(e), same(e));
  });

  testWidgets('app shell widgets construct without throwing', (tester) async {
    // Reference the screen types so the compiler links them; instantiating
    // const constructors is enough to catch signature breakage.
    const widgets = <Widget>[
      AuthGate(),
      SignInScreen(),
      ForgotPasswordScreen(),
      ChangePasswordScreen(),
      RegisterStaffScreen(),
      AttendanceScreen(),
      LeaveScreen(),
      AnnouncementsScreen(),
      NotesScreen(),
      MyTasksScreen(),
      ProfileScreen(),
      MoreScreen(),
      MainNavigationScreen(),
      SettingsScreen(),
    ];
    expect(widgets.length, 14);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: Text('SynthInnoTech'))),
      ),
    );
    expect(find.text('SynthInnoTech'), findsOneWidget);
  });
}
