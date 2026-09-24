import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'deep_link_config.dart';

/// App 资源中 Deep Link 配置文件的固定路径。
const deepLinkConfigAssetPath = 'config/deep_links.json';

/// 从配置资源中读取指定环境的 Deep Link 配置。
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

/// 尝试读取可选配置。
///
/// 配置资源不存在表示宿主未启用 Deep Link，其他格式或环境错误继续抛出，
/// 避免把错误配置静默当成未启用。
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
