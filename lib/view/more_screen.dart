import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/core/rbac/app_role.dart';
import 'package:synthinnotech/modules/announcements/announcements_screen.dart';
import 'package:synthinnotech/modules/attendance/attendance_screen.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/leave/leave_screen.dart';
import 'package:synthinnotech/modules/notes/notes_screen.dart';
import 'package:synthinnotech/modules/tasks/my_tasks_screen.dart';
import 'package:synthinnotech/view/chat_screen.dart';
import 'package:synthinnotech/view/notifications_screen.dart';
import 'package:synthinnotech/view/settings_screen.dart';
import 'package:synthinnotech/view_model/notification_view_model.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final unread = ref.watch(notificationsViewModelProvider).unreadCount;
    final cs = Theme.of(context).colorScheme;

    final tiles = <_MoreTile>[
      _MoreTile('Chat', Icons.chat_bubble_outline, const Color(0xFF2196F3),
          () => Get.to(() => const ChatScreen())),
      _MoreTile('My Tasks', Icons.checklist_rounded, const Color(0xFF9C27B0),
          () => Get.to(() => const MyTasksScreen())),
      _MoreTile('Attendance', Icons.how_to_reg_outlined,
          const Color(0xFF00897B), () => Get.to(() => const AttendanceScreen())),
      _MoreTile('Leave', Icons.beach_access_outlined, const Color(0xFFFF9800),
          () => Get.to(() => const LeaveScreen())),
      _MoreTile('Announcements', Icons.campaign_outlined,
          const Color(0xFFE53935), () => Get.to(() => const AnnouncementsScreen())),
      _MoreTile('Notes', Icons.sticky_note_2_outlined, const Color(0xFFFBC02D),
          () => Get.to(() => const NotesScreen())),
      _MoreTile(
        'Notifications',
        Icons.notifications_outlined,
        const Color(0xFF5E35B1),
        () => Get.to(() => const NotificationsScreen()),
        badge: unread,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('More',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (user != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [user.appRole.color, user.appRole.color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(user.initial,
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('${user.email} · ${user.appRole.label}',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.to(() => const SettingsScreen()),
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: tiles
                .map((t) => _TileCard(tile: t, surface: cs.surface))
                .toList(),
          ),
          const SizedBox(height: 20),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            tileColor: cs.surface,
            leading: Icon(Icons.settings_outlined, color: cs.primary),
            title: Text('Settings',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text('Profile, theme, password, sign out',
                style: GoogleFonts.inter(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
    );
  }
}

class _MoreTile {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int badge;
  _MoreTile(this.label, this.icon, this.color, this.onTap, {this.badge = 0});
}

class _TileCard extends StatelessWidget {
  const _TileCard({required this.tile, required this.surface});
  final _MoreTile tile;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: tile.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tile.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(tile.icon, color: tile.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(tile.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (tile.badge > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text('${tile.badge}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
