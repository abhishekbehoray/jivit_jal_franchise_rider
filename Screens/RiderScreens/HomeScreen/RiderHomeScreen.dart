// Screens/RiderScreens/HomeScreens/RiderHomeScreen.dart
import 'package:flutter/material.dart';
import 'package:jivit_jal_2/Widgets/RiderWidgets/HomeWidgets/NextDeliveriesWidget.dart';
import 'package:jivit_jal_2/Widgets/RiderWidgets/HomeWidgets/RiderFailedDeliveryCardWidget.dart';
import 'package:jivit_jal_2/Widgets/RiderWidgets/HomeWidgets/RiderHeaderWidget.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import '../../../Widgets/RiderWidgets/HomeWidgets/HomeBannerWidget.dart';
import '../../../Widgets/RiderWidgets/HomeWidgets/OverviewCardWidget.dart';

class RiderHomeScreen extends StatelessWidget {
  const RiderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.02),

                    // ── Header ──────────────────────────────────────────
                    const RiderHeaderWidget(),
                    SizedBox(height: height * 0.025),

                    // ── Today's Overview card ───────────────────────────
                    const OverviewCardWidget(),
                    SizedBox(height: height * 0.02),

                    // ── Banner ──────────────────────────────────────────
                    const HomeBannerWidget(),
                    SizedBox(height: height * 0.02),

                    // ── Failed Delivery card ────────────────────────────
                    // const RiderFailedDeliveryCardWidget(),
                    // SizedBox(height: height * 0.025),

                    // ── Next Deliveries ─────────────────────────────────
                    const NextDeliveriesWidget(),

                    SizedBox(height: height * 0.025),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}