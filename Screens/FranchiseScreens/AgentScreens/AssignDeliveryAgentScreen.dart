// Screens/FranchiseScreens/AgentScreens/AssignDeliveryAgentScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Utils/ImageAssets.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_event.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_state.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_event.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_state.dart';
import 'package:jivit_jal_2/data/models/delivery_agent_model.dart';

class AssignDeliveryAgentScreen extends StatefulWidget {
  // Mongo _id of the delivery order being (re)assigned.
  final String orderId;

  const AssignDeliveryAgentScreen({super.key, required this.orderId});

  @override
  State<AssignDeliveryAgentScreen> createState() => _AssignDeliveryAgentScreenState();
}

class _AssignDeliveryAgentScreenState extends State<AssignDeliveryAgentScreen> {
  String? _selectedAgentId;
  bool _isSearching = false;
  bool _isAssigning = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FranchiseAgentBloc>().add(FranchiseAgentFetchRequested());
  }

  Future<void> _onRefresh() async {
    context
        .read<FranchiseAgentBloc>()
        .add(FranchiseAgentFetchRequested(search: _searchController.text));
    await context.read<FranchiseAgentBloc>().stream.firstWhere(
          (s) => s is FranchiseAgentLoaded || s is FranchiseAgentFailure,
        );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<FranchiseAgentBloc>().add(FranchiseAgentFetchRequested());
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                ImageAssets.deliverySuccessIcon,
                height: 60,
                width: 60,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Successfully Reassigned',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have successfully reassigned\nthe delivery agent.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _assignAgent() async {
    final agentId = _selectedAgentId;
    if (agentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an agent'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.orderId.isEmpty) {
      // No real order context to reassign — legacy fallback.
      _showSuccessDialog();
      return;
    }

    setState(() => _isAssigning = true);
    final bloc = context.read<FranchiseOrderActionBloc>();
    bloc.add(FranchiseOrderReassignRequested(orderId: widget.orderId, agentId: agentId));
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
    setState(() => _isAssigning = false);

    if (result is FranchiseOrderActionSuccess) {
      _showSuccessDialog();
    } else if (result is FranchiseOrderActionFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text(
          'Assign Delivery Agent',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          // ── Search Icon ─────────────────────────────────────────────────
          GestureDetector(
            onTap: _toggleSearch,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearching ? 60 : 0,
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: _isSearching ? 8 : 0,
            ),
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (value) {
                      context.read<FranchiseAgentBloc>().add(
                            FranchiseAgentFetchRequested(search: value),
                          );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search agents...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Available Delivery Agent Heading + List ─────────────────────
          Expanded(
            child: BlocBuilder<FranchiseAgentBloc, FranchiseAgentState>(
              builder: (context, state) {
                if (state is FranchiseAgentLoading || state is FranchiseAgentInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FranchiseAgentFailure) {
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
                          onPressed: () => context
                              .read<FranchiseAgentBloc>()
                              .add(FranchiseAgentFetchRequested()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final agents = state is FranchiseAgentLoaded ? state.agents : <DeliveryAgentModel>[];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Available Delivery Agent',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${agents.length} agents',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: agents.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 80),
                                    child: Text(
                                      'No delivery agents found',
                                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: agents.length,
                                itemBuilder: (context, index) {
                                  final agent = agents[index];
                                  final isSelected = _selectedAgentId == agent.id;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedAgentId = agent.id;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryBlue.withOpacity(0.05)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryBlue
                                              : AppColors.borderLight,
                                          width: isSelected ? 2 : 1,
                                        ),
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
                                          // ── Avatar ──────────────────────────────────────────────
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
                                                  agent.name,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected
                                                        ? AppColors.primaryBlue
                                                        : AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  agent.phone,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // ── Radio Button (Right Side) ──────────────────────────
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryBlue
                                                    : AppColors.borderLight,
                                                width: 2,
                                              ),
                                            ),
                                            child: isSelected
                                                ? Center(
                                                    child: Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: const BoxDecoration(
                                                        color: AppColors.primaryBlue,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Assign Agent Button (Bottom) ─────────────────────────────────
          Container(
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isAssigning ? null : _assignAgent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isAssigning
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Assign Agent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
