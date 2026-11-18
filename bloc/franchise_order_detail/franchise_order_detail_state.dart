import 'package:jivit_jal_2/data/models/order_detail_model.dart';

abstract class FranchiseOrderDetailState {}

class FranchiseOrderDetailInitial extends FranchiseOrderDetailState {}

class FranchiseOrderDetailLoading extends FranchiseOrderDetailState {}

class FranchiseOrderDetailLoaded extends FranchiseOrderDetailState {
  final OrderDetailModel order;
  FranchiseOrderDetailLoaded(this.order);
}

class FranchiseOrderDetailFailure extends FranchiseOrderDetailState {
  final String message;
  FranchiseOrderDetailFailure(this.message);
}
