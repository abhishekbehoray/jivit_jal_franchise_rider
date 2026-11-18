import 'package:jivit_jal_2/data/models/cod_order_model.dart';

abstract class FranchiseCodState {}

class FranchiseCodInitial extends FranchiseCodState {}

class FranchiseCodLoading extends FranchiseCodState {}

class FranchiseCodLoaded extends FranchiseCodState {
  final CodOrdersResponseModel data;
  FranchiseCodLoaded(this.data);
}

class FranchiseCodFailure extends FranchiseCodState {
  final String message;
  FranchiseCodFailure(this.message);
}
