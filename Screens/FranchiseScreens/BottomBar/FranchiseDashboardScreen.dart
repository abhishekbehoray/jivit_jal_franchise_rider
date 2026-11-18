// Screens/FranchiseScreens/BottomBar/FranchiseDashboardScreen.dart
import 'package:flutter/material.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/HomeScreens/FranchiseHomeScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/OrderScreens/FranchiseOrdersScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/AgentScreens/FranchiseAgentsScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/InventoryScreens/FranchiseInventoryScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/BottomBar/FranchiseBottomNavBar.dart';

class FranchiseDashboardScreen extends StatefulWidget {
  final int initialTab;
  final String? initialFilter;

  const FranchiseDashboardScreen({
    super.key,
    this.initialTab = 0,
    this.initialFilter,
  });

  @override
  State<FranchiseDashboardScreen> createState() => _FranchiseDashboardScreenState();
}

class _FranchiseDashboardScreenState extends State<FranchiseDashboardScreen> {
  late int _currentIndex;

  // ── Screens in correct order matching bottom nav ──
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _screens = [
      const FranchiseHomeScreen(),      // Index 0 - Home
      const FranchiseAgentsScreen(),    // Index 1 - Agents
      FranchiseOrdersScreen(initialFilter: widget.initialFilter), // Index 2 - Orders
      const FranchiseInventoryScreen(), // Index 3 - Inventory
    ];
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
        bottomNavigationBar: FranchiseBottomNavBar(
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