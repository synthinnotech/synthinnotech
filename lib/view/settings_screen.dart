import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/rbac/app_role.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/auth/presentation/change_password_screen.dart';
import 'package:synthinnotech/modules/profile/profile_screen.dart';
import 'package:synthinnotech/model/user/app_user.dart';
import 'package:synthinnotech/service/theme_service.dart';
import 'package:synthinnotech/view/notifications_screen.dart';
import 'package:synthinnotech/view_model/login_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeService.isDarkTheme);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: _ProfileCard(
              user: user,
              onTap: () => Get.to(() => const ProfileScreen()),
            ),
          ),
          const SizedBox(height: 24),
          FadeInLeft(
            delay: const Duration(milliseconds: 100),
            child: _Section(
              title: 'Appearance',
              items: [
                _SettingsTile(
                  icon: isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  title: 'Dark Mode',
                  subtitle:
                      isDark ? 'Switch to light theme' : 'Switch to dark theme',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => ThemeService.toggleTheme(ref),
                    activeThumbColor: baseColor1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _Section(
              title: 'Account',
              items: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Name, contact details, department',
                  onTap: () => Get.to(() => const ProfileScreen()),
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your sign-in password',
                  onTap: () => Get.to(() => const ChangePasswordScreen()),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'View recent activity',
                  onTap: () => Get.to(() => const NotificationsScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: _Section(
              title: 'About',
              items: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About SynthInnoTech',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAbout(context),
                ),
                _SettingsTile(
                  icon: Db.enabled ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                  title: 'Backend status',
                  subtitle: Db.enabled
                      ? 'Firebase connected'
                      : 'Firebase not configured — see SETUP.md',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _LogoutButton(ref: ref),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SynthInnoTech',
      applicationVersion: '1.0.0',
      applicationIcon: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/logo.png'),
      ),
      children: [
        const SizedBox(height: 12),
        Text(
          'Company management for projects, people, finance, attendance, '
          'leave, announcements and team chat.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final AppUser? user;
  final VoidCallback onTap;
  const _ProfileCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [baseColor1, baseColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              child: Text(
                user?.initial ?? 'U',
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (user?.appRole.label ?? 'Employee').toUpperCase(),
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: 0.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: colorScheme.primary),
      ),
      title: Text(title,
          style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface)),
      subtitle: Text(subtitle,
          style: GoogleFonts.inter(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.55))),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.4))
              : null),
      onTap: onTap,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;
  const _LogoutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(
          'Sign Out',
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(loginViewModelProvider.notifier).logout();
              Get.until((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sign Out',
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
