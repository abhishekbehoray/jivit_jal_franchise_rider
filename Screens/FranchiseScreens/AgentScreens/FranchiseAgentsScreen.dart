// Screens/FranchiseScreens/AgentScreens/FranchiseAgentsScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/AgentScreens/AgentOrdersScreen.dart';
import 'package:jivit_jal_2/Screens/CommonScreens/NotificationScreen.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/AgentWidgets/DeliveryAgentCard.dart';
import 'package:jivit_jal_2/bloc/franchise_live_agent/franchise_live_agent_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_live_agent/franchise_live_agent_event.dart';
import 'package:jivit_jal_2/bloc/franchise_live_agent/franchise_live_agent_state.dart';
import 'package:jivit_jal_2/data/models/live_delivery_agent_model.dart';

class FranchiseAgentsScreen extends StatefulWidget {
  const FranchiseAgentsScreen({super.key});

  @override
  State<FranchiseAgentsScreen> createState() => _FranchiseAgentsScreenState();
}

class _FranchiseAgentsScreenState extends State<FranchiseAgentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FranchiseLiveAgentBloc>().add(FranchiseLiveAgentFetchRequested());
  }

  // ─── Map API model to the shape DeliveryAgentCard expects ──────────────
  Map<String, dynamic> _toCardMap(LiveDeliveryAgentModel agent) {
    final status = agent.todayDelivered > 0 && agent.todayDelivered >= agent.todayAssigned
        ? 'delivered'
        : (agent.todayAssigned > 0 ? 'assigned' : '');
    return {
      'name': agent.name,
      'id': agent.mongoId,
      'phone': agent.phone,
      'details': '${agent.todayAssigned} Assigned, ${agent.todayDelivered} Delivered',
      'address': agent.isBlocked ? 'Blocked' : 'Active',
      'status': status,
    };
  }

  Future<void> _onRefresh() async {
    context.read<FranchiseLiveAgentBloc>().add(FranchiseLiveAgentFetchRequested());
    await context.read<FranchiseLiveAgentBloc>().stream.firstWhere(
          (s) => s is FranchiseLiveAgentLoaded || s is FranchiseLiveAgentFailure,
        );
  }

  void _navigateToAgentOrders(Map<String, dynamic> agent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentOrdersScreen(
          agentId: agent['id'] as String,
          agentName: agent['name'] as String,
        ),
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
        title: const Text(
          'LIVE Delivery Agents',
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
          const SizedBox(height: 4),

          // ── Agents List ──────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<FranchiseLiveAgentBloc, FranchiseLiveAgentState>(
              builder: (context, state) {
                if (state is FranchiseLiveAgentLoading || state is FranchiseLiveAgentInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FranchiseLiveAgentFailure) {
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
                              .read<FranchiseLiveAgentBloc>()
                              .add(FranchiseLiveAgentFetchRequested()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final agents = state is FranchiseLiveAgentLoaded ? state.agents : <LiveDeliveryAgentModel>[];
                final mappedAgents = agents.map(_toCardMap).toList();

                if (mappedAgents.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
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
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: width * 0.01),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: mappedAgents.length,
                    itemBuilder: (context, index) {
                      final agent = mappedAgents[index];
                      return DeliveryAgentCard(
                        agent: agent,
                        onTap: () => _navigateToAgentOrders(agent),
                        onView: () => _navigateToAgentOrders(agent),
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