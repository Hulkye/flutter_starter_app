import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'deep_link_config.dart';

/// 深链配置文件路径。
const deepLinkConfigAssetPath = 'config/deep_links.json';

/// 从与原生构建配置相同的 JSON 资源读取当前环境深链配置。
Future<DeepLinkConfig> loadDeepLinkConfig({
  required String environment,
  AssetBundle? bundle,
}) async {
  final content = await (bundle ?? rootBundle).loadString(
    deepLinkConfigAssetPath,
  );
  final decoded = jsonDecode(content);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'Deep link configuration must be a JSON object.',
    );
  }
  final environmentConfig = decoded[environment];
  if (environmentConfig is! Map<String, dynamic>) {
    throw FormatException('Missing deep link environment: $environment');
  }
  return DeepLinkConfig.fromJson(environmentConfig);
}

/// 尝试加载可选的深链配置；文件不存在表示未启用 Deep Link。
Future<DeepLinkConfig?> tryLoadDeepLinkConfig({
  required String environment,
  AssetBundle? bundle,
}) async {
  try {
    return await loadDeepLinkConfig(environment: environment, bundle: bundle);
  } on FlutterError catch (error) {
    if (error.message.contains('Unable to load asset')) return null;
    rethrow;
  }
}
