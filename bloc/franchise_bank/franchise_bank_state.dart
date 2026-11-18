import '../../data/models/franchise_bank_model.dart';

abstract class FranchiseBankState {}

class FranchiseBankInitial extends FranchiseBankState {}

class FranchiseBankLoading extends FranchiseBankState {}

class FranchiseBankLoaded extends FranchiseBankState {
  final FranchiseBankModel data;
  FranchiseBankLoaded(this.data);
}

class FranchiseBankNotFound extends FranchiseBankState {}

class FranchiseBankFailure extends FranchiseBankState {
  final String message;
  FranchiseBankFailure(this.message);
}

class FranchiseBankSaving extends FranchiseBankState {}

class FranchiseBankSaveSuccess extends FranchiseBankState {
  final FranchiseBankModel data;
  FranchiseBankSaveSuccess(this.data);
}

class FranchiseBankSaveFailure extends FranchiseBankState {
  final String message;
  FranchiseBankSaveFailure(this.message);
}
