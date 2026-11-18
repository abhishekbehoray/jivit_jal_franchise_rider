// Screens/FranchiseScreens/OrderScreens/FranchiseOrderDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/AgentScreens/AgentDetailScreen.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/OrderWidgets/RejectOrderDialog.dart';
import 'package:jivit_jal_2/bloc/franchise_order_view/franchise_order_view_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_view/franchise_order_view_event.dart';
import 'package:jivit_jal_2/bloc/franchise_order_view/franchise_order_view_state.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_event.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_state.dart';
import 'package:jivit_jal_2/data/models/order_full_detail_model.dart';

class FranchiseOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String source; // "request" | "subscription"

  const FranchiseOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.source,
  });

  // Sample agent data used for the (still static) post-accept re-assign flow.
  static const Map<String, dynamic> _agentData = {
    'name': 'Rahul Sharma',
    'id': 'AGT-2025678',
    'phone': '+91 98765 43210',
    'details': 'DL 10AA1234, Two Wheeler',
    'address': 'Sector 34, Karol bagh',
    'status': 'assigned',
    'since': '08:15 AM',
    'activeOrders': '12',
    'distance': '2.3 km',
    'totalDeliveries': '420',
    'customer': 'Rohit',
    'area': 'Noida',
  };

  @override
  State<FranchiseOrderDetailScreen> createState() => _FranchiseOrderDetailScreenState();
}

class _FranchiseOrderDetailScreenState extends State<FranchiseOrderDetailScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    context.read<FranchiseOrderViewBloc>().add(
          FranchiseOrderViewFetchRequested(id: widget.orderId, source: widget.source),
        );
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

  String _formatDateTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$min $ampm | ${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  bool _isSameOrder(FranchiseOrderActionState s, String orderId) {
    if (s is FranchiseOrderActionSuccess) return s.orderId == orderId;
    if (s is FranchiseOrderActionFailure) return s.orderId == orderId;
    return false;
  }

  Future<FranchiseOrderActionState> _runAction(
    String orderId,
    FranchiseOrderActionEvent event,
  ) async {
    setState(() => _isProcessing = true);
    final bloc = context.read<FranchiseOrderActionBloc>();
    bloc.add(event);
    final result = await bloc.stream
        .firstWhere((s) => _isSameOrder(s, orderId))
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () =>
              FranchiseOrderActionFailure(orderId, 'Request timed out. Please check your connection.'),
        );
    if (mounted) setState(() => _isProcessing = false);
    return result;
  }

  Future<void> _handleAccept(OrderFullDetailModel order) async {
    final result = await _runAction(
      order.id,
      FranchiseOrderAcceptRequested(orderId: order.id, orderType: order.orderType),
    );
    if (!mounted) return;

    if (result is FranchiseOrderActionSuccess) {
      // No confirmation modal — go straight to the re-assign flow.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AgentDetailScreen(
            agent: FranchiseOrderDetailScreen._agentData,
          ),
        ),
      );
    } else if (result is FranchiseOrderActionFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleReject(OrderFullDetailModel order, String reason) async {
    final result = await _runAction(
      order.id,
      FranchiseOrderRejectRequested(orderId: order.id, orderType: order.orderType, reason: reason),
    );
    if (!mounted) return;

    if (result is FranchiseOrderActionSuccess) {
      // No message — pop straight back; the orders list refetches on return.
      Navigator.pop(context, true);
    } else if (result is FranchiseOrderActionFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
  }

  String _statusLabel(OrderFullDetailModel order) {
    if (order.approvalStatus == 'pending') return 'New';
    if (order.approvalStatus == 'rejected') return 'Rejected';
    return _capitalize(order.status.isNotEmpty ? order.status : order.approvalStatus);
  }

  Color _statusColor(OrderFullDetailModel order) {
    if (order.approvalStatus == 'pending') return AppColors.primaryBlue;
    if (order.approvalStatus == 'rejected') return Colors.red;
    if (order.status == 'active') return AppColors.success;
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Allow back navigation to previous screen
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Order Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<FranchiseOrderViewBloc, FranchiseOrderViewState>(
          builder: (context, state) {
            if (state is FranchiseOrderViewLoading || state is FranchiseOrderViewInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FranchiseOrderViewFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<FranchiseOrderViewBloc>().add(
                            FranchiseOrderViewFetchRequested(id: widget.orderId, source: widget.source),
                          ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final order = (state as FranchiseOrderViewLoaded).order;
            final addr = order.addressSnapshot;
            final isNew = order.approvalStatus == 'pending';

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order ID + Status Badge ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${order.id.substring(order.id.length - 6).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(order).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(order),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(order),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(order.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Customer Card ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.user?.name ?? '—',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.user?.phone ?? '—',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ── Call Button ──────────────────────────────────────────
                        GestureDetector(
                          onTap: () => _callPhone(order.user?.phone ?? ''),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone_outlined,
                              size: 20,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Delivery Address Card ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${addr.address}, ${addr.city}, ${addr.state} - ${addr.pincode}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            // ── Location Navigate Button ──────────────────────────
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Navigating to location...'),
                                    backgroundColor: AppColors.primaryBlue,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.navigation_outlined,
                                  size: 18,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Order Details Card ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          'Plan Type',
                          _capitalize(order.planType ?? order.orderType),
                        ),
                        _buildDivider(),
                        _buildDetailRow(
                          'Start Date',
                          _formatDate(order.startDate ?? order.deliveryDate),
                        ),
                        _buildDivider(),
                        _buildDetailRow('Time Slot', order.timeSlot.isNotEmpty ? order.timeSlot : '—'),
                        _buildDivider(),
                        _buildDetailRow('Quantity', '${order.jars} x 20L Jar'),
                        _buildDivider(),
                        _buildDetailRowWithColor(
                          'Plan Status',
                          _capitalize(order.status),
                          _statusColor(order),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Action Buttons ─────────────────────────────────────────────
                  if (isNew)
                    _isProcessing
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => RejectOrderDialog(
                                        onRejectSubmit: (reason) => _handleReject(order, reason),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _handleAccept(order),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Accept',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithColor(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
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
