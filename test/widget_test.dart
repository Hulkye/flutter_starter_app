import 'package:flutter_starter_app/app/app.dart';
import 'package:flutter_starter_app/app/env.dart';
import 'package:flutter_starter_app/core/di/di_overrides.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_starter_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_session.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_store.dart';
import 'package:flutter_starter_app/shared/presentation/presentation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'App redirects to login and logs in to root todo tab smoke test',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'app_locale_code': 'zh',
        'app_theme_mode': 0,
      });
      bindPresentationHelper();
      await prefsStorage.init();
      authStore.setMemorySession(null);

      appConfig = const EnvConfig();
      final overrides = [
        ...createEnvOverrides(appConfig),
        authSessionProvider.overrideWith(_TestAuthSessionNotifier.new),
        authRepositoryProvider.overrideWith(_FakeAuthRepository.new),
      ];

      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const App()),
      );
      await tester.pumpAndSettle();

      expect(find.text('登录'), findsAtLeastNWidgets(1));

      final inputFields = find.byType(EditableText);
      expect(inputFields, findsNWidgets(2));

      await tester.enterText(inputFields.at(0), 'demo');
      await tester.enterText(inputFields.at(1), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
      await tester.pumpAndSettle();

      expect(find.text('Todo 示例'), findsAtLeastNWidgets(1));
      expect(find.text('创建 Todo'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);

      await tester.tap(find.text('我的').last);
      await tester.pumpAndSettle();

      expect(find.text('切换主题模式'), findsOneWidget);
      expect(find.text('退出登录'), findsOneWidget);

      await tester.tap(find.text('切换主题模式'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Dark'), findsAtLeastNWidgets(1));

      await tester.tap(find.widgetWithText(ElevatedButton, '退出登录'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();

      expect(find.text('登录'), findsAtLeastNWidgets(1));
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}

final class _TestAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSession? build() => null;

  @override
  Future<void> setSession(AuthSession session) async {
    authStore.setMemorySession(session);
    state = session;
  }

  @override
  Future<void> clear() async {
    authStore.setMemorySession(null);
    state = null;
  }
}

final class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository(this._ref);

  final Ref _ref;

  @override
  Future<void> login(
    String username,
    String password, {
    required String fallbackErrorMessage,
  }) async {
    await _ref
        .read(authSessionProvider.notifier)
        .setSession(
          AuthSession(token: 'test-token', payload: {'username': username}),
        );
  }

  @override
  Future<void> logout() async {
    await _ref.read(authSessionProvider.notifier).clear();
  }
}
