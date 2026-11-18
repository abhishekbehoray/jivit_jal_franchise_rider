import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_cod/franchise_cod_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_cod/franchise_cod_event.dart';
import 'package:jivit_jal_2/bloc/franchise_cod/franchise_cod_state.dart';
import 'package:jivit_jal_2/data/models/cod_order_model.dart';

class CODScreen extends StatefulWidget {
  const CODScreen({super.key});

  @override
  State<CODScreen> createState() => _CODScreenState();
}

class _CODScreenState extends State<CODScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FranchiseCodBloc>().add(FranchiseCodFetchRequested());
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min $ampm';
    } catch (_) {
      return iso;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return AppColors.success;
      case 'pending': return Colors.orange;
      case 'failed': return Colors.red;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
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
            'List Of COD Collected',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<FranchiseCodBloc, FranchiseCodState>(
          builder: (context, state) {
            if (state is FranchiseCodLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FranchiseCodFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context
                          .read<FranchiseCodBloc>()
                          .add(FranchiseCodFetchRequested()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is FranchiseCodLoaded) {
              final orders = state.data.orders;

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No COD orders found',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: () async => context
                    .read<FranchiseCodBloc>()
                    .add(FranchiseCodFetchRequested()),
                child: ListView.builder(
                  padding: EdgeInsets.all(width * 0.04),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) =>
                      _buildCodCard(orders[index], width),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildCodCard(CodOrderModel order, double width) {
    final statusColor = _statusColor(order.deliveryStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COD #${order.orderId.length > 8 ? order.orderId.substring(order.orderId.length - 8) : order.orderId}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              if (order.deliveryStatus.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.deliveryStatus,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(order.dateTime),
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoChip(Icons.water_drop_outlined, '${order.jars} Jars × ₹${order.pricePerJar.toStringAsFixed(0)}'),
              Row(
                children: [
                  if (order.paymentStatus.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.paymentStatus.toLowerCase() == 'paid'
                            ? AppColors.success.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.paymentStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: order.paymentStatus.toLowerCase() == 'paid'
                              ? AppColors.success
                              : Colors.orange,
                        ),
                      ),
                    ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}
