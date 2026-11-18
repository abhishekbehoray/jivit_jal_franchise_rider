import 'package:jivit_jal_2/data/models/customer_delivery_history_model.dart';

abstract class FranchiseCustomerHistoryState {}

class FranchiseCustomerHistoryInitial extends FranchiseCustomerHistoryState {}

class FranchiseCustomerHistoryLoading extends FranchiseCustomerHistoryState {}

class FranchiseCustomerHistoryLoaded extends FranchiseCustomerHistoryState {
  final CustomerDeliveryHistoryModel history;
  FranchiseCustomerHistoryLoaded(this.history);
}

class FranchiseCustomerHistoryFailure extends FranchiseCustomerHistoryState {
  final String message;
  FranchiseCustomerHistoryFailure(this.message);
}
