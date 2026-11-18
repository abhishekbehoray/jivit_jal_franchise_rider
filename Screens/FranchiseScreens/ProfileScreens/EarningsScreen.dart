// Screens/FranchiseScreens/ProfileScreens/EarningsMenuScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/Earningsdetailscreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/Franchiseperformancescreen.dart';

class EarningsMenuScreen extends StatelessWidget {
  const EarningsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Earnings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Select Date Tile
              _MenuTile(
                label: 'Select Date',
                backgroundColor: const Color(0xFFEEF1FB),
                borderColor: const Color(0xFFD0D9F5),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EarningsDetailScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Franchise Performance Tile
              _MenuTile(
                label: 'Franchise Performance',
                backgroundColor: const Color(0xFFFFF4EF),
                borderColor: const Color(0xFFF5D9CC),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FranchisePerformanceScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _MenuTile({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFAAAAAA),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}