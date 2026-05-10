import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/view/expenses_screen.dart';
import 'package:synthinnotech/view/home_page.dart';
import 'package:synthinnotech/view/people_screen.dart';
import 'package:synthinnotech/view/projects_screen.dart';
import 'package:synthinnotech/view/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 2, length: 5, vsync: this);
  }

  @override
  void dispose() {
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
