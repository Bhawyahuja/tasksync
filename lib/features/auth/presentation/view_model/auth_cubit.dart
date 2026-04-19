import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_messages.dart';
import '../../data/auth_local_data_source.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._localDataSource)
    : super(AuthState(isAuthenticated: _localDataSource.isAuthenticated));

  final AuthLocalDataSource _localDataSource;

  Future<void> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail == 'demo@tasksync.dev' && password == 'password123') {
      await _localDataSource.setAuthenticated(true);
      emit(const AuthState(isAuthenticated: true));
      return;
    }

    emit(
      state.copyWith(
        isAuthenticated: false,
        errorMessage: AppMessages.invalidCredentials,
      ),
    );
  }

  Future<void> logout() async {
    await _localDataSource.setAuthenticated(false);
    emit(const AuthState(isAuthenticated: false));
  }
}
