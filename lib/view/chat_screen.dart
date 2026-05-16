import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:synthinnotech/service/chat_service.dart';
import 'package:synthinnotech/view/chat_conversation_screen.dart';
import 'package:synthinnotech/view_model/employee_view_model.dart';
import 'package:synthinnotech/view_model/login_view_model.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginViewModelProvider).user;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages',
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? Center(
              child: Text('Please log in to use chat',
                  style: GoogleFonts.inter(color: colorScheme.onSurface)))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChatService.conversationStream(user.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final convs = snap.data ?? [];
                if (convs.isEmpty) {
                  return _EmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: convs.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 76,
                      color: colorScheme.onSurface.withAlpha(15)),
                  itemBuilder: (context, i) {
                    final conv = convs[i];
                    final participants =
                        List<String>.from(conv['participants'] ?? []);
                    final peerUid = participants.firstWhere(
                        (id) => id != user.uid,
                        orElse: () => '');
                    final names = Map<String, dynamic>.from(
                        conv['participant_names'] ?? {});
                    final peerName =
                        names[peerUid]?.toString() ?? 'Unknown';
                    final lastMsg =
                        conv['last_message']?.toString() ?? '';
                    final lastSenderId =
                        conv['last_sender_id']?.toString() ?? '';
                    final updatedAt =
                        conv['updated_at']?.toString();

                    final employees =
                        ref.read(employeesViewModelProvider).employees;
                    final peer = employees.firstWhere(
                      (e) => e.id == peerUid,
                      orElse: () => EmployeeModel(
                          id: peerUid, name: peerName, email: ''),
                    );

                    return _ConversationTile(
                      peer: peer,
                      lastMessage: lastMsg,
                      isLastFromMe: lastSenderId == user.uid,
                      updatedAt: updatedAt,
                      onTap: () =>
                          Get.to(() => ChatConversationScreen(peer: peer)),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final EmployeeModel peer;
  final String lastMessage;
  final bool isLastFromMe;
  final String? updatedAt;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.peer,
    required this.lastMessage,
    required this.isLastFromMe,
    required this.updatedAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final roleColor = peer.id.isEmpty ? Colors.grey : peer.role.color;

    String timeLabel = '';
    if (updatedAt != null) {
      final dt = DateTime.tryParse(updatedAt!);
      if (dt != null) {
        final now = DateTime.now();
        if (dt.year == now.year && dt.month == now.month &&
            dt.day == now.day) {
          final h = dt.hour.toString().padLeft(2, '0');
          final m = dt.minute.toString().padLeft(2, '0');
          timeLabel = '$h:$m';
        } else {
          const months = ['Jan','Feb','Mar','Apr','May','Jun',
              'Jul','Aug','Sep','Oct','Nov','Dec'];
          timeLabel = '${months[dt.month - 1]} ${dt.day}';
        }
      }
    }

    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: roleColor.withAlpha(30),
        child: Text(
          peer.name.isNotEmpty ? peer.name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: roleColor),
        ),
      ),
      title: Text(peer.name,
          style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Row(
        children: [
          if (isLastFromMe)
            Icon(Icons.done_all,
                size: 14,
                color: colorScheme.primary.withAlpha(180)),
          if (isLastFromMe) const SizedBox(width: 4),
          Expanded(
            child: Text(
              lastMessage,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colorScheme.onSurface.withAlpha(120)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: timeLabel.isEmpty
          ? null
          : Text(timeLabel,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: colorScheme.onSurface.withAlpha(100))),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 72, color: colorScheme.onSurface.withAlpha(60)),
          const SizedBox(height: 16),
          Text('No conversations yet',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withAlpha(140))),
          const SizedBox(height: 8),
          Text('Start a chat from an employee profile',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colorScheme.onSurface.withAlpha(100))),
        ],
      ),
    );
  }
}
