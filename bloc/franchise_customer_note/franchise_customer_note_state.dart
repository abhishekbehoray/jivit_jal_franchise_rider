abstract class FranchiseCustomerNoteState {}

class FranchiseCustomerNoteInitial extends FranchiseCustomerNoteState {}

class FranchiseCustomerNoteLoading extends FranchiseCustomerNoteState {}

class FranchiseCustomerNoteLoaded extends FranchiseCustomerNoteState {
  final String? note;
  FranchiseCustomerNoteLoaded(this.note);
}

class FranchiseCustomerNoteFetchFailure extends FranchiseCustomerNoteState {
  final String message;
  FranchiseCustomerNoteFetchFailure(this.message);
}

class FranchiseCustomerNoteSaving extends FranchiseCustomerNoteState {}

class FranchiseCustomerNoteSaveSuccess extends FranchiseCustomerNoteState {
  final String note;
  FranchiseCustomerNoteSaveSuccess(this.note);
}

class FranchiseCustomerNoteSaveFailure extends FranchiseCustomerNoteState {
  final String message;
  FranchiseCustomerNoteSaveFailure(this.message);
}
