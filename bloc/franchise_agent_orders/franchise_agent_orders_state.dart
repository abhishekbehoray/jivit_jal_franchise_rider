import 'package:jivit_jal_2/data/models/today_order_model.dart';

abstract class FranchiseAgentOrdersState {}

class FranchiseAgentOrdersInitial extends FranchiseAgentOrdersState {}

class FranchiseAgentOrdersLoading extends FranchiseAgentOrdersState {}

class FranchiseAgentOrdersLoaded extends FranchiseAgentOrdersState {
  final List<TodayOrderModel> orders;
  FranchiseAgentOrdersLoaded(this.orders);
}

class FranchiseAgentOrdersFailure extends FranchiseAgentOrdersState {
  final String message;
  FranchiseAgentOrdersFailure(this.message);
}
