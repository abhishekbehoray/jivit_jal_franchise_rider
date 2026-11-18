abstract class FranchiseCustomersEvent {}

class FranchiseCustomersFetchRequested extends FranchiseCustomersEvent {
  final int page;
  final int limit;
  final String search;
  final String planId;
  FranchiseCustomersFetchRequested({
    this.page = 1,
    this.limit = 50,
    this.search = '',
    this.planId = '',
  });
}
