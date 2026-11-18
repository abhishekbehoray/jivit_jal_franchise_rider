import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_customers_event.dart';
import 'franchise_customers_state.dart';

class FranchiseCustomersBloc extends Bloc<FranchiseCustomersEvent, FranchiseCustomersState> {
  final FranchiseRepository _repo;

  FranchiseCustomersBloc(this._repo) : super(FranchiseCustomersInitial()) {
    on<FranchiseCustomersFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(FranchiseCustomersFetchRequested event, Emitter emit) async {
    emit(FranchiseCustomersLoading());
    try {
      final response = await _repo.getCustomers(
        page: event.page,
        limit: event.limit,
        search: event.search,
        planId: event.planId,
      );
      emit(FranchiseCustomersLoaded(response.data));
    } catch (e) {
      emit(FranchiseCustomersFailure(e.toString()));
    }
  }
}
