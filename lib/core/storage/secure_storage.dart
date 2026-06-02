import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_service.dart';

/// 基于 [FlutterSecureStorage] 的存储实现。
///
/// 用于存储敏感数据：token、密码、密钥等。
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
///
/// 非 String 类型通过序列化存储（int/bool/double → toString，list → JSON）。
///
/// 使用前应调用 [init] 以缓存当前所有 key：
/// ```dart
/// final secure = SecureStorage();
/// await secure.init();
/// ```
final class SecureStorage implements StorageService {
  SecureStorage({
    FlutterSecureStorage? storage,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) : _storage =
           storage ??
           FlutterSecureStorage(
             iOptions: iOptions ?? _defaultIOSOptions,
             aOptions: aOptions ?? _defaultAndroidOptions,
           );

  static const _defaultIOSOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  static const _defaultAndroidOptions = AndroidOptions();

  final FlutterSecureStorage _storage;
  final Set<String> _keys = {};

  @override
  Future<void> init() async {
    final all = await _storage.readAll();
    _keys.clear();
    _keys.addAll(all.keys);
  }

  // ---- 通用 ----

  @override
  bool containsKey(String key) => _keys.contains(key);

  @override
  Set<String> getKeys() => Set.unmodifiable(_keys);

  @override
  Future<bool> remove(String key) async {
    await _storage.delete(key: key);
    _keys.remove(key);
    return true;
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
    _keys.clear();
  }

  // ---- String ----

  @override
  Future<bool> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
    _keys.add(key);
    return true;
  }

  @override
  String? getString(String key) {
    throw UnsupportedError(
      'SecureStorage.getString is synchronous but underlying storage is async. '
      'Use readString instead.',
    );
  }

  /// 异步读取字符串。
  Future<String?> readString(String key) => _storage.read(key: key);

  // ---- int ----

  @override
  Future<bool> setInt(String key, int value) =>
      setString(key, value.toString());

  @override
  int? getInt(String key, {int? defaultValue}) {
    throw UnsupportedError(
      'SecureStorage.getInt is synchronous. Use readInt instead.',
    );
  }

  /// 异步读取 int。
  Future<int?> readInt(String key, {int? defaultValue}) async {
    final v = await _storage.read(key: key);
    if (v == null) return defaultValue;
    return int.tryParse(v) ?? defaultValue;
  }

  // ---- bool ----

  @override
  Future<bool> setBool(String key, bool value) =>
      setString(key, value.toString());

  @override
  bool? getBool(String key, {bool? defaultValue}) {
    throw UnsupportedError(
      'SecureStorage.getBool is synchronous. Use readBool instead.',
    );
  }

  /// 异步读取 bool。
  Future<bool?> readBool(String key, {bool? defaultValue}) async {
    final v = await _storage.read(key: key);
    if (v == null) return defaultValue;
    return v == 'true';
  }

  // ---- double ----

  @override
  Future<bool> setDouble(String key, double value) =>
      setString(key, value.toString());

  @override
  double? getDouble(String key, {double? defaultValue}) {
    throw UnsupportedError(
      'SecureStorage.getDouble is synchronous. Use readDouble instead.',
    );
  }

  /// 异步读取 double。
  Future<double?> readDouble(String key, {double? defaultValue}) async {
    final v = await _storage.read(key: key);
    if (v == null) return defaultValue;
    return double.tryParse(v) ?? defaultValue;
  }

  // ---- String List ----

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      setString(key, jsonEncode(value));

  @override
  List<String>? getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    throw UnsupportedError(
      'SecureStorage.getStringList is synchronous. Use readStringList instead.',
    );
  }

  /// 异步读取 String List。
  Future<List<String>?> readStringList(
    String key, {
    List<String> defaultValue = const [],
  }) async {
    final v = await _storage.read(key: key);
    if (v == null) return defaultValue;
    try {
      return (jsonDecode(v) as List<dynamic>).cast<String>();
    } catch (_) {
      return defaultValue;
    }
  }
}
