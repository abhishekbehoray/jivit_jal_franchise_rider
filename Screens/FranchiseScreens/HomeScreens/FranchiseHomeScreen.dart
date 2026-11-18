// Screens/FranchiseScreens/HomeScreens/FranchiseHomeScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_dashboard/franchise_dashboard_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_dashboard/franchise_dashboard_event.dart';
import 'package:jivit_jal_2/bloc/franchise_dashboard/franchise_dashboard_state.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_event.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_state.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_event.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_state.dart';
import 'package:jivit_jal_2/data/models/inventory_model.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/HomeScreenWidget/FailedDeliveryCardWidget.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/HomeScreenWidget/FreshWaterBannerWidget.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/HomeScreenWidget/HeaderWidget.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/HomeScreenWidget/LiveOperationsWidget.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/HomeScreenWidget/QuickActionsWidget.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/HomeScreenWidget/RecentOrderCardWidget.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/HomeScreenWidget/SalmonBoxWidget.dart';
import 'package:jivit_jal_2/Widgets/FranchiseWidgets/HomeScreenWidget/TodaysOverviewWidget.dart';

class FranchiseHomeScreen extends StatefulWidget {
  const FranchiseHomeScreen({super.key});

  @override
  State<FranchiseHomeScreen> createState() => _FranchiseHomeScreenState();
}

class _FranchiseHomeScreenState extends State<FranchiseHomeScreen> {
  Key _recentOrdersKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    context.read<FranchiseProfileBloc>().add(FranchiseProfileFetchRequested());
    context.read<FranchiseDashboardBloc>().add(FranchiseDashboardFetchRequested());
    context.read<FranchiseInventoryBloc>().add(InventoryFetchRequested());
  }

  Future<void> _onRefresh() async {
    context.read<FranchiseProfileBloc>().add(FranchiseProfileFetchRequested());
    context.read<FranchiseDashboardBloc>().add(FranchiseDashboardFetchRequested());
    context.read<FranchiseInventoryBloc>().add(InventoryFetchRequested());
    if (mounted) {
      setState(() => _recentOrdersKey = UniqueKey());
    }
    await context.read<FranchiseDashboardBloc>().stream
        .firstWhere((s) =>
            s is FranchiseDashboardSuccess || s is FranchiseDashboardFailure)
        .timeout(const Duration(seconds: 20), onTimeout: () => FranchiseDashboardInitial());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<FranchiseDashboardBloc, FranchiseDashboardState>(
          builder: (context, dashState) {
            return BlocBuilder<FranchiseProfileBloc, FranchiseProfileState>(
              builder: (context, profileState) {
                return BlocBuilder<FranchiseInventoryBloc, FranchiseInventoryState>(
                  builder: (context, inventoryState) {
                final name = profileState is FranchiseProfileSuccess
                    ? profileState.data.ownerName
                    : '';

                final dashStats = dashState is FranchiseDashboardSuccess
                    ? dashState.dashboardStats
                    : null;
                final deliveryStats = dashState is FranchiseDashboardSuccess
                    ? dashState.deliveryStats
                    : null;
                final revenueStats = dashState is FranchiseDashboardSuccess
                    ? dashState.revenueStats
                    : null;

                final InventoryModel? inventory =
                    inventoryState is FranchiseInventoryLoaded
                        ? inventoryState.inventory
                        : (inventoryState is FranchiseInventorySaving
                            ? inventoryState.current
                            : null);

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primaryBlue,
                  child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.005),

                      // ── Header ────────────────────────────────────────────
                      HeaderWidget(name: name, greeting: 'Good Morning!'),
                      SizedBox(height: height * 0.022),

                      // ── Today's Overview ──────────────────────────────────
                      TodaysOverviewWidget(stats: dashStats, revenueStats: revenueStats),
                      SizedBox(height: height * 0.022),

                      // ── Fresh Water Banner ────────────────────────────────
                      const FreshWaterBannerWidget(),
                      SizedBox(height: height * 0.022),

                      // ── Live Operations ───────────────────────────────────
                      LiveOperationsWidget(deliveryStats: deliveryStats),
                      SizedBox(height: height * 0.01),

                      // ── Salmon Box ────────────────────────────────────────
                      SalmonBoxWidget(inventory: inventory),
                      SizedBox(height: height * 0.022),

                      // ── Quick Actions ─────────────────────────────────────
                      const QuickActionsWidget(),
                      const SizedBox(height: 10),

                      SizedBox(height: height * 0.022),

                      // ── Failed Delivery ───────────────────────────────────
                      // const FailedDeliveryCardWidget(),
                      // SizedBox(height: height * 0.022),

                      // ── Recent Orders ─────────────────────────────────────
                      RecentOrdersSectionWidget(key: _recentOrdersKey),
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                  ),
                );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}