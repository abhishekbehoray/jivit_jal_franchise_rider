abstract class FranchiseAuthEvent {}

class FranchiseLoginRequested extends FranchiseAuthEvent {
  final String email;
  final String password;
  FranchiseLoginRequested({required this.email, required this.password});
}

class FranchiseTokenRefreshRequested extends FranchiseAuthEvent {}
