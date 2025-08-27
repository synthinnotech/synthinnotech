import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/main.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:synthinnotech/view/chat_screen.dart';
import 'package:synthinnotech/view/expenses_screen.dart';
import 'package:synthinnotech/view/home_page.dart';
import 'package:synthinnotech/view/projects_screen.dart';
import 'package:synthinnotech/view/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 2, length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
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
          ProjectsScreen(),
          ExpensesScreen(),
          HomePage(),
          ChatScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildCurvedNavigationBar(),
    );
  }

  Widget _buildCurvedNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: _currentIndex,
        height: 65,
        items: _buildNavigationItems(),
        color: baseColor1,
        buttonBackgroundColor: baseColor3,
        animationCurve: Curves.easeInOutCubicEmphasized,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController!.animateTo(index);
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }

  List<CurvedNavigationBarItem> _buildNavigationItems() {
    final List<Map<String, dynamic>> navItems = [
      {
        'icon': Icons.folder_outlined,
        'label': 'Projects',
        'size': 24.0,
        'index': 0,
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Expenses',
        'size': 24.0,
        'index': 1,
      },
      {
        'icon': Icons.home,
        'label': 'Home',
        'size': 26.0,
        'index': 2,
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'Chat',
        'size': 24.0,
        'index': 3,
      },
      {
        'icon': Icons.settings_outlined,
        'label': 'Settings',
        'size': 24.0,
        'index': 4,
      },
    ];

    return navItems
        .map((item) => _buildNavigationBarItem(
              icon: item['icon'],
              label: item['label'],
              size: item['size'],
              index: item['index'],
            ))
        .toList();
  }

  CurvedNavigationBarItem _buildNavigationBarItem({
    required IconData icon,
    required String label,
    required double size,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    final bool isHome = index == 2;

    return CurvedNavigationBarItem(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size, color: isSelected ? baseColor2 : Colors.white),
        ],
      ),
      label: label,
      labelStyle: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: isHome ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? Colors.black : Colors.white,
      ),
    );
  }
}
