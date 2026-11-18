// Screens/FranchiseScreens/ProfileScreens/ZoneDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/AddAreaScreen.dart';
import 'package:jivit_jal_2/bloc/franchise_zone/franchise_zone_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_zone/franchise_zone_event.dart';
import 'package:jivit_jal_2/bloc/franchise_zone/franchise_zone_state.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_event.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_state.dart';
import 'package:jivit_jal_2/data/models/delivery_agent_model.dart';
import 'package:jivit_jal_2/data/models/franchise_city_model.dart';

class ZoneDetailScreen extends StatefulWidget {
  final String zoneName;
  final Color zoneColor;

  const ZoneDetailScreen({
    super.key,
    required this.zoneName,
    required this.zoneColor,
  });

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  int _tabIndex = 0; // 0 = Area, 1 = Riders

  String get _zoneKey => widget.zoneName.split(' ').first.toLowerCase();

  @override
  void initState() {
    super.initState();
    context.read<FranchiseZoneBloc>().add(FranchiseZoneCitiesFetchRequested());
  }

  void _switchTab(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
    if (index == 1) {
      context.read<FranchiseZoneBloc>().add(FranchiseZoneRidersFetchRequested(_zoneKey));
    } else {
      context.read<FranchiseZoneBloc>().add(FranchiseZoneCitiesFetchRequested());
    }
  }

  void _goToAddArea() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAreaScreen(
          zoneName: widget.zoneName,
          zoneKey: _zoneKey,
          zoneColor: widget.zoneColor,
        ),
      ),
    );
    if (mounted) {
      context.read<FranchiseZoneBloc>().add(FranchiseZoneCitiesFetchRequested());
    }
  }

  void _showAddRiderDialog() {
    context.read<FranchiseAgentBloc>().add(FranchiseAgentFetchRequested());

    showDialog(
      context: context,
      builder: (ctx) => _AddRiderDialog(
        zoneKey: _zoneKey,
        onAdd: (agentIds) {
          context.read<FranchiseZoneBloc>().add(
                FranchiseZoneRidersAddRequested(
                    zone: _zoneKey, deliveryAgentIds: agentIds),
              );
        },
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.zoneName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // ── Toggle Tabs ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.015),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTab('Area', 0, Icons.location_on_outlined),
                    _buildTab('Riders', 1, Icons.delivery_dining_outlined),
                  ],
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: BlocConsumer<FranchiseZoneBloc, FranchiseZoneState>(
                listener: (context, state) {
                  if (state is FranchiseZoneRidersAddSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rider added to zone successfully!')),
                    );
                  } else if (state is FranchiseZoneRidersAddFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (_tabIndex == 0) {
                    return _buildAreaTab(state, width, height);
                  } else {
                    return _buildRidersTab(state, width, height);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ── Area Tab ─────────────────────────────────────────────────────────────
  Widget _buildAreaTab(FranchiseZoneState state, double width, double height) {
    final isAdding = state is FranchiseZoneCityAdding;

    final allCities = state is FranchiseZoneCitiesLoaded ? state.response.cities
        : state is FranchiseZoneCityAdding ? state.response.cities
        : state is FranchiseZoneCityAddSuccess ? state.response.cities
        : state is FranchiseZoneCityAddFailure ? state.response.cities
        : null;

    final zoneCities = allCities?.where((c) => c.zone.toLowerCase() == _zoneKey).toList() ?? [];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isAdding ? null : _goToAddArea,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Add Area',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: state is FranchiseZoneLoading
              ? const Center(child: CircularProgressIndicator())
              : state is FranchiseZoneFailure
                  ? Center(child: Text(state.message, style: const TextStyle(color: Colors.red)))
                  : zoneCities.isEmpty
                      ? _emptyState('No areas added yet', 'Tap "Add Area" to add a new area',
                          Icons.location_off_outlined)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                          itemCount: zoneCities.length,
                          itemBuilder: (_, i) {
                            final city = zoneCities[i];
                            return _AreaCard(
                              name: city.cityName,
                              stateName: city.state,
                              pincode: city.pincode,
                              color: widget.zoneColor,
                            );
                          },
                        ),
        ),
      ],
    );
  }

  // ── Riders Tab ────────────────────────────────────────────────────────────
  Widget _buildRidersTab(FranchiseZoneState state, double width, double height) {
    final isAdding = state is FranchiseZoneRidersAdding;

    final riders = state is FranchiseZoneRidersLoaded ? state.response.riders
        : state is FranchiseZoneRidersAdding ? state.response.riders
        : state is FranchiseZoneRidersAddSuccess ? state.response.riders
        : state is FranchiseZoneRidersAddFailure ? state.response.riders
        : null;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isAdding ? null : _showAddRiderDialog,
              icon: isAdding
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.person_add_outlined, color: Colors.white, size: 18),
              label: Text(isAdding ? 'Adding...' : 'Add Rider',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: state is FranchiseZoneRidersLoading
              ? const Center(child: CircularProgressIndicator())
              : state is FranchiseZoneRidersFailure
                  ? Center(child: Text(state.message, style: const TextStyle(color: Colors.red)))
                  : riders == null
                      ? const Center(child: CircularProgressIndicator())
                      : riders.isEmpty
                          ? _emptyState('No riders assigned', 'Tap "Add Rider" to assign a rider',
                              Icons.delivery_dining_outlined)
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                              itemCount: riders.length,
                              itemBuilder: (_, i) => _RiderCard(rider: riders[i]),
                            ),
        ),
      ],
    );
  }

  Widget _emptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// ── Area Card ─────────────────────────────────────────────────────────────
