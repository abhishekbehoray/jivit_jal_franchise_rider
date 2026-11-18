import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/OrderScreen/EmptyBottleCollectionScreen.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Utils/ImageAssets.dart';

class DeliverySuccessScreen extends StatelessWidget {
  final String customerName;
  final String quantity;
  final String paymentMethod;
  final String orderId;
  final String deliveryTime;
  final String notes;

  const DeliverySuccessScreen({
    super.key,
    this.customerName = 'Amit Sharma',
    this.quantity = '2 x 20L',
    this.paymentMethod = 'COD',
    this.orderId = 'ORD-12345',
    this.deliveryTime = '10:00 AM – 12:00 PM',
    this.notes = 'Please ring the bell',
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ── Green Container (Full Width, Top) ──────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.all(width * 0.06),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Success Icon ──────────────────────────────────
                      Image.asset(
                        ImageAssets.successIconTwo,
                        width: width * 0.15,
                        height: width * 0.15,
                      ),
                      SizedBox(height: height * 0.015),

                      // ── Title ──────────────────────────────────────────
                      const Text(
                        'Delivery Successful!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Subtitle ───────────────────────────────────────
                      const Text(
                        'Order has been delivered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: height * 0.025),

                      // ── White Card ─────────────────────────────────────
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _DetailRow(
                              label: 'Customer Name',
                              value: customerName,
                              isFirst: true,
                              width: width,
                            ),
                            _DetailRow(
                              label: 'Quantity',
                              value: quantity,
                              width: width,
                            ),
                            _DetailRow(
                              label: 'Payment Method',
                              value: paymentMethod,
                              width: width,
                            ),
                            _DetailRow(
                              label: 'Order ID',
                              value: orderId,
                              width: width,
                            ),
                            _DetailRow(
                              label: 'Delivery Time',
                              value: deliveryTime,
                              width: width,
                            ),
                            _DetailRow(
                              label: 'Notes',
                              value: notes,
                              isLast: true,
                              width: width,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                    ],
                  ),
                ),
              ),
            ),

            // ── Buttons Section (Below Green) ────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ── Back to Orders Button ──────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Back to Orders',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.012),

                    // ── Collect Empty Bottles Button ──────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const EmptyBottleCollectionScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Collect Empty Bottles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
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

// ─────────────────────────────────────────────────────────────────────────────
// Detail row widget
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;
  final double width;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: width * 0.035,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderLight,
            indent: width * 0.05,
            endIndent: width * 0.05,
          ),
      ],
    );
  }
}