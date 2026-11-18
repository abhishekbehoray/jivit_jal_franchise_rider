import 'package:jivit_jal_2/data/models/inventory_model.dart';

abstract class FranchiseInventoryState {}

class FranchiseInventoryInitial extends FranchiseInventoryState {}

class FranchiseInventoryLoading extends FranchiseInventoryState {}

class FranchiseInventoryLoaded extends FranchiseInventoryState {
  final InventoryModel inventory;
  FranchiseInventoryLoaded(this.inventory);
}

/// No inventory record exists yet — show "Create Inventory" UI
class FranchiseInventoryNotFound extends FranchiseInventoryState {}

class FranchiseInventoryFailure extends FranchiseInventoryState {
  final String message;
  FranchiseInventoryFailure(this.message);
}

class FranchiseInventorySaving extends FranchiseInventoryState {
  final InventoryModel? current;
  FranchiseInventorySaving({this.current});
}

class FranchiseInventorySaved extends FranchiseInventoryState {
  final InventoryModel inventory;
  FranchiseInventorySaved(this.inventory);
}

class FranchiseInventorySaveFailure extends FranchiseInventoryState {
  final String message;
  final InventoryModel? current;
  FranchiseInventorySaveFailure(this.message, {this.current});
}
