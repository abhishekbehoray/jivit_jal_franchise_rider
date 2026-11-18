abstract class FranchiseAgentOrdersEvent {}

class FranchiseAgentOrdersFetchRequested extends FranchiseAgentOrdersEvent {
  final String agentId;
  final int page;
  final int limit;
  final String status;
  FranchiseAgentOrdersFetchRequested({
    required this.agentId,
    this.page = 1,
    this.limit = 50,
    this.status = '',
  });
}
