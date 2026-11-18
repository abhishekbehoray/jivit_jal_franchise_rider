import 'package:jivit_jal_2/data/models/live_delivery_agent_model.dart';

abstract class FranchiseLiveAgentState {}

class FranchiseLiveAgentInitial extends FranchiseLiveAgentState {}

class FranchiseLiveAgentLoading extends FranchiseLiveAgentState {}

class FranchiseLiveAgentLoaded extends FranchiseLiveAgentState {
  final List<LiveDeliveryAgentModel> agents;
  FranchiseLiveAgentLoaded(this.agents);
}

class FranchiseLiveAgentFailure extends FranchiseLiveAgentState {
  final String message;
  FranchiseLiveAgentFailure(this.message);
}
