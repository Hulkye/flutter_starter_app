/// 业务页面可用的 Feature 公共出口。
///
/// 只导出 route class 和明确需要跨模块使用的公开类型，避免业务页面通过
/// `header.dart` 间接依赖 Feature 的默认 data 装配实现。
library;

export 'auth/presentation/auth_routes.dart';
export 'profile/presentation/profile_routes.dart';
export 'todo/presentation/todo_routes.dart';
