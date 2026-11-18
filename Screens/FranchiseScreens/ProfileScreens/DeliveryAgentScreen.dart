import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_event.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_state.dart';
import 'package:jivit_jal_2/data/models/delivery_agent_model.dart';

class DeliveryAgentScreen extends StatefulWidget {
  const DeliveryAgentScreen({super.key});

  @override
  State<DeliveryAgentScreen> createState() => _DeliveryAgentScreenState();
}

class _DeliveryAgentScreenState extends State<DeliveryAgentScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<FranchiseAgentBloc>().state;
    if (state is FranchiseAgentInitial || state is FranchiseAgentFailure) {
      context.read<FranchiseAgentBloc>().add(FranchiseAgentFetchRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _showAddAgentDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: context.read<FranchiseAgentBloc>(),
        child: BlocConsumer<FranchiseAgentBloc, FranchiseAgentState>(
          listener: (ctx, state) {
            if (state is FranchiseAgentCreateSuccess) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delivery Agent Created Successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is FranchiseAgentCreateFailure) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (ctx, state) {
            final isCreating = state is FranchiseAgentCreating;
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text('Create Delivery Agent ID',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 20),
                    _dialogField('Name', 'Enter Name', nameCtrl),
                    const SizedBox(height: 14),
                    _dialogField('Mobile Number', 'Enter Mobile Number', phoneCtrl,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 14),
                    _dialogField('Email ID', 'Enter email id', emailCtrl,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _dialogField('Password', 'Enter Password', passCtrl, obscure: true),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isCreating ? null : () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.borderLight),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isCreating
                                ? null
                                : () {
                                    final name = nameCtrl.text.trim();
                                    final phone = phoneCtrl.text.trim();
                                    final email = emailCtrl.text.trim();
                                    final pass = passCtrl.text.trim();
                                    if (name.isEmpty || phone.isEmpty || email.isEmpty || pass.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('All fields are required')),
                                      );
                                      return;
                                    }
                                    ctx.read<FranchiseAgentBloc>().add(
                                          FranchiseAgentCreateRequested(
                                            name: name,
                                            email: email,
                                            phone: phone,
                                            password: pass,
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isCreating
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Confirm',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _dialogField(String label, String hint, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryBlue)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  List<DeliveryAgentModel> _extractAgents(FranchiseAgentState state) {
    if (state is FranchiseAgentLoaded) return state.agents;
    if (state is FranchiseAgentCreating) return state.agents;
    if (state is FranchiseAgentCreateSuccess) return state.agents;
    if (state is FranchiseAgentCreateFailure) return state.agents;
    if (state is FranchiseAgentToggling) return state.agents;
    if (state is FranchiseAgentToggleFailure) return state.agents;
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: _isSearching
              ? Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (value) => context
                              .read<FranchiseAgentBloc>()
                              .add(FranchiseAgentFetchRequested(search: value)),
                          decoration: const InputDecoration(
                            hintText: 'Search agents...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleSearch,
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : const Text('Delivery Agent',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
          centerTitle: !_isSearching,
          actions: [
            if (!_isSearching)
              IconButton(
                onPressed: _toggleSearch,
                icon: const Icon(Icons.search, color: AppColors.textPrimary),
              ),
          ],
        ),
        body: BlocConsumer<FranchiseAgentBloc, FranchiseAgentState>(
          listener: (context, state) {
            if (state is FranchiseAgentToggleFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is FranchiseAgentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FranchiseAgentFailure) {
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
                          .read<FranchiseAgentBloc>()
                          .add(FranchiseAgentFetchRequested()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final agents = _extractAgents(state);

            if (agents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off_outlined,
                        size: 64, color: AppColors.iconGray),
                    const SizedBox(height: 16),
                    const Text('No delivery agents found',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: width * 0.05,
                right: width * 0.05,
                top: height * 0.02,
                bottom: height * 0.1,
              ),
              itemCount: agents.length,
              // key by agent.id so Flutter reuses the same StatefulWidget
              // instance per agent and doesn't reset local state on rebuild
              itemBuilder: (context, index) => _AgentCard(
                key: ValueKey(agents[index].id),
                agent: agents[index],
                width: width,
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddAgentDialog,
          backgroundColor: AppColors.primaryBlue,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

// ── Per-card StatefulWidget ───────────────────────────────────────────────────
// Owns its own local isActive + isToggling so BLoC rebuilds never affect
// other cards' switch animation or color.
class _AgentCard extends StatefulWidget {
  final DeliveryAgentModel agent;
  final double width;

  const _AgentCard({required super.key, required this.agent, required this.width});

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard> {
  late bool _isActive;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.agent.isActive;
  }

  @override
  void didUpdateWidget(_AgentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync from BLoC only when not mid-toggle (handles revert on failure)
    if (!_isToggling) {
      _isActive = widget.agent.isActive;
    }
  }

  Future<void> _handleToggle() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);
    context
        .read<FranchiseAgentBloc>()
        .add(FranchiseAgentToggleStatusRequested(widget.agent.id));

    final bloc = context.read<FranchiseAgentBloc>();
    await bloc.stream.firstWhere((s) =>
        s is FranchiseAgentLoaded || s is FranchiseAgentToggleFailure);

    if (mounted) setState(() => _isToggling = false);
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isActive ? AppColors.borderLight : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: width * 0.015),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Agent Rider',
                      style: TextStyle(
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    // Status label with animated color
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w600,
                        color: _isActive ? AppColors.success : Colors.red,
                      ),
                      child: Text(_isActive ? 'Active' : 'Blocked'),
                    ),
                    const SizedBox(width: 4),
                    // Switch — always visible, no loader replacing it
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _isActive,
                        activeColor: AppColors.success,
                        activeTrackColor: AppColors.success.withOpacity(0.3),
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.red.withOpacity(0.3),
                        onChanged: _isToggling ? null : (_) => _handleToggle(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.agent.name,
                  style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.phone, size: width * 0.035, color: AppColors.iconGray),
                    const SizedBox(width: 4),
                    Text(
                      widget.agent.phone,
                      style: TextStyle(
                          fontSize: width * 0.032, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
