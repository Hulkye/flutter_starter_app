import 'dart:async';

import 'package:app_links/app_links.dart';

import 'deep_link_source.dart';

/// 基于 `app_links` 的平台 URI 来源适配器。
final class AppLinksSource implements DeepLinkUriSource {
  AppLinksSource({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  @override
  /// 读取冷启动链接。
  Future<Uri?> getInitialUri() => _appLinks.getInitialLink();

  @override
  /// 监听 App 运行期间的链接事件。
  Stream<Uri> get uriStream => _appLinks.uriLinkStream;

  @override
  Future<void> dispose() async {}
}
