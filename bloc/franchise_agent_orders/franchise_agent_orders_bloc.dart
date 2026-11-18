import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_agent_orders_event.dart';
import 'franchise_agent_orders_state.dart';

class FranchiseAgentOrdersBloc extends Bloc<FranchiseAgentOrdersEvent, FranchiseAgentOrdersState> {
  final FranchiseRepository _repo;

  FranchiseAgentOrdersBloc(this._repo) : super(FranchiseAgentOrdersInitial()) {
    on<FranchiseAgentOrdersFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(FranchiseAgentOrdersFetchRequested event, Emitter emit) async {
    emit(FranchiseAgentOrdersLoading());
    try {
      final response = await _repo.getTodayOrders(
        page: event.page,
        limit: event.limit,
        status: event.status,
        agentId: event.agentId,
      );
      emit(FranchiseAgentOrdersLoaded(response.data));
    } catch (e) {
      emit(FranchiseAgentOrdersFailure(e.toString()));
    }
  }
}
