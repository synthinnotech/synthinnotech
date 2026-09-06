import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:synthinnotech/core/rbac/app_role.dart';
import 'package:synthinnotech/modules/announcements/announcement.dart';
import 'package:synthinnotech/modules/announcements/announcements_view_model.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsViewModelProvider);
    final user = ref.watch(currentUserProvider);
    final canPost = user?.can(Permission.manageAnnouncements) ?? false;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      floatingActionButton: canPost
          ? FloatingActionButton.extended(
              onPressed: () => _showComposer(context, ref),
              icon: const Icon(Icons.campaign_outlined),
              label: Text('Post',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )
          : null,
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.campaign_outlined,
                            size: 56,
                            color: cs.onSurface.withValues(alpha: 0.25)),
                        const SizedBox(height: 12),
                        Text(
                          canPost
                              ? 'No announcements yet.\nTap "Post" to share news with the team.'
                              : 'No announcements yet.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  children: state.items
                      .map((a) => _Card(announcement: a, canManage: canPost))
                      .toList(),
                ),
    );
  }

  void _showComposer(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool pinned = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final cs = Theme.of(ctx).colorScheme;
          return Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New announcement',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: pinned,
                  onChanged: (v) => setSt(() => pinned = v),
                  title: Text('Pin to top',
                      style: GoogleFonts.inter(fontSize: 14)),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await ref
                          .read(announcementsViewModelProvider.notifier)
                          .post(
                            title: titleCtrl.text,
                            body: bodyCtrl.text,
                            pinned: pinned,
                          );
                      if (ok && ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text('Post',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card({required this.announcement, required this.canManage});
  final Announcement announcement;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final a = announcement;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: a.pinned
                ? cs.primary.withValues(alpha: 0.4)
                : cs.onSurface.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (a.pinned)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.push_pin, size: 15, color: cs.primary),
                ),
              Expanded(
                child: Text(a.title,
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              if (canManage)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz,
                      size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
                  onSelected: (v) {
                    final vm =
                        ref.read(announcementsViewModelProvider.notifier);
                    if (v == 'pin') vm.togglePin(a);
                    if (v == 'delete') vm.delete(a);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'pin',
                        child: Text(a.pinned ? 'Unpin' : 'Pin to top')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
          if (a.body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(a.body,
                style: GoogleFonts.inter(
                    fontSize: 13, height: 1.5, color: cs.onSurface)),
          ],
          const SizedBox(height: 10),
          Text(
            '${a.authorName} · ${DateFormat('MMM d, h:mm a').format(a.createdAt)}',
            style: GoogleFonts.inter(
                fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
