/// 存储模块 —— 统一的键值存储抽象。
///
/// ## 架构
///
/// ```
/// StorageService (抽象接口)
///   ├── PrefsStorage   → SharedPreferences（非敏感：设置、缓存）
///   └── SecureStorage  → FlutterSecureStorage（敏感：token、凭证）
///
/// prefsStorageProvider  /  secureStorageProvider   → Riverpod 注入
/// ```
///
/// ## 使用
///
/// ```dart
/// // 读取
/// final mode = ref.read(prefsStorageProvider).getInt('theme_mode');
///
/// // 写入（fire-and-forget）
/// unawaited(ref.read(prefsStorageProvider).setInt('theme_mode', 1));
///
/// // 安全存储（异步读）
/// final token = await (ref.read(secureStorageProvider) as SecureStorage)
///     .readString('access_token');
/// ```
library;

export 'storage_service.dart';
export 'prefs_storage.dart';
export 'secure_storage.dart';
export 'storage_provider.dart';
