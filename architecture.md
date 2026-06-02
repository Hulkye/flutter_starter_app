# Flutter 项目架构技术文档 (Riverpod 2.x 标准版)

## 1. 文档目的
本文档定义了基于 **Flutter 3.x** 和 **Riverpod 2.x** 的企业级应用架构规范。旨在提供一套**高可维护、强类型安全、低模板代码**的开发范式。

## 2. 核心技术栈

| 类别 | 技术方案 | 选型理由 |
| :--- | :--- | :--- |
| **状态管理 & DI** | **Riverpod (Code Gen)** | 编译期安全，脱离 BuildContext，自动销毁。 |
| **路由** | **GoRouter** | 声明式路由，深度链接支持，可与 Riverpod 联动。 |
| **网络** | **Dio** | 拦截器机制完善，生态成熟。 |
| **代码生成** | **Freezed / Json Serializable** | 不可变数据模型，自动生成 `copyWith` 和序列化代码。 |

## 3. 架构总览

本项目采用 **“Feature-First (功能优先)”** 结合 **“Clean Architecture (简洁版)”** 的分层架构。

### 3.1 依赖流向原则
*   **Presentation** $\rightarrow$ **Domain** $\leftarrow$ **Data**
*   **禁止反向依赖**（如 Data 层禁止依赖 UI 层）。
*   **Riverpod** 作为贯穿所有层的“血管”，负责依赖注入和状态分发。

## 4. 目录结构规范

```
lib/
├── main.dart                 # 应用入口
├── core/                    # 全局核心模块（不依赖任何 Feature）
│   ├── di/                  # 全局依赖注入 (Providers)
│   ├── router/              # 全局路由配置
│   │   └── app_router.dart
│   ├── network/             # 网络服务
│   ├── theme/              # 主题样式
│   └── utils/              # 工具类
│
├── features/               # 【核心】业务功能模块
│   └── auth/               # 认证模块（示例）
│       ├── data/           # 数据层
│       │   ├── models/     # 数据模型 (DTO)
│       │   └── repositories/# 仓库实现
│       ├── domain/         # 领域层（业务逻辑核心）
│       │   ├── entities/   # 业务实体 (纯 Dart)
│       │   └── repositories/# 仓库接口 (Abstract)
│       └── presentation/   # 表现层
│           ├── pages/      # 页面 (Widgets)
│           ├── widgets/    # 页面私有组件
│           └── viewmodels/ # ViewModel (Riverpod Notifiers)
│               ├── login_vm.dart
│               └── auth_state.dart
│
└── shared/                 # 跨 Feature 共享资源
    ├── widgets/            # 通用组件
    │   └── page/           # 封装通用的业务场景基类page，各子业务页面继承
    └── services/
```
