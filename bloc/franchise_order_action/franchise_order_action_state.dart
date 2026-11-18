import 'package:jivit_jal_2/data/models/order_action_result_model.dart';

abstract class FranchiseOrderActionState {}

class FranchiseOrderActionInitial extends FranchiseOrderActionState {}

class FranchiseOrderActionProcessing extends FranchiseOrderActionState {
  final String orderId;
  FranchiseOrderActionProcessing(this.orderId);
}

class FranchiseOrderActionSuccess extends FranchiseOrderActionState {
  final String orderId;
  final OrderActionResultModel result;
  FranchiseOrderActionSuccess(this.orderId, this.result);
}

class FranchiseOrderActionFailure extends FranchiseOrderActionState {
  final String orderId;
  final String message;
  FranchiseOrderActionFailure(this.orderId, this.message);
}
