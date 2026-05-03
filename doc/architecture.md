# Architecture

## 设计目标

cute_pixel 是 Flutter + GetX + Flame 应用。架构上的首要目标是**减少 AI 与人在跨模块工作时的上下文负担**:做某个模块的事,只需要看一个文件夹;读架构文档,只需要看几条铁律。

DDD 的分层精神(模块自治、单向依赖、共享集中)被保留,**不**照搬后端 4 层结构 —— 前端业务大头在后端,前端主要是 UI + 状态 + API 调用,4 层会产生大量空壳层,反而增加上下文负担。

具体的代码标准(错误处理、i18n、测试、日志、lint 等)见 [conventions.md](conventions.md)。

## 状态标记说明

下文凡是写到具体文件路径或服务的地方,都带一个 **Status** 标:
- `planned` — 文档里描述了,但代码还**没有**这个文件/类。**禁止直接 import**,要用得先实现(或先和用户对齐再实现)。
- `scaffolded` — 文件已存在,但当前没有 `features/` 模块在 import。可以直接接入,但要意识到这是首次接入。
- `in-use` — 文件已存在且至少被一个 `features/` 模块在用,接入风险最低。

Agent 在生成 import 语句之前**必须**先核对 Status。Status 与代码事实漂移时,以代码为准并就地修订本文档。

## 顶层目录

```
lib/
├── main.dart                      # 入口                                       [in-use]
├── app/                           # App 级配置(全局,不属于任何业务模块)
│   ├── app_routes.dart            # 路由常量                                   [in-use]
│   ├── app_pages.dart             # GetPage 列表                               [in-use]
│   ├── app_binding.dart           # 全局服务的 Get.put                         [scaffolded]
│   └── app_theme.dart             # 主题                                       [scaffolded]
├── core/                          # 跨切关注点(基础设施零件,业务无关)
│   ├── network/                   # HTTP client(Dio + 拦截器)                [planned]   (空目录占位)
│   ├── storage/                   # 本地存储封装                              [planned]   (空目录占位)
│   ├── auth/                      # AuthService + token 生命周期              [planned]   (目录尚未创建)
│   ├── env/                       # 环境配置(Env 抽象)                       [planned]   (目录尚未创建)
│   ├── logging/                   # 日志门面                                  [planned]   (目录尚未创建)
│   ├── error/                     # Failure 类型                              [in-use]
│   └── utils/                     # 纯函数工具                                [planned]   (空目录占位)
├── shared/                        # 跨模块共享 UI / 模型
│   ├── route_args/                # 路由参数类(跨模块契约,见下方说明)        [in-use]
│   ├── state/                     # 跨模块响应式状态(Rx<T>)                  [planned]   (目录尚未创建)
│   └── widgets/                   # 跨模块复用 widget(StateViewBuilder 等)   [in-use]
├── l10n/                          # 国际化资源(ARB 文件)                     [in-use]
└── features/                      # 业务模块(每个模块按 Module-First Flat 组织)
```

**注**:`app_binding.dart` / `app_theme.dart` 文件存在并被 `main.dart` 装配,但目前没有 `features/` 模块直接 import 它们,故按照本文 Status 定义(以"是否被 features/ import"为准)归 `scaffolded`。

## Module-First Flat:模块内部结构

每个业务模块(`lib/features/{module}/`)**内部平铺**,按职责命名,不嵌套层目录:

```
features/{module}/
├── {module}_page.dart             # UI:Scaffold + 视图组合
├── {module}_controller.dart       # GetxController:状态(.obs)+ 用户交互
├── {module}_binding.dart          # Get.lazyPut 注入
├── {module}_models.dart           # 数据类 + enum(纯 Dart)
├── {module}_api.dart              # 后端 API 调用(经 core/network)
├── widgets/                       # 模块内私有 widget(可选)
│   └── *.dart
└── (模块特殊文件,按需添加)
```

**路由参数类** `{module}_route_args.dart` **不**放模块内,统一放 [shared/route_args/](../lib/shared/route_args/)。理由:调用方(任意 feature)需要 import 它来构造强类型参数,放模块内会触发铁律 #1(features 互引)。命名仍保持 `{module}_route_args.dart`,只是位置在 `lib/shared/route_args/`。

**简单模块**只需要 `page` + `controller` + `binding` 三件套,其余按需。

