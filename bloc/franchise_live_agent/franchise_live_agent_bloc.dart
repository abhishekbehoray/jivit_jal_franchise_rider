import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_live_agent_event.dart';
import 'franchise_live_agent_state.dart';

class FranchiseLiveAgentBloc extends Bloc<FranchiseLiveAgentEvent, FranchiseLiveAgentState> {
  final FranchiseRepository _repo;

  FranchiseLiveAgentBloc(this._repo) : super(FranchiseLiveAgentInitial()) {
    on<FranchiseLiveAgentFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(FranchiseLiveAgentFetchRequested event, Emitter emit) async {
    emit(FranchiseLiveAgentLoading());
    try {
      final response = await _repo.getLiveDeliveryAgents(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      emit(FranchiseLiveAgentLoaded(response.data));
    } catch (e) {
      emit(FranchiseLiveAgentFailure(e.toString()));
    }
  }
}
