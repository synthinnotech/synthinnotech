import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/service/theme_service.dart';
import 'package:synthinnotech/view/login_page.dart';
import 'package:synthinnotech/view_model/login_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeService.isDarkTheme);
    final user = ref.watch(loginViewModelProvider).user;

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
            child: _ProfileCard(user: user, isDark: isDark),
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
                  subtitle: isDark ? 'Switch to light theme' : 'Switch to dark theme',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => ThemeService.toggleTheme(ref),
                    activeColor: baseColor1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _Section(
              title: 'Notifications',
              items: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Manage notification preferences',
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: baseColor1,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.campaign_outlined,
                  title: 'Project Alerts',
                  subtitle: 'Deadline and status updates',
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: baseColor1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: _Section(
              title: 'Account',
              items: [
                _SettingsTile(
                  icon: Icons.security,
                  title: 'Security',
                  subtitle: 'Password and authentication',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'FAQs and contact support',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'SynthInnoTech v1.0.0',
                  onTap: () {},
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
}

class _ProfileCard extends StatelessWidget {
  final dynamic user;
  final bool isDark;
  const _ProfileCard({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
            backgroundColor: Colors.white.withAlpha(40),
            child: Text(
              user?.name?.isNotEmpty == true
                  ? user!.name[0].toUpperCase()
                  : 'S',
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
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (user?.role ?? 'employee').toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                color: colorScheme.onSurface.withAlpha(160),
                letterSpacing: 0.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: colorScheme.onSurface.withAlpha(8),
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
          color: colorScheme.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: colorScheme.primary),
      ),
      title: Text(title,
          style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w500,
              color: colorScheme.onSurface)),
      subtitle: Text(subtitle,
          style: GoogleFonts.inter(
              fontSize: 12, color: colorScheme.onSurface.withAlpha(140))),
      trailing: trailing ??
          Icon(Icons.chevron_right, color: colorScheme.onSurface.withAlpha(100)),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red),
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
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(loginViewModelProvider.notifier).logout();
              Get.offAll(() => const LoginPage());
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sign Out',
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
