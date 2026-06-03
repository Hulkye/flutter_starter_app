import 'dart:convert';

/// 认证会话 —— token + 灵活 payload。
///
/// 只定义 token / refreshToken，其他业务字段通过 [payload] 存取，
/// 不与具体后端绑定。
class AuthSession {
  const AuthSession({
    required this.token,
    this.refreshToken,
    this.payload = const {},
  });

  final String token;
  final String? refreshToken;
  final Map<String, dynamic> payload;

  bool get isValid => token.isNotEmpty;

  /// 从 payload 按类型读取字段。
  T? get<T>(String key) => payload[key] as T?;

  /// Bearer token，用于 Authorization header。
  String get bearerToken => 'Bearer $token';

  // ---- JSON ----

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    token: json['token'] as String? ?? '',
    refreshToken: json['refreshToken'] as String?,
    payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
  );

  Map<String, dynamic> toJson() => {
    'token': token,
    if (refreshToken != null) 'refreshToken': refreshToken,
    'payload': payload,
  };

  // ---- 序列化工具 ----

  factory AuthSession.fromJsonString(String raw) =>
      AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() =>
      'AuthSession(token: ${token.length > 8 ? token.substring(0, 8) : token}...)';
}
