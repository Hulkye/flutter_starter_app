import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'enum/connection_type.dart';

///网络状态监听回调
typedef ConnectionChangeListener = void Function(ConnectionType result);
typedef ConnectivityChecker = Future<List<ConnectivityResult>> Function();

///网络连接管理类
class ConnectionManager {
  static ConnectionManager instance = ConnectionManager._fromConnectivity(
    Connectivity(),
  );

  final Completer<void> _initFinish = Completer<void>();
  final List<ConnectionChangeListener> _listenerList =
      <ConnectionChangeListener>[];
  final ConnectivityChecker _checkConnectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectionType _curType = ConnectionType.unknown;

  ConnectionManager._fromConnectivity(Connectivity connectivity)
    : this._(
        checkConnectivity: connectivity.checkConnectivity,
        connectivityChanged: connectivity.onConnectivityChanged,
      );

  ConnectionManager._({
    required ConnectivityChecker checkConnectivity,
    required Stream<List<ConnectivityResult>> connectivityChanged,
  }) : _checkConnectivity = checkConnectivity {
    unawaited(loadConnection());
    _subscription = connectivityChanged.listen(
      _handleConnectivityResults,
      onError: (_) {
        _setConnectionType(ConnectionType.unknown);
        _completeInit();
      },
    );
  }

  /// 测试专用构造，避免单测依赖平台插件。
  ConnectionManager.test({
    required ConnectivityChecker checkConnectivity,
    required Stream<List<ConnectivityResult>> connectivityChanged,
  }) : this._(
         checkConnectivity: checkConnectivity,
         connectivityChanged: connectivityChanged,
       );

  Future<void> dispose() async {
    await _subscription.cancel();
    _listenerList.clear();
  }

  Future<void> loadConnection() async {
    try {
      final connResult = await _checkConnectivity();
      _setConnectionType(_changeConnectType(connResult), notify: false);
    } catch (_) {
      _setConnectionType(ConnectionType.unknown, notify: false);
    } finally {
      _completeInit();
    }
  }

  ///判断是否有网络
  Future<bool> isConnected() async {
    final type = await getConnectionType();
    return _isConnectedType(type);
  }

  ///添加网络状态变化监听器
  void addConnectionChangeListener(ConnectionChangeListener listener) {
    if (!_listenerList.contains(listener)) {
      _listenerList.add(listener);
    }
  }

  ///移除网络状态变化监听器
  void removeConnectionChangeListener(ConnectionChangeListener listener) {
    _listenerList.remove(listener);
  }

  /// 本地类型转换
  ConnectionType _changeConnectType(List<ConnectivityResult> connResult) {
    if (connResult.isEmpty) return ConnectionType.unknown;
    if (connResult.contains(ConnectivityResult.wifi)) {
      return ConnectionType.wifi;
    }
    if (connResult.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.ethernet;
    }
    if (connResult.contains(ConnectivityResult.mobile)) {
      return ConnectionType.mobile;
    }
    if (connResult.contains(ConnectivityResult.vpn)) {
      return ConnectionType.vpn;
    }
    if (connResult.contains(ConnectivityResult.satellite)) {
      return ConnectionType.satellite;
    }
    if (connResult.contains(ConnectivityResult.bluetooth)) {
      return ConnectionType.bluetooth;
    }
    if (connResult.contains(ConnectivityResult.other)) {
      return ConnectionType.other;
    }
    if (connResult.every((item) => item == ConnectivityResult.none)) {
      return ConnectionType.none;
    }
    return ConnectionType.unknown;
  }

  /// 获取当前网络连接类型
  Future<ConnectionType> getConnectionType() async {
    try {
      if (!_initFinish.isCompleted) {
        await _initFinish.future;
      }
    } catch (_) {
      return ConnectionType.unknown;
    }
    return _curType;
  }

  void _handleConnectivityResults(List<ConnectivityResult> data) {
    _setConnectionType(_changeConnectType(data));
    _completeInit();
  }

  void _setConnectionType(ConnectionType type, {bool notify = true}) {
    _curType = type;
    if (!notify) return;
    for (final item in List<ConnectionChangeListener>.of(_listenerList)) {
      item.call(_curType);
    }
  }

  void _completeInit() {
    if (!_initFinish.isCompleted) {
      _initFinish.complete();
    }
  }

  bool _isConnectedType(ConnectionType type) {
    return switch (type) {
      ConnectionType.wifi ||
      ConnectionType.ethernet ||
      ConnectionType.mobile ||
      ConnectionType.bluetooth ||
      ConnectionType.vpn ||
      ConnectionType.satellite ||
      ConnectionType.other => true,
      ConnectionType.none || ConnectionType.unknown => false,
    };
  }
}
