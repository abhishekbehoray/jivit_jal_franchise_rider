// Screens/RiderScreens/BottomBar/RiderDashboardScreen.dart
import 'package:flutter/material.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/HomeScreen/RiderHomeScreen.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/OrderScreen/RiderOrdersScreen.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/ProfileScreen/RiderProfileScreen.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/BottomBar/RiderBottomNavBar.dart';

class RiderDashboardScreen extends StatefulWidget {
  final int initialTab;

  const RiderDashboardScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const RiderHomeScreen(),
    const RiderOrdersScreen(),
    const RiderProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: RiderBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}