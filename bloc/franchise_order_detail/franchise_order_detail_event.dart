abstract class FranchiseOrderDetailEvent {}

class FranchiseOrderDetailFetchRequested extends FranchiseOrderDetailEvent {
  final String orderId;
  FranchiseOrderDetailFetchRequested(this.orderId);
}
