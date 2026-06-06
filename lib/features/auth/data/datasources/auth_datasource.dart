import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/http/response/api_response.dart';

/// Auth 远程数据源 —— 定义认证相关的 API 端点。
///
/// 职责：
/// - 调用 [HttpClient] 发送请求
/// - 将原始响应映射为 [ApiResponse]
/// - 不包含业务逻辑（业务逻辑在 [AuthRepositoryImpl] 中）
final class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  /// 登录。
  Future<ApiResponse<Map<String, dynamic>>> login(
    String username,
    String password,
  ) async {
    // 模板演示：不依赖真实后端，输入任意账号密码均可登录。
    // 接入真实业务时，可恢复为调用 [_client.post] 并按后端协议解析响应。
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ApiResponse<Map<String, dynamic>>(
      code: 0,
      message: 'success',
      data: <String, dynamic>{
        'token': 'demo-token-${DateTime.now().millisecondsSinceEpoch}',
        'username': username,
      },
    );
  }
}

/// Auth DataSource Provider。
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return const AuthRemoteDataSource();
});
