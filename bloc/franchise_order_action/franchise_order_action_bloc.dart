import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_order_action_event.dart';
import 'franchise_order_action_state.dart';

class FranchiseOrderActionBloc extends Bloc<FranchiseOrderActionEvent, FranchiseOrderActionState> {
  final FranchiseRepository _repo;

  FranchiseOrderActionBloc(this._repo) : super(FranchiseOrderActionInitial()) {
    on<FranchiseOrderAcceptRequested>(_onAccept);
    on<FranchiseOrderRejectRequested>(_onReject);
    on<FranchiseOrderReassignRequested>(_onReassign);
    on<FranchiseOrderCodCollectedRequested>(_onCodCollected);
  }

  Future<void> _onAccept(FranchiseOrderAcceptRequested event, Emitter emit) async {
    emit(FranchiseOrderActionProcessing(event.orderId));
    try {
      final result = await _repo.updateOrderStatus(
        orderId: event.orderId,
        orderType: event.orderType,
        action: 'accept',
      );
      emit(FranchiseOrderActionSuccess(event.orderId, result));
    } catch (e) {
      emit(FranchiseOrderActionFailure(event.orderId, e.toString()));
    }
  }

  Future<void> _onReject(FranchiseOrderRejectRequested event, Emitter emit) async {
    emit(FranchiseOrderActionProcessing(event.orderId));
    try {
      final result = await _repo.updateOrderStatus(
        orderId: event.orderId,
        orderType: event.orderType,
        action: 'reject',
        rejectionReason: event.reason,
      );
      emit(FranchiseOrderActionSuccess(event.orderId, result));
    } catch (e) {
      emit(FranchiseOrderActionFailure(event.orderId, e.toString()));
    }
  }

  Future<void> _onReassign(FranchiseOrderReassignRequested event, Emitter emit) async {
    emit(FranchiseOrderActionProcessing(event.orderId));
    try {
      final result = await _repo.reassignDeliveryAgent(
        orderId: event.orderId,
        agentId: event.agentId,
      );
      emit(FranchiseOrderActionSuccess(event.orderId, result));
    } catch (e) {
      emit(FranchiseOrderActionFailure(event.orderId, e.toString()));
    }
  }

  Future<void> _onCodCollected(FranchiseOrderCodCollectedRequested event, Emitter emit) async {
    emit(FranchiseOrderActionProcessing(event.orderId));
    try {
      final result = await _repo.markCodCollected(event.orderId);
      emit(FranchiseOrderActionSuccess(event.orderId, result));
    } catch (e) {
      emit(FranchiseOrderActionFailure(event.orderId, e.toString()));
    }
  }
}
