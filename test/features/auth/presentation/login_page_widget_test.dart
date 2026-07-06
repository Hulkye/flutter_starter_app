import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/l10n/gen/app_localizations.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/core/theme/theme.dart';
import 'package:flutter_starter_app/core/util/screen_util.dart';
import 'package:flutter_starter_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_starter_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login success navigates once from the login action', (
    tester,
  ) async {
    final navigator = _RecordingNavigator();
    await _pumpLoginPage(tester, navigator: navigator);

    await tester.enterText(find.byType(EditableText).first, 'demo');
    await tester.enterText(find.byType(EditableText).last, 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(navigator.replaceAllCount, 1);
    expect(navigator.lastReplaceAllLocation, '/');
  });
}

Future<void> _pumpLoginPage(
  WidgetTester tester, {
  required _RecordingNavigator navigator,
}) async {
  await tester.binding.setSurfaceSize(const Size(414, 896));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appRouterProvider.overrideWith((ref) => navigator),
        authSessionProvider.overrideWith(() => _TestAuthSessionNotifier(null)),
        authRepositoryProvider.overrideWith(
          (ref) => const _SuccessfulAuthRepository(),
        ),
      ],
      child: ScreenUtil.screenInit(
        MaterialApp(
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppThemeData.light,
          darkTheme: AppThemeData.dark,
          home: const LoginPage(),
        ),
        const Size(375, 812),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

final class _SuccessfulAuthRepository implements AuthRepository {
  const _SuccessfulAuthRepository();

  @override
  Future<AuthSession> login(String username, String password) async {
    return AuthSession(
      token: 'test-token',
      payload: <String, dynamic>{'username': username},
    );
  }
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

final class _RecordingNavigator implements BaseNavigator {
  int replaceAllCount = 0;
  String? lastReplaceAllLocation;

  @override
  String get location => lastReplaceAllLocation ?? '/login';

  @override
  void back<T extends Object?>([T? result]) {}

  @override
  bool canBack() => false;

  @override
  void go(String location, {Object? extra}) {}

  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) async {
    return null;
  }

  @override
  void replace(String location, {Object? extra}) {}

  @override
  void replaceAll(String location, {Object? extra}) {
    replaceAllCount++;
    lastReplaceAllLocation = location;
  }
}
