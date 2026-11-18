import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_order_detail_event.dart';
import 'franchise_order_detail_state.dart';

class FranchiseOrderDetailBloc extends Bloc<FranchiseOrderDetailEvent, FranchiseOrderDetailState> {
  final FranchiseRepository _repo;

  FranchiseOrderDetailBloc(this._repo) : super(FranchiseOrderDetailInitial()) {
    on<FranchiseOrderDetailFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(FranchiseOrderDetailFetchRequested event, Emitter emit) async {
    emit(FranchiseOrderDetailLoading());
    try {
      final order = await _repo.getTodayOrderDetail(event.orderId);
      emit(FranchiseOrderDetailLoaded(order));
    } catch (e) {
      emit(FranchiseOrderDetailFailure(e.toString()));
    }
  }
}
