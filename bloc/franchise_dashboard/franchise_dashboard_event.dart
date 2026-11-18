abstract class FranchiseDashboardEvent {}

class FranchiseDashboardFetchRequested extends FranchiseDashboardEvent {
  final String filter;
  FranchiseDashboardFetchRequested({this.filter = 'week'});
}

/// Refetches only the revenue summary for the given filter, leaving the
/// other dashboard stats (Total/Pending Orders, Active Customers) untouched.
class FranchiseRevenueFilterRequested extends FranchiseDashboardEvent {
  final String filter;
  FranchiseRevenueFilterRequested({required this.filter});
}
