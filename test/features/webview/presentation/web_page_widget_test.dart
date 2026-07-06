import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/app/app.dart';
import 'package:flutter_starter_app/app/env.dart';
import 'package:flutter_starter_app/app/router/app_router_config.dart';
import 'package:flutter_starter_app/core/di/di_overrides.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/features/webview/webview_feature.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpMs(WidgetTester tester, int milliseconds) async {
  final steps = milliseconds ~/ 100;
  for (int i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _pumpApp(WidgetTester tester, {AuthSession? session}) async {
  tester.binding.setSurfaceSize(const Size(414, 896));
  SharedPreferences.setMockInitialValues({
    'app_locale_code': 'zh',
    'app_theme_mode': 0,
  });
  await prefsStorage.init();
  appConfig = const EnvConfig();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...createEnvOverrides(appConfig),
        ...createAppRouterOverrides(),
        authSessionProvider.overrideWith(
          () => _TestAuthSessionNotifier(session),
        ),
      ],
      child: const App(),
    ),
  );
}

void main() {
  testWidgets(
    'public web route shows invalid url error without loading WebView',
    (tester) async {
      await _pumpApp(tester);
      await _pumpMs(tester, 3000);

      final context = tester.element(find.byType(MaterialApp));
      final router = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(appRouterProvider);

      router.go(const WebPageRoute(url: 'ftp://example.com').location);
      await _pumpMs(tester, 1000);

      expect(find.text('网页地址无效'), findsOneWidget);
      expect(find.text('刷新'), findsAtLeastNWidgets(1));
    },
  );

  testWidgets('auth web route redirects unauthenticated users to login', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _pumpMs(tester, 3000);

    final context = tester.element(find.byType(MaterialApp));
    final router = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(appRouterProvider);

    router.go(const AuthWebPageRoute(url: 'https://example.com').location);
    await _pumpMs(tester, 1000);

    expect(find.text('登录'), findsAtLeastNWidgets(1));
  });
}

final class _TestAuthSessionNotifier extends AuthSessionNotifier {
  _TestAuthSessionNotifier(this._initialSession);

  final AuthSession? _initialSession;

  @override
  AuthSession? build() => _initialSession;

  @override
  Future<void> setSession(AuthSession session) async {
    state = session;
  }

  @override
  Future<void> clear() async {
    state = null;
  }
}
