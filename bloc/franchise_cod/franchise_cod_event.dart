abstract class FranchiseCodEvent {}

class FranchiseCodFetchRequested extends FranchiseCodEvent {
  final int page;
  FranchiseCodFetchRequested({this.page = 1});
}
