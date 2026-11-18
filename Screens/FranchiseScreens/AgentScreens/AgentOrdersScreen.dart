// Screens/FranchiseScreens/AgentScreens/AgentOrdersScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/AgentScreens/AgentDetailScreen.dart';
import 'package:jivit_jal_2/bloc/franchise_agent_orders/franchise_agent_orders_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_agent_orders/franchise_agent_orders_event.dart';
import 'package:jivit_jal_2/bloc/franchise_agent_orders/franchise_agent_orders_state.dart';
import 'package:jivit_jal_2/data/models/today_order_model.dart';

class AgentOrdersScreen extends StatefulWidget {
  final String agentId;
  final String agentName;

  const AgentOrdersScreen({
    super.key,
    required this.agentId,
    required this.agentName,
  });

  @override
  State<AgentOrdersScreen> createState() => _AgentOrdersScreenState();
}

class _AgentOrdersScreenState extends State<AgentOrdersScreen> {
  static const List<Map<String, String>> _statusFilters = [
    {'label': 'All', 'value': ''},
    {'label': 'Order Created', 'value': 'order_created'},
    {'label': 'Accepted', 'value': 'accepted'},
    {'label': 'Assigned', 'value': 'assigned'},
    {'label': 'Out of Delivery', 'value': 'out_of_delivery'},
    {'label': 'Delivered', 'value': 'delivered'},
    {'label': 'Failed', 'value': 'failed'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    context
        .read<FranchiseAgentOrdersBloc>()
        .add(FranchiseAgentOrdersFetchRequested(agentId: widget.agentId));
  }

  void _onFilterSelected(String status) {
    setState(() {
      _selectedStatus = status;
    });
    context.read<FranchiseAgentOrdersBloc>().add(
          FranchiseAgentOrdersFetchRequested(agentId: widget.agentId, status: status),
        );
  }

  Future<void> _onRefresh() async {
    context.read<FranchiseAgentOrdersBloc>().add(
          FranchiseAgentOrdersFetchRequested(agentId: widget.agentId, status: _selectedStatus),
        );
    await context.read<FranchiseAgentOrdersBloc>().stream.firstWhere(
          (s) => s is FranchiseAgentOrdersLoaded || s is FranchiseAgentOrdersFailure,
        );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'out_of_delivery':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      case 'accepted':
      case 'assigned':
        return AppColors.primaryBlue;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    return _statusFilters.firstWhere(
      (f) => f['value'] == status,
      orElse: () => {'label': status},
    )['label']!;
  }

  void _navigateToOrderDetail(TodayOrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentDetailScreen(orderId: order.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${widget.agentName}'s Orders",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          // ── Filter Pills ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _statusFilters.map((filter) {
                  final isSelected = _selectedStatus == filter['value'];
                  return GestureDetector(
                    onTap: () => _onFilterSelected(filter['value']!),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.015),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.035,
                        vertical: width * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.04),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        filter['label']!,
                        style: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ── Orders List ───────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<FranchiseAgentOrdersBloc, FranchiseAgentOrdersState>(
              builder: (context, state) {
                if (state is FranchiseAgentOrdersLoading || state is FranchiseAgentOrdersInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FranchiseAgentOrdersFailure) {
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
                          onPressed: () => context.read<FranchiseAgentOrdersBloc>().add(
                                FranchiseAgentOrdersFetchRequested(
                                  agentId: widget.agentId,
                                  status: _selectedStatus,
                                ),
                              ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final orders = state is FranchiseAgentOrdersLoaded ? state.orders : <TodayOrderModel>[];

                if (orders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: Text(
                              'No orders found',
                              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: width * 0.01),
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return GestureDetector(
                      onTap: () => _navigateToOrderDetail(order),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order.orderId}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(order.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _statusLabel(order.status),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _statusColor(order.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.local_drink_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${order.jars} Jars • ${order.orderType}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  order.timeSlot,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
