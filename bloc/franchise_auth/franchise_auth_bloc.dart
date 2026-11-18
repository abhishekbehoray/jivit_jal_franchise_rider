import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'franchise_auth_event.dart';
import 'franchise_auth_state.dart';

class FranchiseAuthBloc extends Bloc<FranchiseAuthEvent, FranchiseAuthState> {
  final AuthRepository _authRepository;

  FranchiseAuthBloc(this._authRepository) : super(FranchiseAuthInitial()) {
    on<FranchiseLoginRequested>(_onLoginRequested);
    on<FranchiseTokenRefreshRequested>(_onTokenRefresh);
  }

  Future<void> _onLoginRequested(
    FranchiseLoginRequested event,
    Emitter<FranchiseAuthState> emit,
  ) async {
    emit(FranchiseAuthLoading());
    try {
      final data = await _authRepository.franchiseLogin(
        email: event.email,
        password: event.password,
      );
      emit(FranchiseAuthSuccess(data));
    } catch (e) {
      emit(FranchiseAuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onTokenRefresh(
    FranchiseTokenRefreshRequested event,
    Emitter<FranchiseAuthState> emit,
  ) async {
    try {
      await _authRepository.franchiseRefreshToken();
      emit(FranchiseTokenRefreshSuccess());
    } catch (e) {
      emit(FranchiseTokenRefreshFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
