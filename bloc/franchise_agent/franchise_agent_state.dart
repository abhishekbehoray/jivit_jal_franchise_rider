import 'package:jivit_jal_2/data/models/delivery_agent_model.dart';

abstract class FranchiseAgentState {}

class FranchiseAgentInitial extends FranchiseAgentState {}

class FranchiseAgentLoading extends FranchiseAgentState {}

class FranchiseAgentLoaded extends FranchiseAgentState {
  final List<DeliveryAgentModel> agents;
  FranchiseAgentLoaded(this.agents);
}

class FranchiseAgentFailure extends FranchiseAgentState {
  final String message;
  FranchiseAgentFailure(this.message);
}

class FranchiseAgentCreating extends FranchiseAgentState {
  final List<DeliveryAgentModel> agents;
  FranchiseAgentCreating(this.agents);
}

class FranchiseAgentCreateSuccess extends FranchiseAgentState {
  final List<DeliveryAgentModel> agents;
  FranchiseAgentCreateSuccess(this.agents);
}

class FranchiseAgentCreateFailure extends FranchiseAgentState {
  final List<DeliveryAgentModel> agents;
  final String message;
  FranchiseAgentCreateFailure(this.agents, this.message);
}

class FranchiseAgentToggling extends FranchiseAgentState {
  final List<DeliveryAgentModel> agents;
  final String togglingId; // only this card is loading
  FranchiseAgentToggling(this.agents, this.togglingId);
}

class FranchiseAgentToggleFailure extends FranchiseAgentState {
  final List<DeliveryAgentModel> agents;
  final String message;
  FranchiseAgentToggleFailure(this.agents, this.message);
}
