import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/presentation.dart';
import '../viewmodels/auth_viewmodel.dart';

/// 登录页（模板演示）。
class LoginPage extends BasePage<AuthViewModel> {
  LoginPage({super.key});

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // ── VM 接入 ──

  @override
  AuthViewModel notifier(WidgetRef ref) =>
      ref.read(authViewModelProvider.notifier);

  @override
  BaseState watchState(WidgetRef ref) => ref.watch(authViewModelProvider);

  // ── UI ──

  @override
  PreferredSizeWidget? appBar(
    BuildContext context,
    WidgetRef ref,
    AuthViewModel vm,
  ) {
    return AppBar(title: const Text('Login'));
  }

  @override
  Widget page(BuildContext context, WidgetRef ref, AuthViewModel vm) {
    final state = ref.watch(authViewModelProvider);

    if (state.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome, ${state.username}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () => vm.login(
                        _usernameCtrl.text.trim(),
                        _passwordCtrl.text.trim(),
                      ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
