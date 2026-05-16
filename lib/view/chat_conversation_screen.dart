import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/chat/chat_message.dart';
import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:synthinnotech/model/user/app_user.dart';
import 'package:synthinnotech/service/chat_service.dart';
import 'package:synthinnotech/service/notification_service.dart';
import 'package:synthinnotech/view_model/login_view_model.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final EmployeeModel peer;
  const ChatConversationScreen({super.key, required this.peer});

  // Tracks the currently-open chat so the global listener can suppress duplicates.
  static String? activeChatId;

  @override
  ConsumerState<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState
    extends ConsumerState<ChatConversationScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final String _chatId;
  StreamSubscription<List<ChatMessage>>? _sub;
  final List<ChatMessage> _messages = [];
  bool _sending = false;
  int _lastCount = 0;

  AppUser? get _me => ref.read(loginViewModelProvider).user;

  @override
  void initState() {
    super.initState();
    final me = _me;
    if (me != null) {
      _chatId = ChatService.chatId(me.uid, widget.peer.id);
      ChatConversationScreen.activeChatId = _chatId;
      ChatService.saveMyFCMToken(me.uid);
      _sub = ChatService.messageStream(_chatId).listen(_onMessages);
    }
  }

  void _onMessages(List<ChatMessage> msgs) {
    if (!mounted) return;
    final me = _me;
    if (me != null && msgs.length > _lastCount && _lastCount > 0) {
      for (final msg in msgs.sublist(_lastCount)) {
        if (msg.senderId != me.uid) {
          // Peer sent a message while we're on this screen — notify anyway
          // so the system notification is consistent with background behavior.
          NotificationService.showNotification(
            title: widget.peer.name,
            body: msg.text,
            channelKey: 'chat_channel',
            withActions: false,
          );
        }
      }
    }
    _lastCount = msgs.length;
    setState(() {
      _messages
        ..clear()
        ..addAll(msgs);
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    if (ChatConversationScreen.activeChatId == _chatId) {
      ChatConversationScreen.activeChatId = null;
    }
    _sub?.cancel();
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final me = _me;
    if (me == null) return;
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() => _sending = true);

    final msg = ChatMessage(
      id: '',
      senderId: me.uid,
      senderName: me.name,
      text: text,
      timestamp: DateTime.now(),
    );

    await ChatService.sendMessage(
      id: _chatId,
      message: msg,
      myUid: me.uid,
      myName: me.name,
      peerUid: widget.peer.id,
      peerName: widget.peer.name,
    );
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;
    final colorScheme = Theme.of(context).colorScheme;
    final roleColor = widget.peer.role.color;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: roleColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withAlpha(40),
              child: Text(
                widget.peer.name.isNotEmpty
                    ? widget.peer.name[0].toUpperCase()
                    : '?',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peer.name,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text(
                    widget.peer.jobTitle?.isNotEmpty == true
                        ? widget.peer.jobTitle!
                        : widget.peer.role.label,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: me == null
                ? Center(
                    child: Text('Not logged in',
                        style: GoogleFonts.inter(
                            color: colorScheme.onSurface)))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 60,
                                color: colorScheme.onSurface.withAlpha(60)),
                            const SizedBox(height: 12),
                            Text('Say hello to ${widget.peer.name}!',
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: colorScheme.onSurface
                                        .withAlpha(120))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          final isMe = msg.senderId == me.uid;
                          final showDate = i == 0 ||
                              !_sameDay(_messages[i - 1].timestamp,
                                  msg.timestamp);
                          return Column(
                            children: [
                              if (showDate) _DateDivider(msg.timestamp),
                              _MessageBubble(msg: msg, isMe: isMe),
                            ],
                          );
                        },
                      ),
          ),
          _InputBar(
            controller: _ctrl,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider(this.date);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final now = DateTime.now();
    String label;
    if (date.year == now.year && date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year && date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: colorScheme.onSurface.withAlpha(30))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: colorScheme.onSurface.withAlpha(100))),
          ),
          Expanded(
              child: Divider(color: colorScheme.onSurface.withAlpha(30))),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;
  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final h = msg.timestamp.hour.toString().padLeft(2, '0');
    final m = msg.timestamp.minute.toString().padLeft(2, '0');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 3,
          bottom: 3,
          left: isMe ? 64 : 0,
          right: isMe ? 0 : 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? colorScheme.primary
              : colorScheme.onSurface.withAlpha(14),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg.text,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        isMe ? Colors.white : colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text('$h:$m',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withAlpha(160)
                        : colorScheme.onSurface.withAlpha(100))),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border:
            Border(top: BorderSide(color: colorScheme.onSurface.withAlpha(20))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: GoogleFonts.inter(fontSize: 15),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 15,
                      color: colorScheme.onSurface.withAlpha(100)),
                  filled: true,
                  fillColor: colorScheme.onSurface.withAlpha(8),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: sending ? null : onSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
