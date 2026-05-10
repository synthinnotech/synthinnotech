import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:synthinnotech/service/employee_service.dart';
import 'package:synthinnotech/service/notification_service.dart';

class EmployeesState {
  final bool isLoading;
  final List<EmployeeModel> employees;
  final String? error;
  final String roleFilter; // 'all', 'admin', 'manager', 'employee', 'intern'

  const EmployeesState({
    this.isLoading = false,
    this.employees = const [],
    this.error,
    this.roleFilter = 'all',
  });

  EmployeesState copyWith({
    bool? isLoading,
    List<EmployeeModel>? employees,
    String? error,
    String? roleFilter,
  }) =>
      EmployeesState(
        isLoading: isLoading ?? this.isLoading,
        employees: employees ?? this.employees,
        error: error,
        roleFilter: roleFilter ?? this.roleFilter,
      );

  List<EmployeeModel> get filtered {
    if (roleFilter == 'all') return employees;
    final role = EmployeeRole.values
        .firstWhere((r) => r.name == roleFilter, orElse: () => EmployeeRole.employee);
    return employees.where((e) => e.role == role).toList();
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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(roleFilter: filter);
  }

  Future<void> addEmployee(EmployeeModel emp) async {
    final created = await EmployeeService.addEmployee(emp);
    state = state.copyWith(employees: [created, ...state.employees]);
    NotificationService.showNotification(
      title: 'New Member Added',
      body: '${emp.name} joined as ${emp.role.label}',
      channelKey: 'general_channel',
      withActions: false,
    );
  }

  Future<void> updateEmployee(EmployeeModel emp) async {
    await EmployeeService.updateEmployee(emp);
    final updated =
        state.employees.map((e) => e.id == emp.id ? emp : e).toList();
    state = state.copyWith(employees: updated);
  }

  Future<void> deleteEmployee(String id) async {
    await EmployeeService.deleteEmployee(id);
    state = state.copyWith(
        employees: state.employees.where((e) => e.id != id).toList());
  }
}

final employeesViewModelProvider =
    StateNotifierProvider<EmployeesViewModel, EmployeesState>(
  (ref) => EmployeesViewModel(),
);
