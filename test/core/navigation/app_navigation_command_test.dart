import 'package:flutter_starter_app/core/navigation/app_navigation_command.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppNavigationCommand', () {
    test('builds location with path and query parameters', () {
      const command = AppNavigationCommand(
        path: '/profile/:userId',
        pathParameters: <String, String>{'userId': 'user/1'},
        queryParameters: <String, String>{'tab': 'posts'},
        source: AppNavigationSource.push,
        requiresAuthentication: true,
      );

      expect(command.location, '/profile/user%2F1?tab=posts');
    });

    test('keeps plain path when no parameters exist', () {
      const command = AppNavigationCommand(
        path: '/todo',
        source: AppNavigationSource.internal,
        requiresAuthentication: false,
      );

      expect(command.location, '/todo');
    });
  });
}
