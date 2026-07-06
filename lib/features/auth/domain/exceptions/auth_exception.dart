/// 认证领域异常。
///
/// Domain 层只表达认证失败语义，不携带 UI 文案兜底逻辑。
sealed class AuthException implements Exception {
  const AuthException({this.code, this.message});

  final int? code;
  final String? message;
}

/// 登录被业务侧拒绝，例如账号密码错误或后端返回认证失败状态码。
final class AuthLoginRejectedException extends AuthException {
  const AuthLoginRejectedException({super.code, super.message});

  @override
  String toString() {
    return 'AuthLoginRejectedException(code: $code, message: $message)';
  }
}

/// 登录响应结构无法建立有效会话，例如 token 缺失。
final class AuthInvalidResponseException extends AuthException {
  const AuthInvalidResponseException({super.code, super.message});

  @override
  String toString() {
    return 'AuthInvalidResponseException(code: $code, message: $message)';
  }
}
