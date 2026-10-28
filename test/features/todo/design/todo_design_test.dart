import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_app/core/feature/app_theme_contribution.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/features/features.dart';
import 'package:flutter_starter_app/features/todo/design/todo_design.dart';
import 'package:flutter_starter_app/shared/design_system/design_system.dart';
import 'package:flutter_starter_app/shared/localization/localization.dart';
import 'package:flutter_starter_app/features/todo/localization/todo_localization.dart';

void main() {
  testWidgets('reads feature color and asset from the active theme', (
    tester,
  ) async {
    late TodoColor color;
    late TodoAsset asset;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeData.buildLight(
          extensions: const [
            AppThemeContribution(
              featureKey: 'todo',
              value: TodoColorExtension.light,
            ),
            AppThemeContribution(
              featureKey: 'todo',
              value: TodoAssetExtension.light,
            ),
          ],
        ),
        home: Builder(
          builder: (context) {
            color = context.todoColor;
            asset = context.todoAsset;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(color.completed, const Color(0xFF16A34A));
    expect(asset.emptyState, 'assets/features/todo/todo_empty.png');
  });

  testWidgets('uses feature dark resources from the dark theme', (
    tester,
  ) async {
    late TodoColor color;
    late TodoAsset asset;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeData.buildDark(
          extensions: const [
            AppThemeContribution(
              featureKey: 'todo',
              value: TodoColorExtension.dark,
            ),
            AppThemeContribution(
              featureKey: 'todo',
              value: TodoAssetExtension.dark,
            ),
          ],
        ),
        home: Builder(
          builder: (context) {
            color = context.todoColor;
            asset = context.todoAsset;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(color.completed, const Color(0xFF4ADE80));
    expect(asset.emptyState, 'assets/features/todo/dark/todo_empty.png');
  });

  test('rejects duplicate extension types and reports their owners', () {
    expect(
      () => AppThemeData.buildLight(
        extensions: const [
          AppThemeContribution(
            featureKey: 'todo',
            value: TodoColorExtension.light,
          ),
          AppThemeContribution(
            featureKey: 'orders',
            value: TodoColorExtension.light,
          ),
        ],
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          allOf(contains('TodoColorExtension'), contains('todo and orders')),
        ),
      ),
    );
  });

  testWidgets('loads Todo-owned localization through its feature delegate', (
    tester,
  ) async {
    final registry = createAppFeatureRegistry(EnvTag.dev);
    late String todoEmpty;
    late String todoTitle;

    Future<void> pumpLocale(Locale locale) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: [
            ...AppLocalizations.supportedLocales,
            ...TodoLocalizations.supportedLocales,
          ],
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            ...registry.localizationDelegates,
          ],
          home: Builder(
            builder: (context) {
              todoEmpty = context.todoL10n.empty;
              todoTitle = context.todoL10n.createTitle;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }

    expect(registry.localizationDelegates, hasLength(1));
    await pumpLocale(const Locale('zh'));
    expect(todoEmpty, '暂无待办，添加一条试试吧');
    expect(todoTitle, '创建 Todo');

    await pumpLocale(const Locale('en'));
    expect(todoEmpty, 'No todos yet. Add one to get started.');
    expect(todoTitle, 'Create Todo');
  });
}
