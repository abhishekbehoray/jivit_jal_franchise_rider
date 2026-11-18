import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_customer_note_event.dart';
import 'franchise_customer_note_state.dart';

class FranchiseCustomerNoteBloc
    extends Bloc<FranchiseCustomerNoteEvent, FranchiseCustomerNoteState> {
  final FranchiseRepository _repo;

  FranchiseCustomerNoteBloc(this._repo) : super(FranchiseCustomerNoteInitial()) {
    on<FranchiseCustomerNoteFetchRequested>(_onFetch);
    on<FranchiseCustomerNoteSaveRequested>(_onSave);
  }

  Future<void> _onFetch(
      FranchiseCustomerNoteFetchRequested event, Emitter emit) async {
    emit(FranchiseCustomerNoteLoading());
    try {
      final note = await _repo.getCustomerNote(event.customerId);
      emit(FranchiseCustomerNoteLoaded(note));
    } catch (e) {
      emit(FranchiseCustomerNoteFetchFailure(e.toString()));
    }
  }

  Future<void> _onSave(
      FranchiseCustomerNoteSaveRequested event, Emitter emit) async {
    emit(FranchiseCustomerNoteSaving());
    try {
      if (event.isUpdate) {
        await _repo.updateCustomerNote(customerId: event.customerId, note: event.note);
      } else {
        await _repo.createCustomerNote(customerId: event.customerId, note: event.note);
      }
      emit(FranchiseCustomerNoteSaveSuccess(event.note));
    } catch (e) {
      emit(FranchiseCustomerNoteSaveFailure(e.toString()));
    }
  }
}
