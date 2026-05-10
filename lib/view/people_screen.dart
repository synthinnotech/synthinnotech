import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:synthinnotech/view/add_employee_screen.dart';
import 'package:synthinnotech/view/employee_detail_screen.dart';
import 'package:synthinnotech/view_model/employee_view_model.dart';
import 'package:synthinnotech/widget/common/app_empty_state.dart';
import 'package:synthinnotech/widget/common/app_loading.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(employeesViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('People',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => Get.to(
              () => const AddEmployeeScreen(),
              transition: Transition.downToUp,
            ),
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
          ),
        ],
      ),
      body: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: AppLoadingList(count: 5),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(employeesViewModelProvider.notifier).load(),
              child: Column(
                children: [
                  _SummaryBar(state: state),
                  _FilterChips(
                    selected: state.roleFilter,
                    onSelect: (r) =>
                        ref.read(employeesViewModelProvider.notifier).setFilter(r),
                  ),
                  Expanded(
                    child: state.filtered.isEmpty
                        ? AppEmptyState(
                            icon: Icons.people_outline,
                            title: 'No Members',
                            subtitle: 'No people in this category',
                            actionLabel: 'Add Employee',
                            onAction: () => Get.to(
                              () => const AddEmployeeScreen(),
                              transition: Transition.downToUp,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: state.filtered.length,
                            itemBuilder: (ctx, i) => FadeInLeft(
                              delay: Duration(milliseconds: i * 60),
                              duration: const Duration(milliseconds: 350),
                              child: _EmployeeCard(emp: state.filtered[i]),
                            ),
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 65),
        child: FloatingActionButton.extended(
          onPressed: () => Get.to(
            () => const AddEmployeeScreen(),
            transition: Transition.downToUp,
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: Text('Add Member',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final EmployeesState state;
  const _SummaryBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withAlpha(200)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatTile(
              value: state.employees.length.toString(),
              label: 'Total',
              icon: Icons.people),
          _StatTile(
              value:
                  state.employees.where((e) => e.role == EmployeeRole.admin).length.toString(),
              label: 'Admins',
              icon: Icons.admin_panel_settings_outlined),
          _StatTile(
              value: state.activeEmployees.length.toString(),
              label: 'Active',
              icon: Icons.check_circle_outline),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatTile({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String selected;
  final Function(String) onSelect;
  const _FilterChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', 'All'),
      ('admin', 'Admin'),
      ('manager', 'Manager'),
      ('employee', 'Employee'),
      ('intern', 'Intern'),
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: filters.map((f) {
          final isSelected = selected == f.$1;
          final colorScheme = Theme.of(context).colorScheme;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f.$2,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : colorScheme.onSurface)),
              selected: isSelected,
              onSelected: (_) => onSelect(f.$1),
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primary,
              checkmarkColor: Colors.white,
              side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withAlpha(40)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel emp;
  const _EmployeeCard({required this.emp});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final roleColor = emp.role.color;

    return GestureDetector(
      onTap: () => Get.to(
        () => EmployeeDetailScreen(employee: emp),
        transition: Transition.rightToLeft,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: colorScheme.onSurface.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            _Avatar(emp: emp),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          emp.name,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          emp.role.label,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: roleColor),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    emp.jobTitle ?? emp.department ?? '',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurface.withAlpha(140)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.email_outlined,
                          size: 13,
                          color: colorScheme.onSurface.withAlpha(120)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          emp.email,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colorScheme.onSurface.withAlpha(140)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: emp.isActive
                              ? const Color(0xFF4CAF50)
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final EmployeeModel emp;
  const _Avatar({required this.emp});

  @override
  Widget build(BuildContext context) {
    if (emp.profileImageUrl != null && emp.profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: emp.profileImageUrl!,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                _InitialAvatar(name: emp.name, color: emp.role.color),
            errorWidget: (_, __, ___) =>
                _InitialAvatar(name: emp.name, color: emp.role.color),
          ),
        ),
      );
    }
    return _InitialAvatar(name: emp.name, color: emp.role.color, radius: 28);
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double radius;
  const _InitialAvatar(
      {required this.name, required this.color, this.radius = 28});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withAlpha(40),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.inter(
            fontSize: radius * 0.7,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }
}
