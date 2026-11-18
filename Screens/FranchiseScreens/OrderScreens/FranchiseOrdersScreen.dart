// Screens/FranchiseScreens/OrderScreens/FranchiseOrdersScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/OrderWidgets/OrderCardWidget.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/OrderWidgets/RejectOrderDialog.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/OrderScreens/FranchiseOrderDetailScreen.dart';
import 'package:jivit_jal_2/Screens/CommonScreens/NotificationScreen.dart';
import 'package:jivit_jal_2/bloc/franchise_order_list/franchise_order_list_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_list/franchise_order_list_event.dart';
import 'package:jivit_jal_2/bloc/franchise_order_list/franchise_order_list_state.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_event.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_state.dart';
import 'package:jivit_jal_2/data/models/order_list_item_model.dart';

class FranchiseOrdersScreen extends StatefulWidget {
  final String? initialFilter;

  const FranchiseOrdersScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<FranchiseOrdersScreen> createState() => _FranchiseOrdersScreenState();
}

class _FranchiseOrdersScreenState extends State<FranchiseOrdersScreen> {
  late String _selectedFilter;
  final List<String> _filters = ['All', 'New', 'Accepted', 'Active'];
  String? _processingOrderId;

  @override
  void initState() {
    super.initState();
    // Set initial filter if provided
    _selectedFilter = widget.initialFilter ?? 'All';
    // If the provided filter doesn't exist in the list, default to 'All'
    if (!_filters.contains(_selectedFilter)) {
      _selectedFilter = 'All';
    }
    context
        .read<FranchiseOrderListBloc>()
        .add(FranchiseOrderListFetchRequested(type: _typeForFilter(_selectedFilter)));
  }

  String _typeForFilter(String filter) {
    switch (filter) {
      case 'New':
        return 'new';
      case 'Accepted':
        return 'accepted';
      case 'Active':
        return 'active';
      default:
        return 'all';
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    context
        .read<FranchiseOrderListBloc>()
        .add(FranchiseOrderListFetchRequested(type: _typeForFilter(filter)));
  }

  Future<void> _onRefresh() async {
    context
        .read<FranchiseOrderListBloc>()
        .add(FranchiseOrderListFetchRequested(type: _typeForFilter(_selectedFilter)));
    await context.read<FranchiseOrderListBloc>().stream.firstWhere(
          (s) => s is FranchiseOrderListLoaded || s is FranchiseOrderListFailure,
        );
  }

  // ─── Derive the card's display status from the item + active filter ────
  String _displayStatus(OrderListItemModel item) {
    if (_selectedFilter != 'All') return _typeForFilter(_selectedFilter);
    if (item.approvalStatus == 'pending') return 'new';
    if (item.approvalStatus == 'rejected') return 'rejected';
    if (item.status == 'active') return 'active';
    return 'accepted';
  }

  Map<String, dynamic> _toCardMap(OrderListItemModel item) {
    final addr = item.addressSnapshot;
    return {
      'id': '#${item.id.substring(item.id.length - 6).toUpperCase()}',
      'customer': item.name,
      'phone': item.phone,
      'quantity': '${item.jars} x 20L Jar',
      'address': '${addr.address}, ${addr.city}',
      'amount': '₹${item.totalPrice}',
      'status': _displayStatus(item),
    };
  }

  bool _isSameOrder(FranchiseOrderActionState s, String orderId) {
    if (s is FranchiseOrderActionSuccess) return s.orderId == orderId;
    if (s is FranchiseOrderActionFailure) return s.orderId == orderId;
    return false;
  }

  void _refreshList() {
    context
        .read<FranchiseOrderListBloc>()
        .add(FranchiseOrderListFetchRequested(type: _typeForFilter(_selectedFilter)));
  }

  Future<void> _runAction(OrderListItemModel item, FranchiseOrderActionEvent event) async {
    setState(() => _processingOrderId = item.id);
    final bloc = context.read<FranchiseOrderActionBloc>();
    bloc.add(event);
    final result = await bloc.stream
        .firstWhere((s) => _isSameOrder(s, item.id))
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => FranchiseOrderActionFailure(item.id, 'Request timed out. Please check your connection.'),
        );
    if (!mounted) return;
    setState(() => _processingOrderId = null);

    if (result is FranchiseOrderActionSuccess) {
      // No modal/snackbar on success — just silently refetch so the card
      // smoothly drops out of the current filter (e.g. "New") on its own.
      _refreshList();
    } else if (result is FranchiseOrderActionFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleAccept(OrderListItemModel item) {
    return _runAction(
      item,
      FranchiseOrderAcceptRequested(orderId: item.id, orderType: item.orderType),
    );
  }

  Future<void> _handleReject(OrderListItemModel item, String reason) {
    return _runAction(
      item,
      FranchiseOrderRejectRequested(orderId: item.id, orderType: item.orderType, reason: reason),
    );
  }

  void _showRejectDialog(OrderListItemModel item) {
    showDialog(
      context: context,
      builder: (context) => RejectOrderDialog(
        onRejectSubmit: (reason) => _handleReject(item, reason),
      ),
    );
  }

  Future<void> _navigateToOrderDetail(OrderListItemModel item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FranchiseOrderDetailScreen(
          orderId: item.id,
          source: item.source,
        ),
      ),
    );
    // Refresh on return so an accept/reject made on the detail screen is
    // reflected here immediately.
    if (mounted) _refreshList();
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
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
          // ── Filter Pills (All / New / Accepted / Active) ──────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onFilterSelected(filter),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                      padding: EdgeInsets.symmetric(vertical: width * 0.02),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.04),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        filter,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * 0.032,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),

          // ── Orders List ──────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<FranchiseOrderListBloc, FranchiseOrderListState>(
              builder: (context, state) {
                if (state is FranchiseOrderListLoading || state is FranchiseOrderListInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FranchiseOrderListFailure) {
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
                          onPressed: () => context.read<FranchiseOrderListBloc>().add(
                                FranchiseOrderListFetchRequested(type: _typeForFilter(_selectedFilter)),
                              ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final orders = state is FranchiseOrderListLoaded ? state.orders : <OrderListItemModel>[];

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
                      final item = orders[index];
                      final cardMap = _toCardMap(item);
                      final isNew = cardMap['status'] == 'new';

                      return OrderCardWidget(
                        order: cardMap,
                        onTap: () => _navigateToOrderDetail(item),
                        onReject: isNew ? () => _showRejectDialog(item) : null,
                        onAccept: isNew ? () => _handleAccept(item) : null,
                        isProcessing: _processingOrderId == item.id,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
