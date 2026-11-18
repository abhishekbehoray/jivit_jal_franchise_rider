// Screens/RiderScreens/OrderScreens/RiderOrderDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/OrderScreen/OtpScreen.dart';
import 'package:jivit_jal_2/Utils/AgentSocketService.dart';
import 'package:jivit_jal_2/Utils/SocketLogger.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Utils/ImageAssets.dart';
import 'package:jivit_jal_2/Utils/MapLauncher.dart';
import 'package:jivit_jal_2/bloc/rider_order_detail/rider_order_detail_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_order_detail/rider_order_detail_event.dart';
import 'package:jivit_jal_2/bloc/rider_order_detail/rider_order_detail_state.dart';
import 'package:jivit_jal_2/bloc/rider_order_action/rider_order_action_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_order_action/rider_order_action_event.dart';
import 'package:jivit_jal_2/bloc/rider_order_action/rider_order_action_state.dart';
import 'package:jivit_jal_2/data/models/rider_today_order_model.dart';

class RiderOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const RiderOrderDetailScreen({super.key, required this.orderId});

  @override
  State<RiderOrderDetailScreen> createState() => _RiderOrderDetailScreenState();
}

class _RiderOrderDetailScreenState extends State<RiderOrderDetailScreen> {
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    context.read<RiderOrderDetailBloc>().add(RiderOrderDetailFetchRequested(widget.orderId));
  }

  Future<void> _markOutForDelivery() async {
    SocketLogger.event('👆', 'ACTION · Out for Delivery tapped', {
      'orderId': widget.orderId,
    });
    setState(() => _isUpdatingStatus = true);
    final bloc = context.read<RiderOrderActionBloc>();
    bloc.add(RiderOrderStatusUpdateRequested(orderId: widget.orderId, status: 'out_for_delivery'));
    final result = await bloc.stream
        .firstWhere((s) =>
            (s is RiderOrderActionSuccess && s.orderId == widget.orderId) ||
            (s is RiderOrderActionFailure && s.orderId == widget.orderId))
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => RiderOrderActionFailure(
              widget.orderId, 'Request timed out. Please check your connection.'),
        );
    if (!mounted) return;
    setState(() => _isUpdatingStatus = false);

    if (result is RiderOrderActionSuccess) {
      // Order is now out for delivery → start pushing live location to the
      // user app over the socket. widget.orderId is the DeliveryOrder Mongo _id
      // (deliveryOrderId), the same value the user app uses for track_order.
      AgentSocketService().startDeliveryTracking(widget.orderId);
      context.read<RiderOrderDetailBloc>().add(RiderOrderDetailFetchRequested(widget.orderId));
    } else if (result is RiderOrderActionFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showCustomerNotAvailableDialog() async {
    final success = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _RiderCustomerNotAvailableDialog(orderId: widget.orderId),
    );
    if (success == true) {
      SocketLogger.event('👆', 'ACTION · Customer Not Available', {
        'orderId': widget.orderId,
      });
      // Delivery attempt ended (customer not available) → stop live tracking and
      // tell the user app the session is over.
      AgentSocketService().stopDeliveryTracking(emitDone: true);
      if (mounted) {
        context.read<RiderOrderDetailBloc>().add(RiderOrderDetailFetchRequested(widget.orderId));
      }
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp is not installed'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _callPhone(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available'), backgroundColor: Colors.red),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: cleaned);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer'), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToOtpScreen(BuildContext context, String phone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(phoneNumber: phone),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Order Detail',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocBuilder<RiderOrderDetailBloc, RiderOrderDetailState>(
        builder: (context, state) {
          if (state is RiderOrderDetailLoading || state is RiderOrderDetailInitial) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: _appBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is RiderOrderDetailFailure) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: _appBar(),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context
                          .read<RiderOrderDetailBloc>()
                          .add(RiderOrderDetailFetchRequested(widget.orderId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final order = (state as RiderOrderDetailLoaded).order;
          return _buildScaffold(context, order);
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, RiderTodayOrderModel order) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final fullAddress =
        '${order.address.address}, ${order.address.city}, ${order.address.state} - ${order.address.pincode}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Customer Info ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: AppColors.iconGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.customerPhone,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fullAddress,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Navigate & Call Buttons ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Navigate',
                    icon: Icons.navigation_outlined,
                    color: AppColors.primaryBlue,
                    onTap: () => MapLauncher.openDirections(
                      context: context,
                      latitude: order.address.latitude,
                      longitude: order.address.longitude,
                      addressQuery: fullAddress,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: 'Call',
                    icon: Icons.phone_outlined,
                    color: Colors.green,
                    onTap: () {
                      _callPhone(order.customerPhone);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Order Detail ──────────────────────────────────────────────
            const Text(
              'Order Detail',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow('Order Type', _capitalize(order.orderType), isBold: true),
            _buildDivider(),
            _buildDetailRow('Quantity', '${order.jars} x 20L'),
            _buildDivider(),
            _buildDetailRow('Payment Method', order.paymentMethod.toUpperCase()),
            _buildDivider(),
            _buildDetailRow('Order ID', order.orderId),
            _buildDivider(),
            _buildDetailRow('Delivery Time', order.timeSlot),
            const SizedBox(height: 16),

            // ── Call & Message Buttons ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _callPhone(order.customerPhone);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openWhatsApp(order.customerPhone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageAssets.whatsappIcon,
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Message',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Out for Delivery & Mark as Delivered Buttons ────────────────
            Builder(
              builder: (context) {
                final status = order.status.toLowerCase();
                final isOutForDelivery = status == 'out_for_delivery' || status == 'delivered';

                return Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: (_isUpdatingStatus || isOutForDelivery) ? null : _markOutForDelivery,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        disabledForegroundColor: AppColors.borderMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isUpdatingStatus
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isOutForDelivery ? 'Marked Out for Delivery' : 'Out for Delivery',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isOutForDelivery
                                    ? AppColors.borderMedium
                                    : AppColors.primaryBlue,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _navigateToOtpScreen(context, order.customerPhone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Mark as Delivered',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
                );
              },
            ),
            const SizedBox(height: 12),

            // ── Customer Not Available Button ───────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _showCustomerNotAvailableDialog,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Customer Not Available',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label,
      String value, {
        bool isBold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: AppColors.borderLight,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Customer Not Available — Centered Dialog (calls the real reject API)
// ─────────────────────────────────────────────────────────────────────────────

class _RiderCustomerNotAvailableDialog extends StatefulWidget {
  final String orderId;

  const _RiderCustomerNotAvailableDialog({required this.orderId});

  @override
  State<_RiderCustomerNotAvailableDialog> createState() =>
      _RiderCustomerNotAvailableDialogState();
}

class _RiderCustomerNotAvailableDialogState
    extends State<_RiderCustomerNotAvailableDialog> {
  final List<String> _reasons = [
    'Not Home',
    'Refused Delivery',
    'Wrong Address',
    'Safety Concern',
  ];

  String? _selectedReason;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final bloc = context.read<RiderOrderActionBloc>();
    bloc.add(RiderOrderRejectRequested(orderId: widget.orderId, reason: _selectedReason!));
    final result = await bloc.stream
        .firstWhere((s) =>
            (s is RiderOrderActionSuccess && s.orderId == widget.orderId) ||
            (s is RiderOrderActionFailure && s.orderId == widget.orderId))
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => RiderOrderActionFailure(
              widget.orderId, 'Request timed out. Please check your connection.'),
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result is RiderOrderActionSuccess) {
      Navigator.pop(context, true);
    } else if (result is RiderOrderActionFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
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
            // ── Icon ────────────────────────────────────────────────────
            const Icon(
              Icons.person_off_outlined,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),

            // ── Title ───────────────────────────────────────────────────
            const Text(
              'Customer Not Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // ── Subtitle ─────────────────────────────────────────────────
            const Text(
              'Please select a reason for marking this\ndelivery as failed.',
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
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
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
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
