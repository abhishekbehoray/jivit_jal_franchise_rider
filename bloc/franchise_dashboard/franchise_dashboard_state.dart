import '../../data/models/franchise_dashboard_model.dart';

abstract class FranchiseDashboardState {}

class FranchiseDashboardInitial extends FranchiseDashboardState {}

class FranchiseDashboardLoading extends FranchiseDashboardState {}

class FranchiseDashboardSuccess extends FranchiseDashboardState {
  final FranchiseDashboardStatsModel dashboardStats;
  final FranchiseDeliveryStatsModel deliveryStats;

  /// Revenue summary refetched for a filter selected in the Revenue Summary
  /// tile only. Null until a filter is chosen, in which case [dashboardStats]
  /// (fetched with the default filter) is used for the revenue display.
  final FranchiseDashboardStatsModel? revenueStats;

  FranchiseDashboardSuccess({
    required this.dashboardStats,
    required this.deliveryStats,
    this.revenueStats,
  });

  FranchiseDashboardSuccess copyWith({
    FranchiseDashboardStatsModel? dashboardStats,
    FranchiseDeliveryStatsModel? deliveryStats,
    FranchiseDashboardStatsModel? revenueStats,
  }) {
    return FranchiseDashboardSuccess(
      dashboardStats: dashboardStats ?? this.dashboardStats,
      deliveryStats: deliveryStats ?? this.deliveryStats,
      revenueStats: revenueStats ?? this.revenueStats,
    );
  }
}

class FranchiseDashboardFailure extends FranchiseDashboardState {
  final String message;
  FranchiseDashboardFailure(this.message);
}
