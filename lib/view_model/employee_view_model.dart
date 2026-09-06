import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:synthinnotech/service/employee_service.dart';
import 'package:synthinnotech/service/notification_center.dart';

class EmployeesState {
  final bool isLoading;
  final List<EmployeeModel> employees;
  final String? error;
  final String roleFilter; // 'all', 'admin', 'manager', 'employee', 'intern'
  final String search;

  const EmployeesState({
    this.isLoading = false,
    this.employees = const [],
    this.error,
    this.roleFilter = 'all',
    this.search = '',
  });

  EmployeesState copyWith({
    bool? isLoading,
    List<EmployeeModel>? employees,
    Object? error = _sentinel,
    String? roleFilter,
    String? search,
  }) =>
      EmployeesState(
        isLoading: isLoading ?? this.isLoading,
        employees: employees ?? this.employees,
        error: identical(error, _sentinel) ? this.error : error as String?,
        roleFilter: roleFilter ?? this.roleFilter,
        search: search ?? this.search,
      );

  static const _sentinel = Object();

  List<EmployeeModel> get filtered {
    var list = employees;
    if (roleFilter != 'all') {
      final role = EmployeeRole.values.firstWhere(
        (r) => r.name == roleFilter,
        orElse: () => EmployeeRole.employee,
      );
      list = list.where((e) => e.role == role).toList();
    }
    if (search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      list = list
          .where((e) =>
              e.name.toLowerCase().contains(q) ||
              e.email.toLowerCase().contains(q) ||
              (e.jobTitle ?? '').toLowerCase().contains(q) ||
              (e.department ?? '').toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  List<EmployeeModel> get admins =>
      employees.where((e) => e.role == EmployeeRole.admin).toList();
  List<EmployeeModel> get activeEmployees =>
      employees.where((e) => e.isActive).toList();
}

class EmployeesViewModel extends StateNotifier<EmployeesState> {
  EmployeesViewModel() : super(const EmployeesState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employees = await EmployeeService.getEmployees();
      state = state.copyWith(isLoading: false, employees: employees);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) => state = state.copyWith(roleFilter: filter);
  void setSearch(String value) => state = state.copyWith(search: value);

  Future<bool> addEmployee(EmployeeModel emp) async {
    try {
      final created = await EmployeeService.addEmployee(emp);
      state = state.copyWith(employees: _sorted([created, ...state.employees]));
      Snack.success('${created.name} added to the team');
      NotificationCenter.push(
        title: 'New Team Member',
        body: '${emp.name} joined as ${emp.role.label}',
        type: 'employee',
      );
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }

  Future<bool> updateEmployee(EmployeeModel emp) async {
    try {
      await EmployeeService.updateEmployee(emp);
      state = state.copyWith(
        employees:
            _sorted(state.employees.map((e) => e.id == emp.id ? emp : e).toList()),
      );
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await EmployeeService.deleteEmployee(id);
      state = state.copyWith(
          employees: state.employees.where((e) => e.id != id).toList());
      Snack.success('Employee removed');
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }

  List<EmployeeModel> _sorted(List<EmployeeModel> list) =>
      list..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

final employeesViewModelProvider =
    StateNotifierProvider<EmployeesViewModel, EmployeesState>(
  (ref) => EmployeesViewModel(),
);
