// Screens/RiderScreens/BottomBar/RiderBottomNavBar.dart
import 'package:flutter/material.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';

class RiderBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RiderBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final List<Map<String, dynamic>> _navItems = const [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
    {'icon': Icons.shopping_bag_outlined, 'activeIcon': Icons.shopping_bag, 'label': 'Orders'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.02,
            vertical: height * 0.006,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
                  (index) => _buildNavItem(
                index: index,
                icon: _navItems[index]['icon'] as IconData,
                activeIcon: _navItems[index]['activeIcon'] as IconData,
                label: _navItems[index]['label'] as String,
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
                width: width,
                height: height,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active indicator bar
          if (isSelected)
            Container(
              width: width * 0.06,
              height: height * 0.004,
              margin: EdgeInsets.only(bottom: height * 0.005),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            SizedBox(height: height * 0.009),

          // Icon - filled when selected, outlined when not
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors.primaryBlue : AppColors.iconGray,
            size: width * 0.065,
          ),
          SizedBox(height: height * 0.004),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.03,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primaryBlue : AppColors.iconGray,
            ),
          ),
        ],
      ),
    );
  }
}