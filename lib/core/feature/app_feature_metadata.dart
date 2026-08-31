import '../config/env_config.dart';

/// Feature 的注册元数据。
final class AppFeatureMetadata {
  const AppFeatureMetadata({
    required this.key,
    this.priority = 0,
    this.enabledEnvironments = const <EnvTag>{
      EnvTag.dev,
      EnvTag.sit,
      EnvTag.prod,
    },
    this.permissions = const <String>{},
    this.experimental = false,
  });

  /// Feature 的全局唯一标识。
  final String key;

  /// Feature 的排序优先级，数值越小越靠前。
  final int priority;

  /// 允许启用该 Feature 的环境集合。
  final Set<EnvTag> enabledEnvironments;

  /// Feature 声明所需的业务权限 key，不负责执行鉴权。
  final Set<String> permissions;

  /// 是否为实验性 Feature，仅用于标识。
  final bool experimental;

  /// 判断当前环境是否启用该 Feature。
  bool isEnabledIn(EnvTag environment) =>
      enabledEnvironments.contains(environment);
}
