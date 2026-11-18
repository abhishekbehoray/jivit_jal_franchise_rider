// Screens/FranchiseScreens/Customers/CustomersScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/HomeScreens/CustomerDetailScreen.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_plans/franchise_plans_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_plans/franchise_plans_event.dart';
import 'package:jivit_jal_2/bloc/franchise_plans/franchise_plans_state.dart';
import 'package:jivit_jal_2/bloc/franchise_customers/franchise_customers_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_customers/franchise_customers_event.dart';
import 'package:jivit_jal_2/bloc/franchise_customers/franchise_customers_state.dart';
import 'package:jivit_jal_2/data/models/customer_list_item_model.dart';
import 'package:jivit_jal_2/data/models/plan_model.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _selectedPlanId = ''; // '' = All
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FranchisePlansBloc>().add(FranchisePlansFetchRequested());
    _fetchCustomers();
  }

  void _fetchCustomers() {
    context.read<FranchiseCustomersBloc>().add(
          FranchiseCustomersFetchRequested(
            search: _searchQuery,
            planId: _selectedPlanId,
          ),
        );
  }

  Future<void> _onRefresh() async {
    _fetchCustomers();
    await context.read<FranchiseCustomersBloc>().stream.firstWhere(
          (s) => s is FranchiseCustomersLoaded || s is FranchiseCustomersFailure,
        );
  }

  void _onFilterSelected(String label, String planId) {
    setState(() {
      _selectedFilter = label;
      _selectedPlanId = planId;
    });
    _fetchCustomers();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _fetchCustomers();
      }
    });
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                const Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _fetchCustomers();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _toggleSearch,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
              : const Text(
            'Customers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: !_isSearching,
          actions: [
            if (!_isSearching)
              IconButton(
                onPressed: _toggleSearch,
                icon: const Icon(
                  Icons.search,
                  color: AppColors.textPrimary,
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // ── Filter Chips (plan names) ─────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.015,
              ),
              child: BlocBuilder<FranchisePlansBloc, FranchisePlansState>(
                builder: (context, state) {
                  final plans = state is FranchisePlansLoaded
                      ? state.plans
                      : <PlanModel>[];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', ''),
                        ...plans.map(
                          (plan) => _buildFilterChip(plan.planName, plan.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Customer List ─────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<FranchiseCustomersBloc, FranchiseCustomersState>(
                builder: (context, state) {
                  if (state is FranchiseCustomersLoading ||
                      state is FranchiseCustomersInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FranchiseCustomersFailure) {
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
                            onPressed: _fetchCustomers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final customers = state is FranchiseCustomersLoaded
                      ? state.customers
                      : <CustomerListItemModel>[];

                  if (customers.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: height * 0.25),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No customers found',
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
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return _CustomerCard(
                          name: customer.name,
                          phone: customer.phone,
                          status: _capitalize(customer.subscriptionStatus),
                          address: customer.city,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CustomerDetailScreen(customer: customer),
                              ),
                            );
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

  Widget _buildFilterChip(String label, String planId) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => _onFilterSelected(label, planId),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6), // Less rounded
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final String name;
  final String phone;
  final String status;
  final String address;
  final VoidCallback onTap;

  const _CustomerCard({
    required this.name,
    required this.phone,
    required this.status,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final isPositive = s == 'active' || s == 'delivered' || s == 'completed';
    final statusColor = isPositive ? AppColors.success : Colors.orange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // ── Customer Details ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 12,
                        color: AppColors.iconGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Status & Address on Right ──────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.iconGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
