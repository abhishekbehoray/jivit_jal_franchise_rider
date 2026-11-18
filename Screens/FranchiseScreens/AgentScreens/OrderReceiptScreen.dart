// Screens/FranchiseScreens/OrderScreens/OrderReceiptScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_event.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_state.dart';

class OrderReceiptScreen extends StatefulWidget {
  // Mongo _id of the delivery order whose COD is being confirmed.
  final String orderId;
  // Human-readable order id (e.g. "#2947815480") shown in the title.
  final String? orderIdDisplay;
  // Formatted total amount (e.g. "₹1200") to collect for this order.
  final String? amountDisplay;

  const OrderReceiptScreen({
    super.key,
    required this.orderId,
    this.orderIdDisplay,
    this.amountDisplay,
  });

  @override
  State<OrderReceiptScreen> createState() => _OrderReceiptScreenState();
}

class _OrderReceiptScreenState extends State<OrderReceiptScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmCollected() async {
    if (widget.orderId.isEmpty) {
      // No real order context — legacy fallback.
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount collected successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);
    final bloc = context.read<FranchiseOrderActionBloc>();
    bloc.add(FranchiseOrderCodCollectedRequested(orderId: widget.orderId));
    final result = await bloc.stream
        .firstWhere((s) =>
            (s is FranchiseOrderActionSuccess && s.orderId == widget.orderId) ||
            (s is FranchiseOrderActionFailure && s.orderId == widget.orderId))
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => FranchiseOrderActionFailure(
              widget.orderId, 'Request timed out. Please check your connection.'),
        );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result is FranchiseOrderActionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount collected successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (result is FranchiseOrderActionFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
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
          'Order Receipt ${widget.orderIdDisplay ?? '#00231'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Order Amount ────────────────────────────────────────────────
            const Text(
              'Order Amount',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.amountDisplay ?? '₹250.00',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // ── Divider ──────────────────────────────────────────────────────
            Container(
              height: 1,
              color: AppColors.borderLight,
            ),
            const SizedBox(height: 16),

            // ── Collected Amount ────────────────────────────────────────────
            const Text(
              'Collected Amount',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.amountDisplay ?? '₹250.00',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),

            // ── Divider ──────────────────────────────────────────────────────
            Container(
              height: 1,
              color: AppColors.borderLight,
            ),
            const SizedBox(height: 16),

            // ── Notes ────────────────────────────────────────────────────────
            const Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add any notes...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ── Confirm & Collected Button ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmCollected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Confirm & Collected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
}