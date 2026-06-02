import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'enum/connection_type.dart';

///网络状态监听回调
typedef ConnectionChangeListener = void Function(ConnectionType result);

///网络连接管理类
class ConnectionManager {
  static ConnectionManager instance = ConnectionManager._();

  final Completer<bool> _initFinish = Completer();
  final List<ConnectionChangeListener> _listenerList =
      <ConnectionChangeListener>[];

  ConnectionType _curType = ConnectionType.none;

  ConnectionManager._() {
    loadConnection();
    Connectivity().onConnectivityChanged.listen((data) {
      _curType = _changeConnectType(data);
      if (!_initFinish.isCompleted) {
        _initFinish.complete(true);
      }
      for (final item in _listenerList) {
        item.call(_curType);
      }
    });
  }

  void loadConnection() async {
    try {
      final connResult = await Connectivity().checkConnectivity();
      _curType = _changeConnectType(connResult);
    } catch (_) {
    } finally {
      if (!_initFinish.isCompleted) {
        _initFinish.complete(true);
      }
    }
  }

  ///判断是否有网络
  Future<bool> isConnected() async {
    bool result = true;
    try {
      if (!_initFinish.isCompleted) {
        await _initFinish.future;
      }
      result = _curType != ConnectionType.none;
    } catch (e) {
      // 异常情况，设置为true，让后续流程去做二次判断处理
      result = true;
    }
    return result;
  }

  ///添加网络状态变化监听器
  void addConnectionChangeListener(ConnectionChangeListener listener) {
    if (!_listenerList.contains(listener)) {
      _listenerList.add(listener);
    }
    if (_listenerList.isNotEmpty) {}
  }

  ///移除网络状态变化监听器
  void removeConnectionChangeListener(ConnectionChangeListener listener) {
    _listenerList.remove(listener);
  }

  /// 本地类型转换
  ConnectionType _changeConnectType(List<ConnectivityResult> connResult) {
    switch (connResult.first) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      default:
        return ConnectionType.none;
    }
  }

  /// 获取当前网络连接类型
  Future<ConnectionType> getConnectionType() async {
    try {
      if (!_initFinish.isCompleted) {
        await _initFinish.future;
      }
    } catch (_) {}
    return _curType;
  }
}
