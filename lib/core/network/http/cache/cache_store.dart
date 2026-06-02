import 'dart:convert';
import 'dart:io';

import 'http_cache_entry.dart';

/// HTTP 缓存存储抽象。
abstract class HttpCacheStore {
  /// 读取缓存。
  Future<HttpCacheEntry?> read(String key);

  /// 写入缓存。
  Future<void> write(HttpCacheEntry entry);

  /// 删除指定 key。
  Future<void> remove(String key);

  /// 清空全部缓存。
  Future<void> clear();

  /// 清理过期条目，返回清理数量。
  Future<int> clearExpired();

  /// 当前缓存条目数量。
  Future<int> count();
}

// =======================================================================
// 内存缓存实现
// =======================================================================

/// 基于内存 Map 的缓存存储，适合临时 / 热数据。
class MemoryHttpCacheStore implements HttpCacheStore {
  final Map<String, HttpCacheEntry> _items = <String, HttpCacheEntry>{};

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<int> count() async => _items.length;

  @override
  Future<int> clearExpired() async {
    final expiredKeys = _items.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();
    for (final key in expiredKeys) {
      _items.remove(key);
    }
    return expiredKeys.length;
  }

  @override
  Future<HttpCacheEntry?> read(String key) async => _items[key];

  @override
  Future<void> remove(String key) async => _items.remove(key);

  @override
  Future<void> write(HttpCacheEntry entry) async => _items[entry.key] = entry;
}

// =======================================================================
// 磁盘缓存实现
// =======================================================================

/// 基于文件的缓存存储，适合持久化 / 冷数据。
class FileHttpCacheStore implements HttpCacheStore {
  FileHttpCacheStore({Directory? directory})
      : _directory = directory ??
            Directory(
              '${Directory.systemTemp.path}/http3_cache',
            );

  final Directory _directory;

  Future<void> _ensureDir() async {
    if (!await _directory.exists()) {
      await _directory.create(recursive: true);
    }
  }

  String _safeName(String key) => base64Url.encode(utf8.encode(key));

  File _file(String key) => File('${_directory.path}/${_safeName(key)}.json');

  @override
  Future<void> clear() async {
    if (await _directory.exists()) {
      await _directory.delete(recursive: true);
    }
  }

  @override
  Future<int> count() async {
    if (!await _directory.exists()) return 0;
    return _directory
        .list(recursive: false, followLinks: false)
        .where((e) => e is File)
        .length;
  }

  @override
  Future<int> clearExpired() async {
    if (!await _directory.exists()) return 0;
    var removed = 0;
    await for (final entity in _directory.list(
      recursive: false,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      try {
        final raw = await entity.readAsString();
        if (raw.isEmpty) continue;
        final entry = HttpCacheEntry.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        if (entry.isExpired) {
          await entity.delete();
          removed += 1;
        }
      } catch (_) {
        await entity.delete();
        removed += 1;
      }
    }
    return removed;
  }

  @override
  Future<HttpCacheEntry?> read(String key) async {
    final file = _file(key);
    if (!await file.exists()) return null;
    final raw = await file.readAsString();
    if (raw.isEmpty) return null;
    return HttpCacheEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> remove(String key) async {
    final file = _file(key);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> write(HttpCacheEntry entry) async {
    await _ensureDir();
    await _file(entry.key).writeAsString(jsonEncode(entry.toJson()));
  }
}
