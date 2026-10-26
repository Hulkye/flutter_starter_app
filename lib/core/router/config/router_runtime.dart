import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/go_router/router_provider.dart' as default_runtime;

/// 创建 Router 模块默认 runtime 的 Provider 覆盖项。
///
/// App 组合层使用该稳定入口，不依赖具体路由引擎。
List<Override> createRouterRuntimeOverrides() =>
    default_runtime.createGoRouterRuntimeOverrides();
