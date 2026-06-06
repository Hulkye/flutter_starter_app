import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../shared/presentation/presentation.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Auth 页面状态。
class AuthState extends BaseState {
  const AuthState({
    this.account = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final String account;
  final String password;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    String? account,
    String? password,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      account: account ?? this.account,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Auth ViewModel。
final class AuthViewModel extends BaseVM<AuthState> {
  @override
  AuthState initialState() => const AuthState();

  void updateAccount(String? account) {
    state = state.copyWith(account: account?.trim() ?? '');
  }

  void updatePassword(String? password) {
    state = state.copyWith(password: password ?? '');
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .login(
            username,
            password,
            fallbackErrorMessage: ref
                .read(appLocalizationsProvider)
                .loginFailed,
          );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState();
  }
}

/// Auth ViewModel Provider。
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);
