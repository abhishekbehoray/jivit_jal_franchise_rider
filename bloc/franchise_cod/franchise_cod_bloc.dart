import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_cod_event.dart';
import 'franchise_cod_state.dart';

class FranchiseCodBloc extends Bloc<FranchiseCodEvent, FranchiseCodState> {
  final FranchiseRepository _repo;

  FranchiseCodBloc(this._repo) : super(FranchiseCodInitial()) {
    on<FranchiseCodFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(FranchiseCodFetchRequested event, Emitter emit) async {
    emit(FranchiseCodLoading());
    try {
      final data = await _repo.getCodOrders(page: event.page);
      emit(FranchiseCodLoaded(data));
    } catch (e) {
      emit(FranchiseCodFailure(e.toString()));
    }
  }
}
