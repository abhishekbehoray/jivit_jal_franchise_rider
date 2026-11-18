import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/OrderScreen/ScanQRScreen.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';

class EmptyBottleCollectionScreen extends StatefulWidget {
  const EmptyBottleCollectionScreen({super.key});

  @override
  State<EmptyBottleCollectionScreen> createState() =>
      _EmptyBottleCollectionScreenState();
}

class _EmptyBottleCollectionScreenState
    extends State<EmptyBottleCollectionScreen> {
  final TextEditingController _bottleCountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCondition = 'Good';
  final List<String> _conditions = ['Good', 'Damaged', 'Dirty', 'Broken'];

  @override
  void dispose() {
    _bottleCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleScanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanQRScreen(),
      ),
    );
  }

  void _handleBackToHome() {
    Navigator.pop(context);
  }

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
          title: Text(
            'Collect Empty Bottles',
            style: TextStyle(
              fontSize: width * 0.05,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Scrollable content ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Scan QR button ──────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: OutlinedButton.icon(
                        onPressed: _handleScanQR,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(
                          Icons.qr_code_scanner,
                          color: AppColors.primaryBlue,
                          size: width * 0.05,
                        ),
                        label: Text(
                          'Scan the QR',
                          style: TextStyle(
                            fontSize: width * 0.038,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),

                    // ── Total Bottle ────────────────────────────────────
                    Text(
                      'Total Bottle',
                      style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    TextField(
                      controller: _bottleCountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Count of bottle',
                        hintStyle: TextStyle(
                          fontSize: width * 0.035,
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.018,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.025),

                    // ── Condition ───────────────────────────────────────
                    Text(
                      'Condition',
                      style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: width * 0.05,
                      ),
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.018,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      items: _conditions
                          .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCondition = value);
                        }
                      },
                    ),
                    SizedBox(height: height * 0.025),

                    // ── Notes (Optional) ────────────────────────────────
                    Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    TextField(
                      controller: _notesController,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add any notes...',
                        hintStyle: TextStyle(
                          fontSize: width * 0.035,
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.018,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Back to Home button ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                width * 0.04,
                height * 0.01,
                width * 0.04,
                height * 0.04,
              ),
              child: SizedBox(
                width: double.infinity,
                height: height * 0.065,
                child: ElevatedButton(
                  onPressed: _handleBackToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Collect',
                    style: TextStyle(
                      fontSize: width * 0.04,
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