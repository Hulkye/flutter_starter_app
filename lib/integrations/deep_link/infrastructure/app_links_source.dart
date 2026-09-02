import 'dart:async';

import 'package:app_links/app_links.dart';

/// app_links 的最小平台事件适配。
final class AppLinksSource {
  AppLinksSource({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  /// 初始及后续链接事件流。
  Stream<Uri> get uriStream => _appLinks.uriLinkStream;

  /// 订阅链接事件。
  StreamSubscription<Uri> listen(void Function(Uri uri) onData) {
    return uriStream.listen(onData);
  }
}
