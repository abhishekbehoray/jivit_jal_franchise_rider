// Screens/RiderScreens/OrderScreens/RiderOrdersScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jivit_jal_2/Screens/CommonScreens/NotificationScreen.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/OrderScreen/RiderOrderDetailScreen.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/OrderScreen/RiderRescheduleOrderScreen.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Utils/MapLauncher.dart';
import 'package:jivit_jal_2/Widgets/RiderWidgets/OrderWidget/FilterChipWidget.dart';
import 'package:jivit_jal_2/bloc/rider_order_list/rider_order_list_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_order_list/rider_order_list_event.dart';
import 'package:jivit_jal_2/bloc/rider_order_list/rider_order_list_state.dart';
import 'package:jivit_jal_2/data/models/rider_today_order_model.dart';
import '../../../Widgets/RiderWidgets/OrderWidget/OrderCardWidget.dart';

class RiderOrdersScreen extends StatefulWidget {
  const RiderOrdersScreen({super.key});

  @override
  State<RiderOrdersScreen> createState() => _RiderOrdersScreenState();
}

class _RiderOrdersScreenState extends State<RiderOrdersScreen> {
  // ─── Filter Variables ────────────────────────────────────────────────────
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Delivered'];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    context.read<RiderOrderListBloc>().add(
          RiderOrderListFetchRequested(filter: _selectedFilter.toLowerCase()),
        );
  }

  Future<void> _onRefresh() async {
    _fetchOrders();
    await context.read<RiderOrderListBloc>().stream.firstWhere(
          (s) => s is RiderOrderListLoaded || s is RiderOrderListFailure,
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

  void _onFilterSelected(String filter) {
    setState(() => _selectedFilter = filter);
    _fetchOrders();
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _statusLabel(String status) {
    final cleaned = status.replaceAll('_', ' ');
    return cleaned.isEmpty
        ? cleaned
        : cleaned.split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  void _navigateToNotification(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  }

  void _navigateToOrderDetail(BuildContext context, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiderOrderDetailScreen(orderId: orderId),
      ),
    );
  }

  void _navigateToRescheduleOrder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RiderRescheduleOrderScreen(),
      ),
    );
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            // ── Notification Icon ──────────────────────────────────────
            GestureDetector(
              onTap: () => _navigateToNotification(context),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Filter Chips ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.015,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return FilterChipWidget(
                      label: filter,
                      isSelected: isSelected,
                      onTap: () => _onFilterSelected(filter),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Order List ──────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<RiderOrderListBloc, RiderOrderListState>(
                builder: (context, state) {
                  if (state is RiderOrderListLoading || state is RiderOrderListInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RiderOrderListFailure) {
                    return Center(
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
                            onPressed: _fetchOrders,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final orders = state is RiderOrderListLoaded
                      ? state.orders
                      : <RiderTodayOrderModel>[];

                  if (orders.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: height * 0.2),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No orders found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final isReschedule = order.status.toLowerCase() == 'reschedule';

                        return OrderCardWidget(
                          customerName: order.customerName,
                          address: '${order.address.address}, ${order.address.city}',
                          items: '${order.jars} Jars',
                          date: '${_formatDate(order.deliveryDate)}, ${order.timeSlot}',
                          paymentMode: order.paymentMethod.toUpperCase(),
                          status: _statusLabel(order.status),
                          onTap: () {
                            if (isReschedule) {
                              _navigateToRescheduleOrder(context);
                            } else {
                              _navigateToOrderDetail(context, order.deliveryOrderId);
                            }
                          },
                          onNavigate: () => MapLauncher.openDirections(
                            context: context,
                            latitude: order.address.latitude,
                            longitude: order.address.longitude,
                            addressQuery: '${order.address.address}, ${order.address.city}',
                          ),
                          onCall: () => _callPhone(order.customerPhone),
                          onViewDetails: () {
                            if (isReschedule) {
                              _navigateToRescheduleOrder(context);
                            } else {
                              _navigateToOrderDetail(context, order.deliveryOrderId);
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
