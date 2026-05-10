import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/view/add_project_screen.dart';
import 'package:synthinnotech/view/add_transaction_screen.dart';
import 'package:synthinnotech/view/add_employee_screen.dart';
import 'package:synthinnotech/view/notifications_screen.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FadeInLeft(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
                child: _ActionButton(
                  label: 'Add Transaction',
                  icon: Icons.add_card_rounded,
                  color: const Color(0xFF4CAF50),
                  isDark: isDark,
                  onTap: () => Get.to(
                    () => const AddTransactionScreen(),
                    transition: Transition.downToUp,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FadeInRight(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
                child: _ActionButton(
                  label: 'New Project',
                  icon: Icons.add_box_rounded,
                  color: const Color(0xFF9C27B0),
                  isDark: isDark,
                  onTap: () => Get.to(
                    () => const AddProjectScreen(),
                    transition: Transition.downToUp,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FadeInLeft(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
                child: _ActionButton(
                  label: 'Add Employee',
                  icon: Icons.person_add_rounded,
                  color: const Color(0xFF2196F3),
                  isDark: isDark,
                  onTap: () => Get.to(
                    () => const AddEmployeeScreen(),
                    transition: Transition.downToUp,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FadeInRight(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
                child: _ActionButton(
                  label: 'Notifications',
                  icon: Icons.notifications_outlined,
                  color: const Color(0xFFFF9800),
                  isDark: isDark,
                  onTap: () => Get.to(
                    () => const NotificationsScreen(),
                    transition: Transition.rightToLeft,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: colorScheme.onSurface
                  .withOpacity(isDark ? 0.08 : 0.06)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
