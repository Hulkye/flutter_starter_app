import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/http/http_client.dart';
import '../../../../core/network/http/http_provider.dart';
import '../../domain/repositories/home_repository.dart';

/// [HomeRepository] 的 HTTP 实现（数据层）。
///
/// 直接依赖 [HttpClient]（简单场景可跳过 DataSource 层）。
/// 复杂场景应参考 Auth Feature 的 DataSource + Repository 模式。
final class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._client);

  final HttpClient _client;

  @override
  Future<Map<String, dynamic>> fetchDemo() {
    return _client.get<Map<String, dynamic>>(
      '/get',
      queryParameters: <String, dynamic>{
        'ts': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      loggingEnabled: true,
    );
  }
}

/// HomeRepository Provider。
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(httpClientProvider));
});
