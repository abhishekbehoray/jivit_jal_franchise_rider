abstract class FranchiseAgentEvent {}

class FranchiseAgentFetchRequested extends FranchiseAgentEvent {
  final String search;
  FranchiseAgentFetchRequested({this.search = ''});
}

class FranchiseAgentCreateRequested extends FranchiseAgentEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  FranchiseAgentCreateRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class FranchiseAgentToggleStatusRequested extends FranchiseAgentEvent {
  final String id;
  FranchiseAgentToggleStatusRequested(this.id);
}
