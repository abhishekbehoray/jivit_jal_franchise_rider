import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/franchise_repository.dart';
import 'franchise_dashboard_event.dart';
import 'franchise_dashboard_state.dart';

class FranchiseDashboardBloc extends Bloc<FranchiseDashboardEvent, FranchiseDashboardState> {
  final FranchiseRepository _repository;

  FranchiseDashboardBloc(this._repository) : super(FranchiseDashboardInitial()) {
    on<FranchiseDashboardFetchRequested>(_onFetch);
    on<FranchiseRevenueFilterRequested>(_onRevenueFilter);
  }

  Future<void> _onFetch(
    FranchiseDashboardFetchRequested event,
    Emitter<FranchiseDashboardState> emit,
  ) async {
    emit(FranchiseDashboardLoading());
    try {
      final results = await Future.wait([
        _repository.getDashboardStats(filter: event.filter),
        _repository.getDeliveryStats(),
      ]);
      emit(FranchiseDashboardSuccess(
        dashboardStats: results[0] as dynamic,
        deliveryStats: results[1] as dynamic,
      ));
    } catch (e) {
      emit(FranchiseDashboardFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRevenueFilter(
    FranchiseRevenueFilterRequested event,
    Emitter<FranchiseDashboardState> emit,
  ) async {
    final current = state;
    if (current is! FranchiseDashboardSuccess) return;
    try {
      final revenueStats = await _repository.getDashboardStats(filter: event.filter);
      emit(current.copyWith(revenueStats: revenueStats));
    } catch (_) {
      // Keep showing the previous revenue figure if the refetch fails.
    }
  }
}
