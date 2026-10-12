import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const state = AppRouteState(
    location: '/profile/42?tab=posts',
    pathParameters: <String, String>{'userId': '42'},
    queryParameters: <String, String>{'tab': 'posts', 'empty': ''},
    extra: _TestExtra('source'),
  );

  test('reads required and optional route parameters', () {
    expect(state.requiredPathParameter('userId'), '42');
    expect(state.requiredQueryParameter('tab'), 'posts');
    expect(state.optionalQueryParameter('tab'), 'posts');
    expect(state.optionalQueryParameter('empty'), isNull);
    expect(state.optionalQueryParameter('missing'), isNull);
  });

  test('rejects missing required route parameters', () {
    expect(() => state.requiredPathParameter('missing'), throwsFormatException);
    expect(() => state.requiredQueryParameter('empty'), throwsFormatException);
  });

  test('reads typed extra and rejects a mismatched type', () {
    expect(state.requiredExtra<_TestExtra>().value, 'source');
    expect(() => state.requiredExtra<String>(), throwsStateError);
  });
}

final class _TestExtra {
  const _TestExtra(this.value);

  final String value;
}
