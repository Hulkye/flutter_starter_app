/// Home 业务数据仓库接口（领域层）。
///
/// 定义 Feature 需要的数据操作契约，不依赖具体实现（Dio / HTTP / 数据库等）。
/// 实现在 [data/repositories/] 层。
abstract class HomeRepository {
  /// 获取示例数据。
  Future<Map<String, dynamic>> fetchDemo();
}
