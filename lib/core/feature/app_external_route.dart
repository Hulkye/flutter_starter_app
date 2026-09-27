import '../router/router.dart';

/// Feature 暴露给 App 外部入口的路由声明。
///
/// 这是宿主层契约，不依赖具体 Deep Link、Push 或平台 package。外部入口
/// 适配层可以将它转换为对应平台的路由描述。
final class AppExternalRoute {
  const AppExternalRoute({required this.key, required this.route});

  /// 外部入口使用的稳定标识。
  final String key;

  /// 对应的 App 页面路由。
  final AppPageRoute route;
}