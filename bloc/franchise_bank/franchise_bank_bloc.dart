import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/franchise_repository.dart';
import 'franchise_bank_event.dart';
import 'franchise_bank_state.dart';

class FranchiseBankBloc extends Bloc<FranchiseBankEvent, FranchiseBankState> {
  final FranchiseRepository _repository;

  FranchiseBankBloc(this._repository) : super(FranchiseBankInitial()) {
    on<FranchiseBankFetchRequested>(_onFetch);
    on<FranchiseBankSaveRequested>(_onSave);
  }

  Future<void> _onFetch(
    FranchiseBankFetchRequested event,
    Emitter<FranchiseBankState> emit,
  ) async {
    emit(FranchiseBankLoading());
    try {
      final data = await _repository.getBankDetails();
      if (data == null) {
        emit(FranchiseBankNotFound());
      } else {
        emit(FranchiseBankLoaded(data));
      }
    } catch (e) {
      emit(FranchiseBankFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSave(
    FranchiseBankSaveRequested event,
    Emitter<FranchiseBankState> emit,
  ) async {
    emit(FranchiseBankSaving());
    try {
      final data = await _repository.saveBankDetails(
        accountHolderName: event.accountHolderName,
        accountNumber: event.accountNumber,
        ifscCode: event.ifscCode,
        bankName: event.bankName,
      );
      emit(FranchiseBankSaveSuccess(data));
    } catch (e) {
      emit(FranchiseBankSaveFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
