// Screens/FranchiseScreens/AgentScreens/AgentDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/AgentScreens/OrderReceiptScreen.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/AgentScreens/AssignDeliveryAgentScreen.dart';
import 'package:jivit_jal_2/bloc/franchise_order_detail/franchise_order_detail_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_detail/franchise_order_detail_event.dart';
import 'package:jivit_jal_2/bloc/franchise_order_detail/franchise_order_detail_state.dart';
import 'package:jivit_jal_2/data/models/order_detail_model.dart';

class AgentDetailScreen extends StatefulWidget {
  // Legacy static entry point (e.g. FranchiseOrderDetailScreen's accept flow).
  final Map<String, dynamic>? agent;
  // Mongo _id of the order — when provided, the screen fetches live data
  // from GET /api/franchise/delivery-agent/today-orders/{orderId}.
  final String? orderId;

  const AgentDetailScreen({
    super.key,
    this.agent,
    this.orderId,
  }) : assert(agent != null || orderId != null, 'Either agent or orderId must be provided');

  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      context.read<FranchiseOrderDetailBloc>().add(FranchiseOrderDetailFetchRequested(widget.orderId!));
    }
  }

  void _refreshOrderDetail() {
    if (widget.orderId != null && widget.orderId!.isNotEmpty && mounted) {
      context.read<FranchiseOrderDetailBloc>().add(FranchiseOrderDetailFetchRequested(widget.orderId!));
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

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  Map<String, dynamic> _mapOrderToData(OrderDetailModel order) {
    final addr = order.customer.addressSnapshot;
    final timeSlotParts = order.timeSlot.split(' - ');
    return {
      'name': order.deliveryAgent?.name ?? '',
      'phone': order.deliveryAgent?.phone ?? '',
      'since': timeSlotParts.isNotEmpty ? timeSlotParts.first : '',
      'id': order.orderId,
      'customer': order.customer.name,
      'area': addr.city,
      'status': order.status,
      'orderIdDisplay': '#${order.orderId}',
      'planType': _capitalize(order.orderType),
      'startDate': _formatDate(order.deliveryDate),
      'orderTimeSlot': order.timeSlot,
      'quantity': '${order.jars} x 20L Jar',
      'planStatusDisplay': _capitalize(order.status),
      if (order.pricing != null) ...{
        'pricePerJar': '₹${order.pricing!.pricePerJar}',
        'totalAmount': '₹${order.pricing!.totalAmount}',
        'paymentMethod': order.pricing!.paymentMethod.toUpperCase(),
        'paymentStatusDisplay': _capitalize(order.pricing!.paymentStatus),
        'codCollected': order.pricing!.codCollectedByFranchise ? 'Yes' : 'No',
        'isPaymentPaid': order.pricing!.paymentStatus.toLowerCase() == 'paid',
        'isCodCollected': order.pricing!.codCollectedByFranchise,
      },
    };
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
        'Assign Delivery Agent',
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
    if (widget.orderId != null) {
      return BlocBuilder<FranchiseOrderDetailBloc, FranchiseOrderDetailState>(
        builder: (context, state) {
          if (state is FranchiseOrderDetailLoading || state is FranchiseOrderDetailInitial) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: _appBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is FranchiseOrderDetailFailure) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: _appBar(),
              body: Center(
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
                      onPressed: () => context
                          .read<FranchiseOrderDetailBloc>()
                          .add(FranchiseOrderDetailFetchRequested(widget.orderId!)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final order = (state as FranchiseOrderDetailLoaded).order;
          return _buildScaffold(_mapOrderToData(order));
        },
      );
    }

    return _buildScaffold(widget.agent ?? {});
  }

  Widget _buildScaffold(Map<String, dynamic> agent) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            // ── Agent Info Card ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
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
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agent['name'] ?? 'Rahul Sharma',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Since ${agent['since'] ?? '08:15 AM'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${agent['id'] ?? 'AGT-YTU'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Online Status Badge ─────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Stats Boxes (Outside the container) ──────────────────────
            Row(
              children: [
                _buildStatBox(
                  value: agent['activeOrders'] ?? '12',
                  label: 'Active orders',
                  icon: Icons.shopping_bag_outlined,
                ),
                _buildStatBox(
                  value: agent['distance'] ?? '2.3 km',
                  label: 'Away',
                  icon: Icons.location_on_outlined,
                ),
                _buildStatBox(
                  value: agent['totalDeliveries'] ?? '420',
                  label: 'Total Deliveries',
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Delivery Details Card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
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
                    'Delivery Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Customer', agent['customer'] ?? 'Rohit'),
                  _buildDivider(),
                  _buildDetailRow('Area', agent['area'] ?? 'Noida'),
                  _buildDivider(),
                  _buildDetailRow('Delivery Status',
                      agent['status'] == 'delivered' ? 'Delivered' : 'In Progress'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Order Details Card ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Order ID', agent['orderIdDisplay'] ?? '#ORD-2025678-003'),
                  _buildDivider(),
                  _buildDetailRow('Plan Type', agent['planType'] ?? 'Daily'),
                  _buildDivider(),
                  _buildDetailRow('Start Date', agent['startDate'] ?? '12/02/2026'),
                  _buildDivider(),
                  _buildDetailRow('Time Slot', agent['orderTimeSlot'] ?? '9 AM - 11 AM'),
                  _buildDivider(),
                  _buildDetailRow('Quantity', agent['quantity'] ?? '2 x 20L Jar'),
                  _buildDivider(),
                  _buildDetailRowWithColor(
                      'Plan Status', agent['planStatusDisplay'] ?? 'Active', AppColors.success),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Pricing Card ──────────────────────────────────────────────
            if (agent.containsKey('pricePerJar'))
              Container(
                padding: const EdgeInsets.all(16),
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
                      'Pricing',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Price per Jar', agent['pricePerJar']),
                    _buildDivider(),
                    _buildDetailRow('Total Amount', agent['totalAmount']),
                    _buildDivider(),
                    _buildDetailRow('Payment Method', agent['paymentMethod']),
                    _buildDivider(),
                    _buildDetailRowWithColor(
                      'Payment Status',
                      agent['paymentStatusDisplay'],
                      agent['paymentStatusDisplay'] == 'Pending' ? Colors.orange : AppColors.success,
                    ),
                    _buildDivider(),
                    _buildDetailRow('COD Collected by Franchise', agent['codCollected']),
                  ],
                ),
              ),
            if (agent.containsKey('pricePerJar')) const SizedBox(height: 16),

            // ── Action Buttons ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _callPhone(agent['phone'] as String? ?? ''),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Call Agent',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignDeliveryAgentScreen(
                            orderId: widget.orderId ?? '',
                          ),
                        ),
                      );
                      _refreshOrderDetail();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Re-assign',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Collected COD Button (Blue) ──────────────────────────────────
            Builder(
              builder: (context) {
                final isPaymentPaid = agent['isPaymentPaid'] as bool? ?? true;
                final isCodCollected = agent['isCodCollected'] as bool? ?? false;
                final canCollect = isPaymentPaid && !isCodCollected;

                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: !canCollect
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderReceiptScreen(
                                  orderId: widget.orderId ?? '',
                                  orderIdDisplay: agent['orderIdDisplay'] as String?,
                                  amountDisplay: agent['totalAmount'] as String?,
                                ),
                              ),
                            );
                            _refreshOrderDetail();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      disabledBackgroundColor: AppColors.borderMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCodCollected ? 'Already Collected' : 'Collected COD',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
