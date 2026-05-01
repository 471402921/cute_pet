# Architecture

## 设计目标

cute_pet 是 Flutter + GetX + Flame 应用。架构上的首要目标是**减少 AI 与人在跨模块工作时的上下文负担**:做某个模块的事,只需要看一个文件夹;读架构文档,只需要看几条铁律。

DDD 的分层精神(模块自治、单向依赖、共享集中)被保留,**不**照搬后端 4 层结构 —— 前端业务大头在后端,前端主要是 UI + 状态 + API 调用,4 层会产生大量空壳层,反而增加上下文负担。

具体的代码标准(错误处理、i18n、测试、日志、lint 等)见 [conventions.md](conventions.md)。

## 顶层目录

```
lib/
├── main.dart                      # 入口
├── app/                           # App 级配置(全局,不属于任何业务模块)
│   ├── app_routes.dart            # 路由常量
│   ├── app_pages.dart             # GetPage 列表
│   ├── app_binding.dart           # 全局服务的 Get.put
│   └── app_theme.dart             # 主题
├── core/                          # 跨切关注点(基础设施零件,业务无关)
│   ├── network/                   # HTTP client(Dio + 拦截器)
│   ├── storage/                   # 本地存储封装
│   ├── auth/                      # AuthService + token 生命周期
│   ├── env/                       # 环境配置(Env 抽象)
│   ├── logging/                   # 日志门面
│   ├── error/                     # Failure 类型
│   └── utils/                     # 纯函数工具
├── shared/                        # 跨模块共享 UI / 模型
│   ├── state/                     # 跨模块响应式状态(Rx<T>)
│   └── widgets/                   # 跨模块复用 widget(StateViewBuilder 等)
├── l10n/                          # 国际化资源(ARB 文件)
└── features/                      # 业务模块(每个模块按 Module-First Flat 组织)
```

## Module-First Flat:模块内部结构

每个业务模块(`lib/features/{module}/`)**内部平铺**,按职责命名,不嵌套层目录:

```
features/{module}/
├── {module}_page.dart             # UI:Scaffold + 视图组合
├── {module}_controller.dart       # GetxController:状态(.obs)+ 用户交互
├── {module}_binding.dart          # Get.lazyPut 注入
├── {module}_models.dart           # 数据类 + enum(纯 Dart)
├── {module}_api.dart              # 后端 API 调用(经 core/network)
├── {module}_route_args.dart       # 路由参数类(只在带参数路由时存在)
├── widgets/                       # 模块内私有 widget(可选)
│   └── *.dart
└── (模块特殊文件,按需添加)
```

**简单模块**只需要 `page` + `controller` + `binding` 三件套,其余按需。

