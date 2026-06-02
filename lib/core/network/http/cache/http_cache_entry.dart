import '../shared/serialization_utils.dart';

/// 缓存条目实体 —— 可序列化到磁盘。
class HttpCacheEntry {
  const HttpCacheEntry({
    required this.key,
    required this.data,
    required this.createdAt,
    required this.expiresAt,
    required this.statusCode,
    required this.headers,
    required this.requestSignature,
    this.cachePolicy,
  });

  /// 缓存键。
  final String key;

  /// 缓存的响应数据。
  final dynamic data;

  /// 创建时间。
  final DateTime createdAt;

  /// 过期时间（null = 永不过期）。
  final DateTime? expiresAt;

  /// HTTP 状态码。
  final int? statusCode;

  /// 响应头。
  final Map<String, List<String>> headers;

  /// 请求签名（用于校验缓存有效性）。
  final String requestSignature;

  /// 缓存策略名称。
  final String? cachePolicy;

  /// 是否已过期。
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  // -----------------------------------------------------------------------
  // 序列化
  // -----------------------------------------------------------------------

  /// 转为 JSON。
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'data': encodeJsonFriendly(data),
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'statusCode': statusCode,
        'headers': headers,
        'requestSignature': requestSignature,
        'cachePolicy': cachePolicy,
      };

  /// 从 JSON 还原。
  static HttpCacheEntry fromJson(Map<String, dynamic> json) {
    return HttpCacheEntry(
      key: json['key'] as String,
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      statusCode: json['statusCode'] as int?,
      headers: (json['headers'] as Map<String, dynamic>? ??
              const <String, dynamic>{})
          .map(
            (dynamic key, dynamic value) => MapEntry(
              key as String,
              (value as List<dynamic>)
                  .map((dynamic e) => e.toString())
                  .toList(),
            ),
          ),
      requestSignature: json['requestSignature'] as String? ?? '',
      cachePolicy: json['cachePolicy'] as String?,
    );
  }
}
