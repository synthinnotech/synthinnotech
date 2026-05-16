import 'dart:async';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/service/chat_service.dart';
import 'package:synthinnotech/service/notification_service.dart';
import 'package:synthinnotech/view/chat_conversation_screen.dart';
import 'package:synthinnotech/view/expenses_screen.dart';
import 'package:synthinnotech/view/home_page.dart';
import 'package:synthinnotech/view/people_screen.dart';
import 'package:synthinnotech/view/projects_screen.dart';
import 'package:synthinnotech/view/settings_screen.dart';
import 'package:synthinnotech/view_model/login_view_model.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 2;
  StreamSubscription<List<Map<String, dynamic>>>? _chatSub;
  String? _lastConvUpdateTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 2, length: 5, vsync: this);
    // Delay to let the auth state settle before starting listener.
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupChatListener());
  }

  void _setupChatListener() {
    final user = ref.read(loginViewModelProvider).user;
    if (user == null) return;

    ChatService.saveMyFCMToken(user.uid);

    _chatSub = ChatService.conversationStream(user.uid).listen((convs) {
      if (convs.isEmpty) return;
      final latest = convs.first;
      final updatedAt = latest['updated_at']?.toString() ?? '';
      final lastSenderId = latest['last_sender_id']?.toString() ?? '';
      final chatDocId = latest['id']?.toString() ?? '';

      if (_lastConvUpdateTime != null &&
          updatedAt != _lastConvUpdateTime &&
          lastSenderId != user.uid &&
          ChatConversationScreen.activeChatId != chatDocId) {
        final participants =
            List<String>.from(latest['participants'] ?? []);
        final peerUid = participants.firstWhere(
          (id) => id != user.uid,
          orElse: () => '',
        );
        final names = Map<String, dynamic>.from(
            latest['participant_names'] ?? {});
        final peerName = names[peerUid]?.toString() ?? 'New message';
        final lastMsg = latest['last_message']?.toString() ?? '';

        NotificationService.showNotification(
          title: peerName,
          body: lastMsg,
          channelKey: 'chat_channel',
          withActions: false,
        );
      }
      _lastConvUpdateTime = updatedAt;
    });
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: const [
          ExpensesScreen(),
          ProjectsScreen(),
          HomePage(),
          PeopleScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: _currentIndex,
        height: 65,
        color: baseColor1,
        buttonBackgroundColor: baseColor3,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOutCubicEmphasized,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
        items: _navItems(),
      ),
    );
  }

  List<CurvedNavigationBarItem> _navItems() {
    final items = [
      (Icons.account_balance_wallet_outlined, 'Finance', 0),
      (Icons.folder_outlined, 'Projects', 1),
      (Icons.home_rounded, 'Home', 2),
      (Icons.people_outline, 'People', 3),
      (Icons.settings_outlined, 'Settings', 4),
    ];

    return items.map((item) {
      final isSelected = _currentIndex == item.$3;
      return CurvedNavigationBarItem(
        child: Icon(
          item.$1,
          size: item.$3 == 2 ? 28 : 24,
          color: isSelected ? baseColor2 : Colors.white,
        ),
        label: item.$2,
        labelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: item.$3 == 2 ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : Colors.white70,
        ),
      );
    }).toList();
  }
}