class _AreaCard extends StatelessWidget {
  final String name;
  final String stateName;
  final String pincode;
  final Color color;

  const _AreaCard({
    required this.name,
    required this.stateName,
    required this.pincode,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.location_on_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('$stateName · $pincode',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Rider Dialog (multi-select) ──────────────────────────────────────
class _AddRiderDialog extends StatefulWidget {
  final String zoneKey;
  final void Function(List<String> agentIds) onAdd;

  const _AddRiderDialog({required this.zoneKey, required this.onAdd});

  @override
  State<_AddRiderDialog> createState() => _AddRiderDialogState();
}

class _AddRiderDialogState extends State<_AddRiderDialog> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FranchiseAgentBloc, FranchiseAgentState>(
      builder: (context, agentState) {
        final isLoading = agentState is FranchiseAgentLoading;
        final agents = agentState is FranchiseAgentLoaded
            ? agentState.agents
            : agentState is FranchiseAgentCreateSuccess
                ? agentState.agents
                : <DeliveryAgentModel>[];

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            'Add Riders to Zone',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: isLoading
                ? const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : agents.isEmpty
                    ? const Text(
                        'No delivery agents found.\nCreate agents first from Delivery Agent screen.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: agents.length,
                          itemBuilder: (_, i) {
                            final agent = agents[i];
                            final isChecked = _selectedIds.contains(agent.id);
                            return InkWell(
                              onTap: () => setState(() {
                                isChecked
                                    ? _selectedIds.remove(agent.id)
                                    : _selectedIds.add(agent.id);
                              }),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isChecked,
                                      activeColor: AppColors.primaryBlue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4)),
                                      onChanged: (_) => setState(() {
                                        isChecked
                                            ? _selectedIds.remove(agent.id)
                                            : _selectedIds.add(agent.id);
                                      }),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            agent.name,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary),
                                          ),
                                          Text(
                                            agent.phone,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: agent.isActive
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        agent.isActive ? 'Active' : 'Blocked',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: agent.isActive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      widget.onAdd(_selectedIds.toList());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _selectedIds.isEmpty
                    ? 'Add'
                    : 'Add (${_selectedIds.length})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
class _RiderCard extends StatelessWidget {
  final ZoneRiderModel rider;
  const _RiderCard({required this.rider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delivery_dining_outlined, color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rider.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(rider.phone,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: rider.isBlocked
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rider.isBlocked ? 'Blocked' : 'Active',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: rider.isBlocked ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
