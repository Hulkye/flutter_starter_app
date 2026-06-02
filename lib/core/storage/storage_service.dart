/// 存储服务抽象接口。
///
/// 提供统一的键值存储 API，不依赖具体实现（SharedPreferences / SecureStorage / 数据库）。
///
/// 实现类：
/// - [PrefsStorage] — SharedPreferences（非敏感数据：设置、缓存）
/// - [SecureStorage] — FlutterSecureStorage（敏感数据：token、凭证）
abstract interface class StorageService {
  /// 初始化存储引擎。使用前必须调用一次。
  Future<void> init();

  // ---- String ----

  Future<bool> setString(String key, String value);
  String? getString(String key);

  // ---- int ----

  Future<bool> setInt(String key, int value);
  int? getInt(String key, {int? defaultValue});

  // ---- bool ----

  Future<bool> setBool(String key, bool value);
  bool? getBool(String key, {bool? defaultValue});

  // ---- double ----

  Future<bool> setDouble(String key, double value);
  double? getDouble(String key, {double? defaultValue});

  // ---- String List ----

  Future<bool> setStringList(String key, List<String> value);
  List<String>? getStringList(String key, {List<String> defaultValue = const []});

  // ---- 通用 ----

  Future<bool> remove(String key);
  Future<void> clear();
  bool containsKey(String key);
  Set<String> getKeys();
}
