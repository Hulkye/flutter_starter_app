/// 一次导航请求的不可变目标。
///
/// [AppPageRoute] 描述路由注册信息；[AppRouteTarget] 描述本次导航要访问的
/// 实际地址，不参与路由注册。
abstract interface class AppRouteTarget {
  /// 目标的完整应用内 location。
  String get location;

  /// 仅适合当前进程内传递的附加数据。
  Object? get extra;
}

/// 不使用附加数据时可继承的 Target 基类。
abstract class AppRouteTargetBase implements AppRouteTarget {
  const AppRouteTargetBase();

  @override
  Object? get extra => null;
}

/// 已完成解析和校验的应用内导航目标。
final class AppRouteTargetValue implements AppRouteTarget {
  const AppRouteTargetValue({required this.location, this.extra});

  @override
  final String location;

  @override
  final Object? extra;
}

/// 路由 location 构造工具。
///
/// 各 Feature 的 Target 通过静态 `location(...)` 工厂生成导航地址；此
/// 工具集中处理共享的 URI 与路径参数编码逻辑。
abstract final class AppRouteLocation {
  /// 构造带 query 参数的 location。
  static String withQuery(String path, Map<String, String> queryParameters) {
    if (queryParameters.isEmpty) return path;
    return Uri(path: path, queryParameters: queryParameters).toString();
  }

  /// 将 path 参数替换为已编码的实际值。
  static String withPathParameters(
    String path,
    Map<String, String> pathParameters,
  ) {
    final parameterNames = <String>{};
    final resolvedPath = path.replaceAllMapped(RegExp(r':([A-Za-z0-9_]+)'), (
      match,
    ) {
      final name = match.group(1)!;
      final value = pathParameters[name];
      if (value == null || value.isEmpty) {
        throw ArgumentError.value(
          value,
          'pathParameters[$name]',
          'A non-empty value is required for path parameter "$name".',
        );
      }
      parameterNames.add(name);
      return Uri.encodeComponent(value);
    });

    final unexpectedNames = pathParameters.keys.toSet().difference(
      parameterNames,
    );
    if (unexpectedNames.isNotEmpty) {
      throw ArgumentError.value(
        unexpectedNames,
        'pathParameters',
        'Parameters are not present in route path "$path".',
      );
    }

    return resolvedPath;
  }
}
