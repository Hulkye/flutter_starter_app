import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/presentation.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Auth 页面状态。
class AuthState extends BaseState {
  const AuthState({
    super.isReady = true,
    this.isLoading = false,
    this.errorMessage,
    this.isLoggedIn = false,
    this.username = '',
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isLoggedIn;
  final String username;

  @override
  AuthState copyWithBase({bool? isReady}) {
    return copyWith(isReady: isReady);
  }

  AuthState copyWith({
    bool? isReady,
    bool? isLoading,
    String? errorMessage,
    bool? isLoggedIn,
    String? username,
  }) {
    return AuthState(
      isReady: isReady ?? this.isReady,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      username: username ?? this.username,
    );
  }
}

/// Auth ViewModel。
final class AuthViewModel extends BaseVM<AuthState> {
  @override
  AuthState initialState() => const AuthState();

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(authRepositoryProvider).login(username, password);
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        username: username,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = state.copyWith(isLoggedIn: false, username: '');
  }
}

/// Auth ViewModel Provider。
final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);
