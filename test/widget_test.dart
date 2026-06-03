import 'package:flutter_starter_app/app/app.dart';
import 'package:flutter_starter_app/app/env.dart';
import 'package:flutter_starter_app/core/di/di_overrides.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/shared/presentation/base_feedback_binding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'App renders home page smoke test',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'zh'});
      bindBaseVmFeedbackHandlers();
      await prefsStorage.init();

      appConfig = const EnvConfig();
      final overrides = createEnvOverrides(appConfig);

      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const App()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('首页'), findsOneWidget);
      expect(find.text('前往我的页面'), findsOneWidget);
      expect(find.text('前往 Todo 示例'), findsOneWidget);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
