import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_starter_app/core/network/connection/connection_manager.dart';
import 'package:flutter_starter_app/core/network/connection/enum/connection_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectionManager', () {
    test(
      'reports unknown and not connected when initialization fails',
      () async {
        final fixture = _createManager(
          checkConnectivity: () async => throw StateError('plugin failed'),
        );

        expect(
          await fixture.manager.getConnectionType(),
          ConnectionType.unknown,
        );
        expect(await fixture.manager.isConnected(), isFalse);
      },
    );

    test(
      'reports unknown and not connected for empty connectivity result',
      () async {
        final fixture = _createManager(checkConnectivity: () async => []);

        expect(
          await fixture.manager.getConnectionType(),
          ConnectionType.unknown,
        );
        expect(await fixture.manager.isConnected(), isFalse);
      },
    );

    test('reports none and not connected for explicit none result', () async {
      final fixture = _createManager(
        checkConnectivity: () async => [ConnectivityResult.none],
      );

      expect(await fixture.manager.getConnectionType(), ConnectionType.none);
      expect(await fixture.manager.isConnected(), isFalse);
    });

    test('does not depend on the first connectivity result', () async {
      final fixture = _createManager(
        checkConnectivity: () async => [
          ConnectivityResult.other,
          ConnectivityResult.wifi,
        ],
      );

      expect(await fixture.manager.getConnectionType(), ConnectionType.wifi);
      expect(await fixture.manager.isConnected(), isTrue);
    });

    test('notifies listeners when connectivity changes', () async {
      final fixture = _createManager(
        checkConnectivity: () async => [ConnectivityResult.none],
      );
      final changes = <ConnectionType>[];

      fixture.manager.addConnectionChangeListener(changes.add);
      fixture.changes.add([ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);

      expect(changes, [ConnectionType.mobile]);
      expect(await fixture.manager.getConnectionType(), ConnectionType.mobile);
      expect(await fixture.manager.isConnected(), isTrue);
    });

    test('reports unknown and not connected when stream emits error', () async {
      final fixture = _createManager(
        checkConnectivity: () async => [ConnectivityResult.wifi],
      );
      expect(await fixture.manager.getConnectionType(), ConnectionType.wifi);

      fixture.changes.addError(StateError('stream failed'));
      await Future<void>.delayed(Duration.zero);

      expect(await fixture.manager.getConnectionType(), ConnectionType.unknown);
      expect(await fixture.manager.isConnected(), isFalse);
    });
  });
}

({
  ConnectionManager manager,
  StreamController<List<ConnectivityResult>> changes,
})
_createManager({required ConnectivityChecker checkConnectivity}) {
  final changes = StreamController<List<ConnectivityResult>>();
  final manager = ConnectionManager.test(
    checkConnectivity: checkConnectivity,
    connectivityChanged: changes.stream,
  );

  addTearDown(() async {
    await manager.dispose();
    await changes.close();
  });

  return (manager: manager, changes: changes);
}
