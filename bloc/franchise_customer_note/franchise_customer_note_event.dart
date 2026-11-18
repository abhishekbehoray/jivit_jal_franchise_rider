abstract class FranchiseCustomerNoteEvent {}

class FranchiseCustomerNoteFetchRequested extends FranchiseCustomerNoteEvent {
  final String customerId;
  FranchiseCustomerNoteFetchRequested(this.customerId);
}

class FranchiseCustomerNoteSaveRequested extends FranchiseCustomerNoteEvent {
  final String customerId;
  final String note;
  final bool isUpdate;
  FranchiseCustomerNoteSaveRequested({
    required this.customerId,
    required this.note,
    required this.isUpdate,
  });
}
