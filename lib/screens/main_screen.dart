import 'package:infinz/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import 'package:infinz/screens/dashboard_screen.dart';
import 'package:infinz/screens/history_screen.dart';
import 'package:infinz/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    LoanHomeScreen(),
    HistoryScreen(),
    MyProfileScreen(),
  ];

  final List<IconData> _iconList = [
    Icons.home,
    Icons.history,
    Icons.person,
  ];

  final List<String> _labels = [
    'Home',
    'History',
    'Profile',
  ];

  late AnimationController _bottomBarAnimationController;
  late Animation<double> _bottomBarAnimation;

  @override
  void initState() {
    super.initState();

    _bottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bottomBarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bottomBarAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _bottomBarAnimationController.forward();
  }

  @override
  void dispose() {
    _bottomBarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      // FAB removed

      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        scaleFactor: 1.0,
        itemCount: _iconList.length,
        tabBuilder: (index, isActive) {
          final color = isActive ? Colors.black : Colors.grey;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconList[index], size: 24, color: color),
              Text(
                _labels[index],
                style: TextStyle(color: color, fontSize: 12),
              )
            ],
          );
        },
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.none, // ✅ No FAB, so no gap
        notchSmoothness: NotchSmoothness.defaultEdge,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        leftCornerRadius: 24,
        rightCornerRadius: 24,
        splashColor: Colors.indigo,
        elevation: 8,
        height: 80,
      ),
    );
  }
}
