abstract class FranchiseInventoryEvent {}

class InventoryFetchRequested extends FranchiseInventoryEvent {}

class InventoryCreateRequested extends FranchiseInventoryEvent {
  final int filledJars;
  final int emptyJarsAtCustomers;
  final int returnedEmptyJars;
  final int damagedJars;
  final int totalJars;
  final int lowStockThreshold;

  InventoryCreateRequested({
    required this.filledJars,
    required this.emptyJarsAtCustomers,
    required this.returnedEmptyJars,
    required this.damagedJars,
    required this.totalJars,
    required this.lowStockThreshold,
  });
}

class InventoryUpdateRequested extends FranchiseInventoryEvent {
  final int filledJars;
  final int emptyJarsAtCustomers;
  final int returnedEmptyJars;
  final int damagedJars;
  final int totalJars;
  final int lowStockThreshold;

  InventoryUpdateRequested({
    required this.filledJars,
    required this.emptyJarsAtCustomers,
    required this.returnedEmptyJars,
    required this.damagedJars,
    required this.totalJars,
    required this.lowStockThreshold,
  });
}
