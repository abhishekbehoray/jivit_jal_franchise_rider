import 'package:jivit_jal_2/data/models/customer_list_item_model.dart';

abstract class FranchiseCustomersState {}

class FranchiseCustomersInitial extends FranchiseCustomersState {}

class FranchiseCustomersLoading extends FranchiseCustomersState {}

class FranchiseCustomersLoaded extends FranchiseCustomersState {
  final List<CustomerListItemModel> customers;
  FranchiseCustomersLoaded(this.customers);
}

class FranchiseCustomersFailure extends FranchiseCustomersState {
  final String message;
  FranchiseCustomersFailure(this.message);
}
