import '../../data/models/franchise_auth_model.dart';

abstract class FranchiseAuthState {}

class FranchiseAuthInitial extends FranchiseAuthState {}

class FranchiseAuthLoading extends FranchiseAuthState {}

class FranchiseAuthSuccess extends FranchiseAuthState {
  final FranchiseAuthModel data;
  FranchiseAuthSuccess(this.data);
}

class FranchiseAuthFailure extends FranchiseAuthState {
  final String message;
  FranchiseAuthFailure(this.message);
}

class FranchiseTokenRefreshSuccess extends FranchiseAuthState {}

class FranchiseTokenRefreshFailure extends FranchiseAuthState {
  final String message;
  FranchiseTokenRefreshFailure(this.message);
}
