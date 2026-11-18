import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/OrderScreen/CODPaymentScreen.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/OrderScreen/ScheduleReattemptScreen.dart';
import 'package:jivit_jal_2/Utils/AgentSocketService.dart';
import 'package:jivit_jal_2/Utils/SocketLogger.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Utils/ImageAssets.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    this.phoneNumber = '+91 98765 43210',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  // ─── Global Variables ────────────────────────────────────────────────────
  String _phoneNumber = '+91 98765 43210';

  // OTP controllers
  final List<TextEditingController> _otpControllers = List.generate(
    4,
        (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
        (_) => FocusNode(),
  );

  // Timer
  static const int _initialSeconds = 300; // 5 minutes
  int _secondsRemaining = _initialSeconds;
  Timer? _timer;
  bool _isResendDisabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber.isNotEmpty) {
      _phoneNumber = widget.phoneNumber;
    }
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isResendDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && value.length > 1) {
      _otpControllers[index].text = value.substring(value.length - 1);
      _otpControllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _otpControllers[index].text.length),
      );
    }
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _otpControllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _handleContinue() {
    final otpString = _otpControllers.map((c) => c.text).join();
    if (otpString.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the complete 4‑digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        SocketLogger.event('👆', 'ACTION · OTP verified → Delivered', {
          'activeOrderId': AgentSocketService().activeOrderId ?? '(none)',
        });
        // OTP verified → delivery complete. Stop live tracking and notify the
        // user app. The socket service already knows which order is active.
        AgentSocketService().stopDeliveryTracking(emitDone: true);
        // Navigate to CODPaymentScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CODPaymentScreen(),
          ),
        );
      }
    });
  }

  void _handleResend() {
    if (_isResendDisabled) return;
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {
      _secondsRemaining = _initialSeconds;
      _isResendDisabled = true;
    });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('New OTP sent to your phone'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleCustomerNotAvailable() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const _CustomerNotAvailableDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // ── Scrollable Content ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.04),

                    // ── OTP Banner Image ──────────────────────────────────
                    Image.asset(
                      ImageAssets.otpBanner,
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.18,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),

                    // ── Title ──────────────────────────────────────────────
                    const Text(
                      'OTP Verification',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Subtitle with Phone Number ────────────────────────
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Enter the 4-digit OTP sent to\n',
                          ),
                          TextSpan(
                            text: _phoneNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ── OTP Input Fields ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          width: 56,
                          height: 64,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: RawKeyboardListener(
                            focusNode: FocusNode(),
                            onKey: (event) => _onKeyEvent(event, index),
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: AppColors.cardBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderLight,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderLight,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) => _onOtpChanged(value, index),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // ── Timer + Resend ─────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'OTP Expires in ${_formatTime(_secondsRemaining)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleResend,
                          child: Text(
                            'Request Resend',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isResendDisabled
                                  ? AppColors.textHint
                                  : AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ── Fixed Bottom Buttons ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24.0),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Continue Button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Customer Not Available Button (Outlined) ────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _handleCustomerNotAvailable,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Customer Not Available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Customer Not Available — Centered Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _CustomerNotAvailableDialog extends StatefulWidget {
  const _CustomerNotAvailableDialog();

  @override
  State<_CustomerNotAvailableDialog> createState() =>
      _CustomerNotAvailableDialogState();
}

class _CustomerNotAvailableDialogState
    extends State<_CustomerNotAvailableDialog> {
  final List<String> _reasons = [
    'Not Home',
    'Refused Delivery',
    'Wrong Address',
    'Safety Concern',
  ];

  String? _selectedReason;
  String? _photoPath;

  void _pickPhoto() async {
    // TODO: wire up image_picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo picker not yet wired up')),
    );
  }

  void _submitFailure() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    Navigator.pop(context); // close dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScheduleReattemptScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Red cross icon ──────────────────────────────────────────
            Image.asset(
              ImageAssets.crossImage,
              width: 64,
              height: 64,
            ),
            const SizedBox(height: 16),

            // ── Title ───────────────────────────────────────────────────
            const Text(
              'Reject Task?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // ── Subtitle ─────────────────────────────────────────────────
            const Text(
              'Please select or enter a reason for\nrejecting this task.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // ── Reason chips — 2×2 grid ───────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.4,
              children: _reasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return GestureDetector(
                  onTap: () => setState(() => _selectedReason = reason),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.borderLight,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      reason,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                        isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Upload Photo Evidence label ────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Upload Photo Evidence',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Dashed upload box ─────────────────────────────────────
            GestureDetector(
              onTap: _pickPhoto,
              child: _DashedBorderBox(
                height: 100,
                child: _photoPath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _photoPath!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 28,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap to Upload Photo',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Action buttons ────────────────────────────────────────
            Row(
              children: [
                // Cancel
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Submit Delivery Failure
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitFailure,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Delivery Failure',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: dashed border container
// ─────────────────────────────────────────────────────────────────────────────

class _DashedBorderBox extends StatelessWidget {
  final double height;
  final Widget child;

  const _DashedBorderBox({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final radius = const Radius.circular(12);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}