**复杂模块**(如 Flame 的 pet)可以加专属文件,但仍然平铺(见 [pixel-foundation.md "Flame 的位置"](pixel-foundation.md#flame-的位置))。

### 命名约定

| 文件名 | 职责 | 类名约定 |
|---|---|---|
| `{module}_page.dart` | Scaffold 与 widget 组合,**只组合不写业务** | `XxxPage` |
| `{module}_controller.dart` | GetxController 子类,**业务状态唯一真理** | `XxxController` |
| `{module}_binding.dart` | Bindings 子类,负责依赖注入 | `XxxBinding` |
| `{module}_models.dart` | 数据类、enum、值对象,**纯 Dart 无框架引用** | 多个类 |
| `{module}_api.dart` | 该模块的后端调用,返回模型类型 | `XxxApi` |
| `shared/route_args/{module}_route_args.dart` | 路由参数类(传 `Get.toNamed` 的 `arguments`,跨模块契约) | `XxxRouteArgs` |
| `widgets/*.dart` | 模块内私有 widget(被多个 page 组合用) | 与文件同名 |

类名与文件名一一对应,小驼峰转大驼峰:`pet_controller.dart` → `class PetController`。

## 4 条铁律

写在最前面,违反就是设计错了:

1. **模块自治**:`features/A/` 内部任何 import 都**不能**跨到 `features/B/`。要跨模块通信,见 [conventions.md §11](conventions.md#11-跨模块通信)。
2. **共享单点**:跨模块用的东西必须放 `core/` 或 `shared/`,**不能**放某个 feature 里再被另一个 feature 引用。
3. **单向依赖**:依赖图严格单向 —— `features/* → core/* + shared/* → 外部包`。`core/`、`shared/` 不能依赖 `features/`。
4. **命名一致**:`{module}_*.dart` 命名约定必须遵守,Agent 看名字就知道职责。

## core/ vs shared/ 边界

容易模糊,记住经验法则:

- **`core/`** 偏**基础设施 / 通用能力**,业务无关。例:HTTP 客户端、本地存储封装、Env 配置、Failure 类型、日志门面、日期格式化工具。**不依赖 widget 树的工具一般归 core**(error/、utils/、env/、auth/ 完全纯 Dart;network/、storage/、logging/ 可以依赖第三方包但不依赖 widgets)。
- **`shared/`** 偏**跨模块的 UI 或业务状态**。例:`StateViewBuilder` widget、跨模块共享的 `Rx<UserSettings>`、多模块都用的"主按钮"。**带 widget 或带响应式业务状态的归 shared**。

模糊时优先放 `shared/`,后悔了再迁。**单一模块独占的东西不放这里**,放进 `features/{module}/` 内部。

## 像素风通用底座

Flame 集成、Controller↔Game 同步契约、sprite 资源约定,以及像素风专属的 4 个底座主题(渲染器选择 / 像素纯度自检 / 输入抽象 / 资源懒加载),全部见 [pixel-foundation.md](pixel-foundation.md)。本架构文档只保留与"像素"无关的通用 Flutter+GetX 模块化约定 —— 换一个非像素 Flutter 项目时,本文仍然适用,而 pixel-foundation.md 不需要带走。

## 与后端的契约

cute_pixel 接入 spec_flow 后端时的统一约定:

- **响应格式** `{code, message, data, traceId}`,`code == 0` 为成功
- **鉴权**:`Authorization: Bearer <token>`(token 生命周期见 [conventions.md §3](conventions.md#3-认证与-token-生命周期))
- **HTTP 错误统一映射**(由 `core/network/` 拦截器处理,业务层不做 HTTP 异常处理):
  - **Status:** `core/network/` 整体 `planned`(目录存在但为空,所有拦截器尚未实现)
  - 401 → `AuthService.clear()` + 跳登录
  - 403 → 抛 `ForbiddenFailure`
  - 422/400 → 抛 `ValidationFailure`
  - 404 → 抛 `NotFoundFailure`
  - 500 → 抛 `ServerFailure`
  - 超时/断网 → 抛 `NetworkFailure`
- **错误的传递与展示**见 [conventions.md §1](conventions.md#1-错误处理流水线)

后端接入前,`{module}_api.dart` 返回 mock 数据,接入后只改这一个文件。

## 不在本架构范围内 (Out of Scope)

明确**不在本架构里规范**的事项,这些到上线前再单独规划:

- CI/CD 流水线(GitHub Actions:lint + test + build)
- 崩溃上报(Sentry / Firebase Crashlytics)
- 性能监控(Flutter Timeline、Flame FPS overlay 仅 dev)
- 证书钉扎
- 响应式断点(平板 / 折叠屏)
- 远程资源热更新(sprite/manifest 远程下载与版本管理)

