import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:synthinnotech/view/chat_conversation_screen.dart';
import 'package:synthinnotech/view/edit_employee_screen.dart';
import 'package:synthinnotech/view_model/employee_view_model.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final EmployeeModel employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesViewModelProvider).employees;
    final current = employees.isEmpty
        ? employee
        : employees.firstWhere((e) => e.id == employee.id, orElse: () => employee);

    final roleColor = current.role.color;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: roleColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [roleColor, roleColor.withAlpha(180)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _AvatarLarge(employee: current),
                    const SizedBox(height: 12),
                    Text(current.name,
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(current.role.label,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: current.isActive
                                        ? Colors.greenAccent
                                        : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  )),
                              const SizedBox(width: 5),
                              Text(
                                  current.isActive ? 'Active' : 'Inactive',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'edit') {
                    Get.to(() => EditEmployeeScreen(employee: current));
                  } else if (v == 'toggle') {
                    _toggleActive(ref, current);
                  } else if (v == 'delete') {
                    _confirmDelete(context, ref, current);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Edit', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          current.isActive
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          size: 18,
                          color: current.isActive ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(current.isActive ? 'Deactivate' : 'Activate',
                            style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text('Delete',
                            style: GoogleFonts.inter(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeInUp(
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(
                            () => ChatConversationScreen(peer: current)),
                        icon: const Icon(Icons.chat_bubble_outline,
                            size: 20),
                        label: Text('Send Message',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roleColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 350),
                  child: _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Contact'),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: current.email,
                          color: const Color(0xFF2196F3),
                        ),
                        if (current.phone.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: current.phone,
                            color: const Color(0xFF4CAF50),
                          ),
                        ],
                        if (current.address != null &&
                            current.address!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: current.address!,
                            color: const Color(0xFFFF9800),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 350),
                  child: _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Work Details'),
                        const SizedBox(height: 12),
                        if (current.jobTitle != null) ...[
                          _InfoRow(
                            icon: Icons.work_outline,
                            label: 'Job Title',
                            value: current.jobTitle!,
                            color: roleColor,
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (current.department != null) ...[
                          _InfoRow(
                            icon: Icons.business_outlined,
                            label: 'Department',
                            value: current.department!,
                            color: const Color(0xFF9C27B0),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (current.salary > 0) ...[
                          _InfoRow(
                            icon: Icons.currency_rupee,
                            label: 'Salary',
                            value:
                                '₹${current.salary.toStringAsFixed(0)} / month',
                            color: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (current.joinDate != null) ...[
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Joined',
                            value:
                                '${months[current.joinDate!.month - 1]} ${current.joinDate!.day}, ${current.joinDate!.year}',
                            color: const Color(0xFF2196F3),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (current.gender != null ||
                    current.dateOfBirth != null) ...[
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 160),
                    duration: const Duration(milliseconds: 350),
                    child: _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Personal'),
                          const SizedBox(height: 12),
                          if (current.gender != null) ...[
                            _InfoRow(
                              icon: Icons.person_outline,
                              label: 'Gender',
                              value: current.gender!,
                              color: roleColor,
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (current.dateOfBirth != null)
                            _InfoRow(
                              icon: Icons.cake_outlined,
                              label: 'Date of Birth',
                              value:
                                  '${months[current.dateOfBirth!.month - 1]} ${current.dateOfBirth!.day}, ${current.dateOfBirth!.year}',
                              color: const Color(0xFFFF9800),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleActive(WidgetRef ref, EmployeeModel current) {
    final toggled = EmployeeModel(
      id: current.id,
      name: current.name,
      email: current.email,
      phone: current.phone,
      role: current.role,
      department: current.department,
      jobTitle: current.jobTitle,
      salary: current.salary,
      profileImageUrl: current.profileImageUrl,
      isActive: !current.isActive,
      address: current.address,
      gender: current.gender,
      dateOfBirth: current.dateOfBirth,
      joinDate: current.joinDate,
      createdAt: current.createdAt,
    );
    ref.read(employeesViewModelProvider.notifier).updateEmployee(toggled);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, EmployeeModel current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Employee',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Remove ${current.name} from the system?',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(employeesViewModelProvider.notifier)
                  .deleteEmployee(current.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete',
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AvatarLarge extends StatelessWidget {
  final EmployeeModel employee;
  const _AvatarLarge({required this.employee});

  @override
  Widget build(BuildContext context) {
    final color = employee.role.color;
    if (employee.profileImageUrl != null &&
        employee.profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: employee.profileImageUrl!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (_, __) => _Initial(name: employee.name, color: color),
            errorWidget: (_, __, ___) =>
                _Initial(name: employee.name, color: color),
          ),
        ),
      );
    }
    return _Initial(name: employee.name, color: color, radius: 40);
  }
}

class _Initial extends StatelessWidget {
  final String name;
  final Color color;
  final double radius;
  const _Initial(
      {required this.name, required this.color, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withAlpha(40),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.inter(
            fontSize: radius * 0.7,
            fontWeight: FontWeight.w800,
            color: Colors.white),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: colorScheme.onSurface.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
            letterSpacing: 0.4));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colorScheme.onSurface.withAlpha(110))),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }
}
