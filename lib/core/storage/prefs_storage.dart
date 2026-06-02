import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// 基于 [SharedPreferences] 的存储实现。
///
/// 用于存储非敏感数据：用户偏好设置、UI 状态缓存、应用配置等。
///
/// 使用前必须调用 [init]：
/// ```dart
/// final prefs = PrefsStorage();
/// await prefs.init();
/// ```
final class PrefsStorage implements StorageService {
  SharedPreferences? _prefs;

  SharedPreferences get _p {
    final p = _prefs;
    if (p == null)
      throw StateError('PrefsStorage not initialized. Call init() first.');
    return p;
  }

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  bool containsKey(String key) => _p.containsKey(key);

  @override
  Set<String> getKeys() => _p.getKeys();

  // ---- String ----

  @override
  Future<bool> setString(String key, String value) => _p.setString(key, value);

  @override
  String? getString(String key) => _p.getString(key);

  // ---- int ----

  @override
  Future<bool> setInt(String key, int value) => _p.setInt(key, value);

  @override
  int? getInt(String key, {int? defaultValue}) =>
      _p.getInt(key) ?? defaultValue;

  // ---- bool ----

  @override
  Future<bool> setBool(String key, bool value) => _p.setBool(key, value);

  @override
  bool? getBool(String key, {bool? defaultValue}) =>
      _p.getBool(key) ?? defaultValue;

  // ---- double ----

  @override
  Future<bool> setDouble(String key, double value) => _p.setDouble(key, value);

  @override
  double? getDouble(String key, {double? defaultValue}) =>
      _p.getDouble(key) ?? defaultValue;

  // ---- String List ----

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _p.setStringList(key, value);

  @override
  List<String>? getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) => _p.getStringList(key) ?? defaultValue;

  // ---- 通用 ----

  @override
  Future<bool> remove(String key) => _p.remove(key);

  @override
  Future<void> clear() => _p.clear();
}
