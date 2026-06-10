import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prefs_storage.dart';
import 'secure_storage.dart';
import 'storage_service.dart';

// =============================================================================
// 存储实例（ProviderScope 创建前初始化）
// =============================================================================

/// 非敏感数据存储（SharedPreferences）。
///
/// 在 `Application.run()` 中调用 `prefsStorage.init()` 完成初始化。
final prefsStorage = PrefsStorage();

/// 敏感数据存储（FlutterSecureStorage — iOS Keychain / Android 加密存储）。
///
/// 在 `Application.run()` 中调用 `secureStorage.init()` 完成初始化。
final secureStorage = SecureStorage();

// =============================================================================
// Provider
// =============================================================================

/// 非敏感数据存储 Provider。
///
/// 使用前由 `Application.run()` 完成初始化。
final prefsStorageProvider = Provider<StorageService>((ref) => prefsStorage);

/// 敏感数据存储 Provider。
///
/// 使用前由 `Application.run()` 完成初始化。
final secureStorageProvider = Provider<StorageService>((ref) => secureStorage);
