import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_customer_history_event.dart';
import 'franchise_customer_history_state.dart';

class FranchiseCustomerHistoryBloc
    extends Bloc<FranchiseCustomerHistoryEvent, FranchiseCustomerHistoryState> {
  final FranchiseRepository _repo;

  FranchiseCustomerHistoryBloc(this._repo) : super(FranchiseCustomerHistoryInitial()) {
    on<FranchiseCustomerHistoryFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
      FranchiseCustomerHistoryFetchRequested event, Emitter emit) async {
    emit(FranchiseCustomerHistoryLoading());
    try {
      final history = await _repo.getCustomerDeliveryHistory(event.customerId);
      emit(FranchiseCustomerHistoryLoaded(history));
    } catch (e) {
      emit(FranchiseCustomerHistoryFailure(e.toString()));
    }
  }
}
