import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/models/delivery_agent_model.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_agent_event.dart';
import 'franchise_agent_state.dart';

class FranchiseAgentBloc extends Bloc<FranchiseAgentEvent, FranchiseAgentState> {
  final FranchiseRepository _repo;

  FranchiseAgentBloc(this._repo) : super(FranchiseAgentInitial()) {
    on<FranchiseAgentFetchRequested>(_onFetch);
    on<FranchiseAgentCreateRequested>(_onCreate);
    on<FranchiseAgentToggleStatusRequested>(_onToggle);
  }

  List<DeliveryAgentModel> _currentAgents() {
    final s = state;
    if (s is FranchiseAgentLoaded) return s.agents;
    if (s is FranchiseAgentCreating) return s.agents;
    if (s is FranchiseAgentCreateSuccess) return s.agents;
    if (s is FranchiseAgentCreateFailure) return s.agents;
    if (s is FranchiseAgentToggling) return s.agents;
    if (s is FranchiseAgentToggleFailure) return s.agents;
    return [];
  }

  Future<void> _onFetch(FranchiseAgentFetchRequested event, Emitter emit) async {
    emit(FranchiseAgentLoading());
    try {
      final agents = await _repo.getDeliveryAgents(search: event.search);
      emit(FranchiseAgentLoaded(agents));
    } catch (e) {
      emit(FranchiseAgentFailure(e.toString()));
    }
  }

  Future<void> _onCreate(FranchiseAgentCreateRequested event, Emitter emit) async {
    final current = _currentAgents();
    emit(FranchiseAgentCreating(current));
    try {
      final agent = await _repo.createDeliveryAgent(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      final updated = [agent, ...current];
      emit(FranchiseAgentCreateSuccess(updated));
    } catch (e) {
      emit(FranchiseAgentCreateFailure(current, e.toString()));
    }
  }

  Future<void> _onToggle(FranchiseAgentToggleStatusRequested event, Emitter emit) async {
    final current = _currentAgents();
    // Optimistically flip the value before API call
    final optimistic = current.map((a) {
      if (a.id == event.id) {
        return DeliveryAgentModel(
          id: a.id,
          name: a.name,
          email: a.email,
          phone: a.phone,
          isActive: !a.isActive,
        );
      }
      return a;
    }).toList();
    emit(FranchiseAgentToggling(optimistic, event.id));
    try {
      await _repo.toggleDeliveryAgentStatus(event.id);
      emit(FranchiseAgentLoaded(optimistic));
    } catch (e) {
      // Revert back on failure
      emit(FranchiseAgentToggleFailure(current, e.toString()));
    }
  }
}
