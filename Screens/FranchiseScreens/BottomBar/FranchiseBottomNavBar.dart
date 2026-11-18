// Screens/FranchiseScreens/BottomBar/FranchiseBottomNavBar.dart
import 'package:flutter/material.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';

class FranchiseBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FranchiseBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
      top: false,
      child: Container(
        height: height * 0.085,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            context,
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Agents',
            index: 1,
          ),
          _buildNavItem(
            context,
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag,
            label: 'Orders',
            index: 2,
          ),
          _buildNavItem(
            context,
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: 'Inventory',
            index: 3,
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required IconData activeIcon,
        required String label,
        required int index,
      }) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: height * 0.008,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Selection Indicator Line ────────────────────────────────────
              Container(
                height: 3,
                width: isSelected ? width * 0.1 : 0,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: height * 0.004),
              // ── Icon ────────────────────────────────────────────────────────
              Icon(
                isSelected ? activeIcon : icon,
                size: width * 0.075,
                color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
              ),
              SizedBox(height: height * 0.004),
              // ── Label ───────────────────────────────────────────────────────
              Text(
                label,
                style: TextStyle(
                  fontSize: width * 0.035,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}