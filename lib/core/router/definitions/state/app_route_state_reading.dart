import 'app_route_state.dart';

/// [AppRouteState] 的严格参数读取方法。
extension AppRouteStateReading on AppRouteState {
  /// 读取必需的 path 参数；缺失或为空时抛出 [FormatException]。
  String requiredPathParameter(String key) {
    final value = pathParameters[key];
    if (value == null || value.isEmpty) {
      throw FormatException('Missing required path parameter: $key');
    }
    return value;
  }

  /// 读取必需的 query 参数；缺失或为空时抛出 [FormatException]。
  String requiredQueryParameter(String key) {
    final value = queryParameters[key];
    if (value == null || value.isEmpty) {
      throw FormatException('Missing required query parameter: $key');
    }
    return value;
  }

  /// 读取可选的 query 参数。
  String? optionalQueryParameter(String key) {
    final value = queryParameters[key];
    return value == null || value.isEmpty ? null : value;
  }

  /// 读取指定类型的进程内附加数据。
  T requiredExtra<T extends Object>() {
    final value = extra;
    if (value is! T) {
      throw StateError(
        'Expected route extra of type $T, got ${value.runtimeType}',
      );
    }
    return value;
  }
}