**复杂模块**(如 Flame 的 pet)可以加专属文件,但仍然平铺(见 [Flame 的位置](#flame-的位置))。

### 命名约定

| 文件名 | 职责 | 类名约定 |
|---|---|---|
| `{module}_page.dart` | Scaffold 与 widget 组合,**只组合不写业务** | `XxxPage` |
| `{module}_controller.dart` | GetxController 子类,**业务状态唯一真理** | `XxxController` |
| `{module}_binding.dart` | Bindings 子类,负责依赖注入 | `XxxBinding` |
| `{module}_models.dart` | 数据类、enum、值对象,**纯 Dart 无框架引用** | 多个类 |
| `{module}_api.dart` | 该模块的后端调用,返回模型类型 | `XxxApi` |
| `{module}_route_args.dart` | 路由参数类(传 `Get.toNamed` 的 `arguments`) | `XxxRouteArgs` |
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

## Flame 的位置

Flame 是 `features/pet/` 模块的**实现细节**。不出现在 `core/`、`shared/`、其他 feature。Pet 模块允许的扩展结构:

```
features/pet/
├── pet_page.dart                  # Scaffold + GameWidget + Flutter Overlay 控制面板
├── pet_controller.dart            # 业务状态唯一真理(pets 列表、当前选中、动作)
├── pet_binding.dart
├── pet_models.dart                # Pet + PetAction + PetDirection + PetSpecies(纯 Dart)
├── pet_api.dart
├── pet_route_args.dart            # (如果路由带参)
├── pet_game.dart                  # FlameGame:监听 Controller → 同步 PetComponent
├── pet_manifest.dart              # manifest.json 模型 + 解析(真接 sprite 时加)
├── pet_animation_loader.dart      # 加载 manifest + 构建 SpriteAnimation 字典(真接 sprite 时加)
└── components/
    └── pet_component.dart         # PositionComponent,applyState(action, direction)
```

**关键**:Flame Component **只负责渲染**,不持有业务状态。业务状态(饥饿度、健康、当前动作等)在 `pet_controller.dart`。

## Controller ↔ Flame Game 同步契约

为避免业务状态 Controller 和 Component 双 source of truth:

```
PetController (.obs<List<Pet>>)
        │
        │  ever() 监听变化
        ▼
   PetGame.onPetsChanged(newList)
        │
        │  与当前 PetComponent 列表做 diff:
        │  - 新增 Pet      → world.add(PetComponent(pet))
        │  - 删除 Pet      → component.removeFromParent()
        │  - 现有 Pet 状态变 → component.applyState(action, direction)
        ▼
   PetComponent.applyState(action, direction)
        │
        │  只做一件事:
        ▼
   切换当前显示的 SpriteAnimation(或占位渲染)
```

**Component 不订阅 Controller**,只暴露 `applyState()` 让 Game 推。这样 Component 可以脱离 GetX 在纯 Flame 测试里跑。

## Sprite 资源约定

每只宠物一个文件夹,内含 manifest 与 PNG:

```
assets/pets/{species}/
├── manifest.json
├── idle_north.png       (directional: true 时,4 张 north/east/south/west)
├── idle_east.png
├── idle_south.png
├── idle_west.png
├── eat.png              (directional: false 时,1 张所有方向共用)
├── sleep.png
└── ...
```

### manifest.json schema

```json
{
  "species": "shibainu",
  "displayName": "柴犬",
  "tileSize": { "w": 64, "h": 64 },
  "actions": {
    "idle":  { "frameCount": 4, "stepTime": 0.20, "directional": true  },
    "walk":  { "frameCount": 6, "stepTime": 0.12, "directional": true  },
    "run":   { "frameCount": 6, "stepTime": 0.08, "directional": true  },
    "eat":   { "frameCount": 6, "stepTime": 0.15, "directional": false },
    "drink": { "frameCount": 6, "stepTime": 0.15, "directional": false },
    "sleep": { "frameCount": 4, "stepTime": 0.40, "directional": false }
  }
}
```

**字段说明**
- `tileSize`:每帧像素尺寸(SpriteAnimation 切帧依据)
- `frameCount`:该动作的帧数
- `stepTime`:每帧持续秒数
- `directional`:`true` 加载 4 个方向的 PNG;`false` 加载单张所有方向共用

**扩展原则**
- **加新宠物** = 新建 `assets/pets/{new_species}/` + 一份 manifest + PNG;**零代码改动**(只需 `PetSpecies` enum 加一项)
- **加新动作** = manifest 里加一行 + 出图;**零代码改动**(只需 `PetAction` enum 加一项)
- **加 8 方向** = 改 `PetDirection` enum + 改加载逻辑;少量改动

## 与后端的契约

cute_pet 接入 spec_flow 后端时的统一约定:

- **响应格式** `{code, message, data, traceId}`,`code == 0` 为成功
- **鉴权**:`Authorization: Bearer <token>`(token 生命周期见 [conventions.md §3](conventions.md#3-认证与-token-生命周期))
- **HTTP 错误统一映射**(由 `core/network/` 拦截器处理,业务层不做 HTTP 异常处理):
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

