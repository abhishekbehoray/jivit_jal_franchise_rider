abstract class FranchiseBankEvent {}

class FranchiseBankFetchRequested extends FranchiseBankEvent {}

class FranchiseBankSaveRequested extends FranchiseBankEvent {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;

  FranchiseBankSaveRequested({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
  });
}
