abstract class FranchiseLiveAgentEvent {}

class FranchiseLiveAgentFetchRequested extends FranchiseLiveAgentEvent {
  final int page;
  final int limit;
  final String status;
  FranchiseLiveAgentFetchRequested({this.page = 1, this.limit = 50, this.status = ''});
}
