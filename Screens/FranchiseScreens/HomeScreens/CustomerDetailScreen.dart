// Screens/FranchiseScreens/Customers/CustomerDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_customer_history/franchise_customer_history_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_customer_history/franchise_customer_history_event.dart';
import 'package:jivit_jal_2/bloc/franchise_customer_history/franchise_customer_history_state.dart';
import 'package:jivit_jal_2/bloc/franchise_customer_note/franchise_customer_note_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_customer_note/franchise_customer_note_event.dart';
import 'package:jivit_jal_2/bloc/franchise_customer_note/franchise_customer_note_state.dart';
import 'package:jivit_jal_2/data/models/customer_list_item_model.dart';
import 'package:jivit_jal_2/data/models/customer_delivery_history_model.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerListItemModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  String _selectedHistoryView = 'upcoming'; // 'upcoming' | 'previous'
  bool _hasExistingNote = false;
  bool _isEditingNote = true;

  @override
  void initState() {
    super.initState();
    context
        .read<FranchiseCustomerHistoryBloc>()
        .add(FranchiseCustomerHistoryFetchRequested(widget.customer.customerId));
    context
        .read<FranchiseCustomerNoteBloc>()
        .add(FranchiseCustomerNoteFetchRequested(widget.customer.customerId));
  }

  void _saveNote() {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    context.read<FranchiseCustomerNoteBloc>().add(
          FranchiseCustomerNoteSaveRequested(
            customerId: widget.customer.customerId,
            note: note,
            isUpdate: _hasExistingNote,
          ),
        );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]}, ${dt.year} | $hour:$min $ampm';
    } catch (_) {
      return iso;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final customer = widget.customer;
    final isActive = customer.subscriptionStatus.toLowerCase() == 'active';
    final statusColor = isActive ? AppColors.success : Colors.orange;

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Customers Details',
            style: TextStyle(
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
              // ── Customer Info ──────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
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
                              customer.phone,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _capitalize(customer.subscriptionStatus),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Plan Info ──────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Plan', _capitalize(customer.planType)),
                  const SizedBox(height: 4),
                  _buildInfoRow('Start Date', _formatDate(customer.joinedAt)),
                  const SizedBox(height: 4),
                  _buildInfoRowWithIcon(
                    label: 'City',
                    value: customer.city,
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Upcoming Order & Previous Orders ───────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Upcoming Order',
                      icon: Icons.calendar_today,
                      isPrimary: _selectedHistoryView == 'upcoming',
                      onTap: () => setState(() => _selectedHistoryView = 'upcoming'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Previous Orders',
                      icon: Icons.history,
                      isPrimary: _selectedHistoryView == 'previous',
                      onTap: () => setState(() => _selectedHistoryView = 'previous'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Order History (toggled by buttons above) ────────────────
              BlocBuilder<FranchiseCustomerHistoryBloc, FranchiseCustomerHistoryState>(
                builder: (context, state) {
                  if (state is FranchiseCustomerHistoryLoading ||
                      state is FranchiseCustomerHistoryInitial) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is FranchiseCustomerHistoryFailure) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => context
                                .read<FranchiseCustomerHistoryBloc>()
                                .add(FranchiseCustomerHistoryFetchRequested(
                                    widget.customer.customerId)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final history = state is FranchiseCustomerHistoryLoaded
                      ? state.history
                      : null;

                  if (_selectedHistoryView == 'upcoming') {
                    final today = history?.todayDelivery;
                    if (today == null) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No upcoming order',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return _buildOrderCard(today);
                  } else {
                    final previous = history?.previousDeliveries ?? [];
                    if (previous.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No previous orders',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return Column(children: previous.map(_buildOrderCard).toList());
                  }
                },
              ),
              const SizedBox(height: 16),

              // ── Add Note ──────────────────────────────────────────────────
              BlocListener<FranchiseCustomerNoteBloc, FranchiseCustomerNoteState>(
                listener: (context, state) {
                  if (state is FranchiseCustomerNoteLoaded) {
                    final hasNote = state.note != null && state.note!.isNotEmpty;
                    _noteController.text = state.note ?? '';
                    setState(() {
                      _hasExistingNote = hasNote;
                      _isEditingNote = !hasNote;
                    });
                  } else if (state is FranchiseCustomerNoteSaveSuccess) {
                    setState(() {
                      _hasExistingNote = true;
                      _isEditingNote = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note saved successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else if (state is FranchiseCustomerNoteSaveFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _hasExistingNote ? 'Note' : 'Add a Note...',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_hasExistingNote && !_isEditingNote)
                          GestureDetector(
                            onTap: () => setState(() => _isEditingNote = true),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(10),
                        color: _isEditingNote ? Colors.white : AppColors.background,
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 3,
                        readOnly: !_isEditingNote,
                        decoration: const InputDecoration(
                          hintText: 'Type here...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Save Note Button ─────────────────────────────────────────
              if (_isEditingNote)
              BlocBuilder<FranchiseCustomerNoteBloc, FranchiseCustomerNoteState>(
                builder: (context, state) {
                  final isSaving = state is FranchiseCustomerNoteSaving;
                  return SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Note',
                              style: TextStyle(
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithIcon({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.iconGray,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    bool isPrimary = false,
    VoidCallback? onTap,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onTap ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: onTap ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.05),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: AppColors.borderLight),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildOrderCard(CustomerDeliveryItemModel item) {
    final status = item.deliveryStatus.toLowerCase();
    final isDelivered = status == 'delivered' || status == 'completed';
    final statusColor = isDelivered ? AppColors.success : Colors.orange;
    final statusLabel = _capitalize(item.deliveryStatus.replaceAll('_', ' '));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${item.orderId}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(item.deliveryDate),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (item.timeSlot.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.timeSlot,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            '${item.jars} Jars',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
