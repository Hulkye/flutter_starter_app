/// 缓存统计信息。
class HttpCacheInfo {
  const HttpCacheInfo({
    required this.memoryCount,
    required this.diskCount,
    required this.totalCount,
  });

  /// 内存缓存条目数。
  final int memoryCount;

  /// 磁盘缓存条目数。
  final int diskCount;

  /// 总条目数。
  final int totalCount;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'memoryCount': memoryCount,
    'diskCount': diskCount,
    'totalCount': totalCount,
  };
}
