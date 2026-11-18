abstract class FranchiseCustomerHistoryEvent {}

class FranchiseCustomerHistoryFetchRequested extends FranchiseCustomerHistoryEvent {
  final String customerId;
  FranchiseCustomerHistoryFetchRequested(this.customerId);
}
