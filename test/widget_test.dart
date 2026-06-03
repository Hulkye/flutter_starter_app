import 'package:flutter_starter_app/app/app.dart';
import 'package:flutter_starter_app/app/env.dart';
import 'package:flutter_starter_app/core/di/app_bootstrap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders home page smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'app_locale_code': 'zh'});
    appConfig = const EnvConfig();
    final bootstrap = await AppBootstrap.create(appConfig);

    await tester.pumpWidget(
      ProviderScope(overrides: bootstrap.overrides, child: const App()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('前往我的页面'), findsOneWidget);
    expect(find.text('前往 Todo 示例'), findsOneWidget);
  });
}
