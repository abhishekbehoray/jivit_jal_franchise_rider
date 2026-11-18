import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/BottomBar/RiderDashboardScreen.dart';

class ScheduleReattemptScreen extends StatefulWidget {
  const ScheduleReattemptScreen({super.key});

  @override
  State<ScheduleReattemptScreen> createState() =>
      _ScheduleReattemptScreenState();
}

class _ScheduleReattemptScreenState extends State<ScheduleReattemptScreen> {
  String _selected = 'today'; // 'today' or 'tomorrow'

  void _handleDeliveryDone() {
    // Navigate to RiderDashboardScreen with Home tab (index 0) selected
    // and clear all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const RiderDashboardScreen(
          initialTab: 0, // Home tab
        ),
      ),
          (route) => false, // removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Schedule Reattempt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Scrollable content ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Label ─────────────────────────────────────────
                    const Text(
                      'Reattempt',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // ── Retry later Today ─────────────────────────────
                    _ReattemptOption(
                      label: 'Retry later Today',
                      value: 'today',
                      groupValue: _selected,
                      onChanged: (val) => setState(() => _selected = val!),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // ── Retry Tomorrow ────────────────────────────────
                    _ReattemptOption(
                      label: 'Retry Tomorrow',
                      value: 'tomorrow',
                      groupValue: _selected,
                      onChanged: (val) => setState(() => _selected = val!),
                    ),
                  ],
                ),
              ),
            ),

            // ── Delivery Done button ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.05,
                0,
                screenWidth * 0.05,
                screenHeight * 0.04,
              ),
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.065,
                child: ElevatedButton(
                  onPressed: _handleDeliveryDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delivery Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reattempt Option Row
// ─────────────────────────────────────────────────────────────────────────────

class _ReattemptOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _ReattemptOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}