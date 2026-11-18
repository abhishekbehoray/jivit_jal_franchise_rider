import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'franchise_inventory_event.dart';
import 'franchise_inventory_state.dart';

class FranchiseInventoryBloc
    extends Bloc<FranchiseInventoryEvent, FranchiseInventoryState> {
  final FranchiseRepository _repo;

  FranchiseInventoryBloc(this._repo) : super(FranchiseInventoryInitial()) {
    on<InventoryFetchRequested>(_onFetch);
    on<InventoryCreateRequested>(_onCreate);
    on<InventoryUpdateRequested>(_onUpdate);
  }

  Future<void> _onFetch(
      InventoryFetchRequested event, Emitter<FranchiseInventoryState> emit) async {
    emit(FranchiseInventoryLoading());
    try {
      final inventory = await _repo.getInventory();
      if (inventory == null) {
        emit(FranchiseInventoryNotFound());
      } else {
        emit(FranchiseInventoryLoaded(inventory));
      }
    } catch (e) {
      emit(FranchiseInventoryFailure(e.toString()));
    }
  }

  Future<void> _onCreate(
      InventoryCreateRequested event, Emitter<FranchiseInventoryState> emit) async {
    emit(FranchiseInventorySaving());
    try {
      final inventory = await _repo.createInventory(
        filledJars: event.filledJars,
        emptyJarsAtCustomers: event.emptyJarsAtCustomers,
        returnedEmptyJars: event.returnedEmptyJars,
        damagedJars: event.damagedJars,
        totalJars: event.totalJars,
        lowStockThreshold: event.lowStockThreshold,
      );
      emit(FranchiseInventorySaved(inventory));
      emit(FranchiseInventoryLoaded(inventory));
    } catch (e) {
      emit(FranchiseInventorySaveFailure(e.toString()));
      emit(FranchiseInventoryNotFound());
    }
  }

  Future<void> _onUpdate(
      InventoryUpdateRequested event, Emitter<FranchiseInventoryState> emit) async {
    final current = state is FranchiseInventoryLoaded
        ? (state as FranchiseInventoryLoaded).inventory
        : null;
    emit(FranchiseInventorySaving(current: current));
    try {
      final inventory = await _repo.updateInventory(
        filledJars: event.filledJars,
        emptyJarsAtCustomers: event.emptyJarsAtCustomers,
        returnedEmptyJars: event.returnedEmptyJars,
        damagedJars: event.damagedJars,
        totalJars: event.totalJars,
        lowStockThreshold: event.lowStockThreshold,
      );
      emit(FranchiseInventorySaved(inventory));
      emit(FranchiseInventoryLoaded(inventory));
    } catch (e) {
      emit(FranchiseInventorySaveFailure(e.toString(), current: current));
      if (current != null) emit(FranchiseInventoryLoaded(current));
    }
  }
}
