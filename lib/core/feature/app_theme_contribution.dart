/// Feature 向 App 提供的主题资源贡献，不依赖 Flutter UI 类型。
final class AppThemeContribution {
  const AppThemeContribution({required this.featureKey, required this.value});

  final String featureKey;
  final Object value;
}
