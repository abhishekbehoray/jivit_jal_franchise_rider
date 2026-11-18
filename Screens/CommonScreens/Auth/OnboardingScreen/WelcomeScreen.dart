// Screens/Auth/WelcomeScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/Auth/OnboardingScreen/OnboardingScreenThree.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/Auth/OnboardingScreen/OnboardingScreenTwo.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Utils/ImageAssets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            // ── Bottom Water Element ────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                ImageAssets.waterBottom,
                width: double.infinity,
                height: height * 0.15, // Reduced height
                fit: BoxFit.cover,
              ),
            ),

            // ── Main Content ─────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Title ─────────────────────────────────────────────
                    const Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose your role to get started',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: height * 0.04),

                    // ── Franchise Card ────────────────────────────────────
                    _buildRoleCard(
                      context,
                      icon: ImageAssets.franchiseIcon,
                      title: 'Franchise',
                      description:
                      'manage your franchise operations,\norders, and deliveries.',
                      onTap: () { Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OnboardingScreenTwo()),
                    );
              },
                      borderColor: AppColors.quickActionBlue,
                      iconBgColor: AppColors.quickActionBlueBg,
                      titleColor: AppColors.primaryBlue,
                    ),
                    SizedBox(height: height * 0.02),

                    // ── Rider Card ────────────────────────────────────────
                    _buildRoleCard(
                      context,
                      icon: ImageAssets.riderIcon,
                      title: 'Rider',
                      description:
                      'Deliver water, manage deliveries,\nand track your earnings.',
                      onTap: () { Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingScreenThree()),
                      );
                      },
                      borderColor: AppColors.quickActionGreen,
                      iconBgColor: AppColors.quickActionGreenBg,
                      titleColor: AppColors.quickActionGreen,
                    ),
                    SizedBox(height: height * 0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      BuildContext context, {
        required String icon,
        required String title,
        required String description,
        required VoidCallback onTap,
        required Color borderColor,
        required Color iconBgColor,
        required Color titleColor,
      }) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.045),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Icon Container ──────────────────────────────────────────
            Container(
              width: width * 0.14,
              height: width * 0.14,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(
                icon,
                width: width * 0.07,
                height: width * 0.07,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: width * 0.04),

            // ── Text Content ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── Arrow Icon ───────────────────────────────────────────────
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: borderColor,
            ),
          ],
        ),
      ),
    );
  }
}