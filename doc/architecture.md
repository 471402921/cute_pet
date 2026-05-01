# Architecture

## 总览

cute_pet 是 Flutter + GetX + Flame 的学习型项目。架构上参考 spec_flow 的 **DDD Light** 思想,落到 Flutter 上做了适配。Flame 仅用于宠物/动画场景,不主体化。

## 分层(DDD Light for Flutter)

每个**业务模块**(`lib/features/{module}/`)按四层组织:

```
features/{module}/
├── presentation/                  # UI 层
│   ├── {module}_page.dart         # Scaffold / 视图组合
│   ├── {module}_controller.dart   # GetxController(状态 + 用户交互)
│   ├── {module}_binding.dart      # Get.lazyPut 注入
│   └── widgets/                   # 模块内私有 widget
├── application/                   # 用例层(简单模块可省略)
│   └── {module}_service.dart      # 编排多个仓储 / 跨实体逻辑
├── domain/                        # 领域层 ⚠️ 纯 Dart, 无任何框架引用
│   ├── entities/                  # 实体(行为 + 数据)
│   ├── value_objects/             # 值对象(不可变, 等值靠属性)
│   └── repositories/              # 仓储**接口**(只声明)
└── infrastructure/                # 基础设施层
    ├── repositories/              # 仓储实现(实现 domain 的接口)
    ├── data_sources/              # API client / 本地存储 / DB 适配器
    └── dto/                       # API 数据传输对象 + 与 entity 互转
```

### 关键铁律

**`domain/` 必须框架无关**。打开任意一个 `domain/` 下的文件,你**不应**看到:
- `import 'package:flutter/...'`
- `import 'package:get/...'`
- `import 'package:dio/...'`
- `import 'package:flame/...'`
- 任何包装框架的注解

domain 类是纯 Dart。它们通过 infrastructure 层的 converter 与 DTO 互转。

**为什么**:领域逻辑应该可以脱离 Flutter 跑单元测试,不依赖 widget 树、不依赖 GetX 容器、不依赖 Dio。换框架时 domain 层不需要改。

## Common(跨模块共享)目录

```
lib/
├── main.dart                      # 入口
├── app/                           # App 级配置
│   ├── app_routes.dart            # 路由常量
│   ├── app_pages.dart             # GetPage 列表
│   ├── app_binding.dart           # 全局 binding(单例服务)
│   └── app_theme.dart             # 主题
├── core/                          # 跨切关注点(基础设施零件)
│   ├── network/                   # HTTP client(Dio + 拦截器, 待加)
│   ├── storage/                   # 本地存储封装(待加)
│   ├── error/                     # Failure 类型(domain 层错误用, 纯 Dart)
│   └── utils/                     # 纯函数工具
├── shared/                        # 跨模块共享 UI / 模型
│   └── widgets/                   # 跨模块复用 widget
└── features/                      # 业务模块(每个模块按上面的 DDD Light 分层)
```

### core/ vs shared/

- `core/` 偏**基础设施 / 通用能力**,业务无关(网络、存储、错误类型、工具函数)
- `shared/` 偏**跨模块的 UI 或模型**(同一个按钮多模块都用、同一个值对象多模块都用)
- 单一模块独占的东西**不放这里**,放进 `features/{module}/` 内部

### core/error/ 的特殊性

`core/error/` 里放的 `Failure` 类型属于**领域语义**(如 `NetworkFailure`, `NotFoundFailure`, `ValidationFailure`),所以也是**纯 Dart**,不能依赖任何框架。它服务于所有 features 的 `domain/`。

## 与后端的契约(参考 spec_flow_frontend)

如果接入 spec_flow 后端,统一约定:

- 响应格式 `{code, message, data, traceId}`,`code == 0` 为成功
- 鉴权 `Authorization: Bearer <token>`
- HTTP 错误统一映射:
  - 401 → 清 token + 跳登录
  - 403 → 提示无权限
  - 422/400 → 展示 message
  - 500 → 提示服务异常,记 traceId
  - 超时 → 提示网络异常,可重试
- HTTP 拦截在 `core/network/` 内统一处理,业务层不做 HTTP 异常处理

后端接入前,`core/network/` 暂空。

## 现有代码的状态

⚠️ `features/home/` 和 `features/pet/` 是**第一版脚手架**,**未**按上面的四层分。它们没有真实的 domain 逻辑(没有实体、没有仓储),所以暂时只用 `presentation/` 三件套(page/controller/binding)。

当任意一个模块开始有**真实业务逻辑**(比如 pet 接入档案数据、健康数据)时,把它**重构成完整四层结构**,作为后续模块的参考样板。

## Flame 的位置

Flame 是 `features/pet/` 的 **presentation 层**实现细节(`pet_game.dart` 是一个 widget 内部用的 FlameGame)。Flame 不出现在 domain/ 或 application/。把宠物的属性、状态、行为(domain)和 Flame 的渲染(presentation)分开,可以让宠物逻辑用普通单元测试覆盖。
