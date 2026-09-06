// Basic smoke test for the SynthInnoTech app shell.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:synthinnotech/core/rbac/app_role.dart';

void main() {
  test('RBAC: only admins manage employees', () {
    expect(Rbac.can(AppRole.admin, Permission.manageEmployees), isTrue);
    expect(Rbac.can(AppRole.manager, Permission.manageEmployees), isFalse);
    expect(Rbac.can(AppRole.employee, Permission.manageEmployees), isFalse);
  });

  test('RBAC: managers and admins manage finance', () {
    expect(Rbac.can(AppRole.admin, Permission.manageFinance), isTrue);
    expect(Rbac.can(AppRole.manager, Permission.manageFinance), isTrue);
    expect(Rbac.can(AppRole.intern, Permission.manageFinance), isFalse);
  });

  test('AppRole.fromWire tolerates legacy values', () {
    expect(AppRoleX.fromWire('admin'), AppRole.admin);
    expect(AppRoleX.fromWire(true), AppRole.admin);
    expect(AppRoleX.fromWire('manager'), AppRole.manager);
    expect(AppRoleX.fromWire(null), AppRole.employee);
    expect(AppRoleX.fromWire('anything-else'), AppRole.employee);
  });

  testWidgets('MaterialApp builds inside a ProviderScope', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: Text('SynthInnoTech'))),
      ),
    );
    expect(find.text('SynthInnoTech'), findsOneWidget);
  });
}
