import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/http/http_client.dart';
import '../../../../core/network/http/http_provider.dart';
import '../../../../core/network/http/response/api_response.dart';

/// Auth 远程数据源 —— 定义认证相关的 API 端点。
///
/// 职责：
/// - 调用 [HttpClient] 发送请求
/// - 将原始响应映射为 [ApiResponse]
/// - 不包含业务逻辑（业务逻辑在 [AuthRepositoryImpl] 中）
final class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final HttpClient _client;

  /// 登录。
  Future<ApiResponse<Map<String, dynamic>>> login(
    String username,
    String password,
  ) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{'username': username, 'password': password},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(data);
  }
}

/// Auth DataSource Provider。
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(httpClientProvider));
});
