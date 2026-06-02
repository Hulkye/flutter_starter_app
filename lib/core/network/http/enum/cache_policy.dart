/// HTTP 缓存策略枚举。
enum CachePolicy {
  /// 不使用缓存。
  noCache,

  /// 优先读缓存，缓存未命中时走网络。
  cacheFirst,

  /// 优先走网络，失败后回退到缓存。
  networkFirst,

  /// 仅读缓存（离线模式）。
  cacheOnly,

  /// 仅走网络。
  networkOnly,

  /// 立即返回缓存数据，同时在后台静默刷新。
  staleWhileRevalidate,
}
