abstract class FranchiseOrderActionEvent {}

class FranchiseOrderAcceptRequested extends FranchiseOrderActionEvent {
  final String orderId;
  final String orderType;
  FranchiseOrderAcceptRequested({required this.orderId, required this.orderType});
}

class FranchiseOrderRejectRequested extends FranchiseOrderActionEvent {
  final String orderId;
  final String orderType;
  final String? reason;
  FranchiseOrderRejectRequested({required this.orderId, required this.orderType, this.reason});
}

class FranchiseOrderReassignRequested extends FranchiseOrderActionEvent {
  final String orderId;
  final String agentId;
  FranchiseOrderReassignRequested({required this.orderId, required this.agentId});
}

class FranchiseOrderCodCollectedRequested extends FranchiseOrderActionEvent {
  final String orderId;
  FranchiseOrderCodCollectedRequested({required this.orderId});
}
