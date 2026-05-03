# Conventions

本文档定义 cute_pixel 的生产级代码标准。架构(模块边界、目录结构、4 条铁律)见 [architecture.md](architecture.md);本文规定**怎么写**。

> **Status 标记**:下文每个 `**位置**:` 行都带一个 `[planned | scaffolded | in-use]` 标签,语义见 [architecture.md 状态标记说明](architecture.md#状态标记说明)。生成 import 之前**先核对 Status**,`planned` 的文件不存在,直接 import 会编译失败。

## 目录

P0(生产前必备)
- [1. 错误处理流水线](#1-错误处理流水线)
- [2. 环境配置(flavor)](#2-环境配置flavor)
- [3. 认证与 Token 生命周期](#3-认证与-token-生命周期)
- [4. 国际化(i18n)](#4-国际化i18n)
- [5. 日志与可观测](#5-日志与可观测)
- [6. Lint 与代码风格](#6-lint-与代码风格)
- [7. 测试纪律](#7-测试纪律)

P1(应该有)
- [8. 路由参数类型化](#8-路由参数类型化)
- [9. 加载/空/错误状态 UI 模式](#9-加载空错误状态-ui-模式)
- [10. JSON 序列化](#10-json-序列化)
- [11. 跨模块通信](#11-跨模块通信)
- [12. 时间与存档](#12-时间与存档)

附录
- [A. 依赖清单](#a-依赖清单)

---

## 1. 错误处理流水线

**标准**:所有失败用 `core/error/failures.dart` 的 `Failure` 子类型表达;`api → controller → page` 的传递路径固定;UI 兜底统一在全局,业务页只关心展示。

**位置**:`lib/core/error/failures.dart`  **Status:** `in-use`

```dart
sealed class Failure {
  final String message;
  final String? traceId;
  const Failure(this.message, {this.traceId});
}

class NetworkFailure  extends Failure { const NetworkFailure(super.m, {super.traceId}); }
class AuthFailure     extends Failure { const AuthFailure(super.m, {super.traceId}); }      // 401
class ForbiddenFailure extends Failure { const ForbiddenFailure(super.m, {super.traceId}); } // 403
class NotFoundFailure extends Failure { const NotFoundFailure(super.m, {super.traceId}); }  // 404
class ValidationFailure extends Failure {                                                    // 400/422
  final Map<String, String> fieldErrors;
  const ValidationFailure(super.m, this.fieldErrors, {super.traceId});
}
class ServerFailure  extends Failure { const ServerFailure(super.m, {super.traceId}); }     // 500
class UnknownFailure extends Failure { const UnknownFailure(super.m, {super.traceId}); }
```

**传递路径**(api 抛 → controller catch → state.obs → page Obx):

```dart
// {module}_api.dart
Future<List<Pet>> fetchPets() async {
  try {
    final res = await _dio.get('/pets');
    return (res.data['data'] as List).map(Pet.fromJson).toList();
  } on DioException catch (e) {
    throw _mapDioError(e);  // 抛 Failure 子类(由 core/network 提供 mapper)
  }
}

// {module}_controller.dart
final state = Rx<ViewState<List<Pet>>>(Loading());
Future<void> load() async {
  state.value = Loading();
  try {
    state.value = Data(await _api.fetchPets());
  } on Failure catch (f) {
    state.value = ErrorState(f);
    log.e(f.message, error: f, traceId: f.traceId);
  }
}
```

**全局兜底**:

- **401** 由 `core/network/` 拦截器统一处理,不在业务层 catch:`AuthService.clear()` + 跳登录(见 §3)
- **未捕获 Failure** 由 `app/app_binding.dart` 注册的全局错误处理器兜底,显示 SnackBar 含 `traceId`

**禁止**:
- 抛裸 `Exception` / `String` / `dynamic`
- 在业务层 catch 401 自己处理(必须让拦截器统一处理)
- 错误日志不带 `traceId`

---

## 2. 环境配置(flavor)

**标准**:所有 base URL、开关、第三方 SDK key 通过 `--dart-define` 注入,在 `core/env/env.dart` 集中读取;**禁止**在业务代码硬写 URL/key。

**位置**:`lib/core/env/env.dart`  **Status:** `planned`(文件与目录均未创建)

```dart
abstract class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev.example.com',
  );
  static const String name = String.fromEnvironment('ENV', defaultValue: 'dev');

  static bool get isDev => name == 'dev';
  static bool get isStaging => name == 'staging';
  static bool get isProd => name == 'prod';
}
```

**调用**(以构建 prod 为例):

```bash
flutter build apk --dart-define=API_BASE_URL=https://api.example.com --dart-define=ENV=prod
```

**推荐用法**:把环境组合写进 `env/{env}.json`,通过 `--dart-define-from-file=env/prod.json` 一行带过,Makefile 包好(`make run-dev` / `make run-prod`)。

**禁止**:
- 业务代码 `import` 任何带 URL 的常量文件,统一走 `Env.apiBaseUrl`
- `flutter run` 跑生产环境(默认 dev,要切环境必须显式 `--dart-define=ENV=...`)

---

## 3. 认证与 Token 生命周期

**标准**:Token 必须存 `flutter_secure_storage`(底层 iOS Keychain / Android EncryptedSharedPreferences);全局 `AuthService` 是 token 唯一真理;401 在 `core/network/` 拦截器统一清理 + 跳登录,业务层不处理 401。

**位置**:`lib/core/auth/auth_service.dart`,在 `app/app_binding.dart` 中 `Get.put(AuthService(), permanent: true)`  **Status:** `lib/core/auth/auth_service.dart` `planned`(目录与文件均未创建);`app/app_binding.dart` `scaffolded`(文件存在但 `AuthService` 注册尚未加入)

```dart
class AuthService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final tokenRx = Rxn<String>();

  static const _key = 'auth_token';

  Future<void> init() async {
    tokenRx.value = await _storage.read(key: _key);
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: _key, value: token);
    tokenRx.value = token;
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
    tokenRx.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => tokenRx.value != null;
}
```

**network 拦截器**(`lib/core/network/auth_interceptor.dart`)  **Status:** `planned`(`core/network/` 目录存在但为空):

```dart
onRequest: (options, handler) {
  final token = Get.find<AuthService>().tokenRx.value;
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  handler.next(options);
}

onError: (e, handler) {
  if (e.response?.statusCode == 401) {
    Get.find<AuthService>().clear();
  }
  handler.next(e);
}
```

**禁止**:
- Token 存 `shared_preferences`、内存单例、文件
- 业务 controller 自己读/写 token(必须经 `AuthService`)
- 业务 controller 自己 catch 401

---

## 4. 国际化(i18n)

**标准**:**中文 + 英文**双语,两份 ARB 同步维护;所有用户可见字符串走 `flutter_localizations` 的 `gen-l10n`;ARB 文件按模块前缀键命名;**禁止**硬编码用户可见字符串;**禁止**只在一种语言里加 key(代码 review 阻断)。

**位置**:`lib/l10n/app_zh.arb` + `lib/l10n/app_en.arb`(两份地位平等,新增 key 必须**同时**在两边写完)  **Status:** `app_zh.arb` `in-use`、`app_en.arb` `in-use`(`main.dart` 已配 `AppLocalizations`,`features/home`、`features/pet` 已使用)

**键命名**:`{module}{Concept}` 小驼峰,例 `petActionEat` / `homeGreeting` / `commonRetry`。跨模块复用的字符串放 `common*` 前缀。

```arb
// app_zh.arb
{
  "@@locale": "zh",
  "homeGreeting": "你好,{petName}",
  "@homeGreeting": { "placeholders": { "petName": { "type": "String" } } },
  "petActionEat": "吃饭",
  "petActionSleep": "睡觉",
  "commonRetry": "重试"
}

// app_en.arb(每个 key 必须有对应翻译,占位符同步)
{
  "@@locale": "en",
  "homeGreeting": "Hi, {petName}",
  "petActionEat": "Eat",
  "petActionSleep": "Sleep",
  "commonRetry": "Retry"
}
```

**pubspec.yaml**:

```yaml
flutter:
  generate: true
```

**l10n.yaml**(项目根):

```yaml
arb-dir: lib/l10n
template-arb-file: app_zh.arb
output-localization-file: app_localizations.dart
```

**MaterialApp 配置**(在 `main.dart` 的 `GetMaterialApp`):

```dart
GetMaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: Get.deviceLocale,         // 跟随设备
  fallbackLocale: const Locale('en'),
  // ...
)
```

**调用**:

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.homeGreeting('小柴'));
```

**禁止**:
- 硬编码用户可见字符串(包括 SnackBar、按钮、错误提示)
- 字符串拼接拼出最终展示文本(用 ARB 的 `{placeholder}`)
- 单语提交:zh 加了 key 不在 en 加(或反过来)
- log 信息走 ARB(log 永远英文/中文皆可,但不进 ARB)

---

## 5. 日志与可观测

**标准**:用 `logger` 包统一门面;级别明确;后端返回的 `traceId` 必须打到日志;dev 环境彩色控台,prod 环境精简输出(远端上报留接口)。

**位置**:`lib/core/logging/log.dart`(单顶层 `log` 变量,免去每文件初始化)  **Status:** `planned`(目录与文件均未创建;依赖 `Env`,需先建 `core/env/`)

```dart
import 'package:logger/logger.dart' as l;
import '../env/env.dart';

final log = l.Logger(
  level: Env.isProd ? l.Level.info : l.Level.debug,
  printer: l.PrettyPrinter(
    methodCount: 0,
    colors: !Env.isProd,
    printEmojis: !Env.isProd,
    dateTimeFormat: l.DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
```

**级别**:

| 级别 | 用途 | dev | prod |
|---|---|---|---|
| `log.d()` debug | 调试细节(变量值、流程节点) | ✓ | ✗ |
| `log.i()` info | 里程碑(应用启动、登录、路由切换) | ✓ | ✓ |
| `log.w()` warn | 可恢复问题(重试中、降级路径) | ✓ | ✓ |
| `log.e()` error | 失败(Failure、异常) | ✓ | ✓ |

**traceId 透传**:

```dart
} on Failure catch (f) {
  log.e('fetchPets failed: ${f.message}', error: f);
  // 实际打印中包含 f.traceId,因为 Failure.toString() 会带
}
```

**禁止**:
- `print()` / `debugPrint()`(lint 阻止,见 §6)
- 日志带敏感信息(token、密码、PII)
- 错误日志不带 `traceId`

后端接入后,prod 远端日志通道作为单独工程,在本文档外定义(见 architecture.md Out of Scope)。

---

## 6. Lint 与代码风格

**标准**:`analysis_options.yaml` 在 `flutter_lints` 基础上加严;`dart format` 必须过(行宽默认 80);CI/pre-commit 强制(本期暂未引入 CI,本地约束)。

**位置**:`analysis_options.yaml`(项目根)  **Status:** `in-use`(项目根已有此文件)

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    avoid_print: error
    todo: ignore  # TODO 允许在代码里
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/l10n/**"  # 自动生成

linter:
  rules:
    - always_declare_return_types
    - always_use_package_imports
    - avoid_dynamic_calls
    - avoid_print
    - directives_ordering
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_locals
    - require_trailing_commas
    - sort_pub_dependencies
    - unawaited_futures
    - use_super_parameters
```

**格式化**:`dart format .` 在提交前必跑。Makefile 提供 `make fmt` / `make fmt-check`。

**导入顺序**(`directives_ordering` 强制):
1. `dart:` 内置
2. `package:flutter` 与 `package:` 第三方
3. 项目内 `package:cute_pixel/...`(用 `always_use_package_imports`,禁止相对导入)

**禁止**:
- `import '../../../foo.dart'`(用 `package:cute_pixel/foo.dart`)
- `print()` / `debugPrint()`(用 `log.d/i/w/e`)
- 提交未格式化的代码

---

## 7. 测试纪律

**标准**:三层金字塔,每个新模块必带测试;mock 用 `mocktail`(零代码生成);**覆盖率按层定指标**(下表)。

**目录**:`test/` 镜像 `lib/` 结构

```
test/
├── core/
│   └── error/failures_test.dart
└── features/
    └── pet/
        ├── pet_models_test.dart
        ├── pet_api_test.dart
        └── pet_controller_test.dart
```

**三层 + 覆盖率指标**:

| 层 | 对象 | 怎么测 | 覆盖率指标 |
|---|---|---|---|
| 1. 纯单测(domain) | `*_models.dart`, `core/error/`, `core/utils/`, 纯 Dart 工具 | 直接调,断言返回值 | **≥ 90%** |
| 2. 纯单测(api) | `*_api.dart` | mock Dio,测请求构造与响应解析 | **≥ 80%** |
| 3. Controller 测 | `*_controller.dart` | mock api → 调方法 → 断言 `.obs` 状态 | **≥ 70%** |
| 4. Widget 测 | `*_page.dart` 关键交互 | `pumpWidget` + `find` + `tap` | **≥ 50%** |

页面层指标低,因为 page 主要靠人工/真机测;但**关键路径**(登录、付款、删除等不可逆操作)的 widget 测必写。

**Controller 测样例**:

```dart
class _MockApi extends Mock implements PetApi {}

void main() {
  late PetController controller;
  late _MockApi api;

  setUp(() {
    api = _MockApi();
    controller = PetController(api);
  });

  test('load() emits Loading then Data on success', () async {
    when(() => api.fetchPets()).thenAnswer((_) async => [Pet(...)]);
    final states = <ViewState<List<Pet>>>[];
    controller.state.listen(states.add);

    await controller.load();

    expect(states.first, isA<Loading>());
    expect(states.last, isA<Data>());
  });
}
```

**Makefile**:`make test`(默认)+ `make test-coverage`(带 `--coverage`,产出 `coverage/lcov.info`)

**禁止**:
- 新模块代码无测试合入
- 用 mockito + build_runner(mocktail 已够,避免代码生成)
- Widget 测里调真 Dio / 真 storage(必须 mock)

---

## 8. 路由参数类型化

**标准**:每条带参数的路由定义 `{Module}RouteArgs` 类;`Get.toNamed` 的 `arguments` 强类型;page 第一行从 `Get.arguments` 强制转型。

**位置**:`shared/route_args/{module}_route_args.dart`(跨模块契约,**不**放在模块内,见 [architecture.md "Module-First Flat"](architecture.md#module-first-flat模块内部结构) 的路由参数说明)  **Status:** 实例 `lib/shared/route_args/pet_route_args.dart` `in-use`

```dart
class PetRouteArgs {
  final String petId;
  const PetRouteArgs({required this.petId});
}
```

**调用**:

```dart
// 任何地方
Get.toNamed(AppRoutes.pet, arguments: const PetRouteArgs(petId: 'abc'));

// pet_page.dart 第一行
@override
Widget build(BuildContext context) {
  final args = Get.arguments as PetRouteArgs;
  // ...
}
```

**禁止**:
- `Get.arguments['id']`(用 `Map<String, dynamic>` 传参)
- 多个参数挤在一个 String

---

## 9. 加载/空/错误状态 UI 模式

**标准**:任何"列表/详情"页 controller 暴露 `Rx<ViewState<T>>`;page 用 `StateViewBuilder` 包裹消费。统一展示口径,不让每个 page 自己写 if/else。

**`ViewState<T>`** 是 freezed sealed union,定义见 [§10 数据建模](#10-数据建模freezed--json_serializable)。

**位置**:`lib/shared/widgets/state_view_builder.dart`  **Status:** `in-use`(被 `features/pet/pet_page.dart` import)

```dart
class StateViewBuilder<T> extends StatelessWidget {
  final Rx<ViewState<T>> state;
  final Widget Function(T) onData;
  final Widget? loading;
  final Widget? empty;
  final Widget Function(Failure)? onError;
  final VoidCallback? onRetry;

  // build:Obx + Dart 3 模式匹配 switch on state.value
}
```

**用法**:

```dart
StateViewBuilder<List<Pet>>(
  state: controller.state,
  onData: (pets) => ListView(...),
  onRetry: controller.load,
)
```

**禁止**:
- page 里用 `Obx` + `if (loading) ... else if (error) ...`(用 `StateViewBuilder`)
- 每个模块自己写 `LoadingView` / `ErrorView`(全局一份在 `shared/widgets/`)

---

## 10. 数据建模:freezed + json_serializable

**标准**:所有**数据模型**和**值等价 Union**(如 `ViewState<T>`)用 `freezed` + `json_serializable`;放在 `{module}_models.dart`(必要时拆 `{module}_models.freezed.dart` + `.g.dart` 由代码生成器产出,**不手写不提交手改**)。

**例外**:`Failure` 这类**靠类型分支**的错误 sealed,不需要 `copyWith` / `toJson`,用 plain Dart sealed(见 §1)即可。

**为什么 freezed**:免手写 `==` / `hashCode` / `toString` / `copyWith`;不可变默认;sealed union 模式匹配编译期穷尽检查;`fromJson`/`toJson` 由 `json_serializable` 一并出。代码量比手写少 60%,可读性高,Agent/人都不容易写错。

**freezed 3.x 关键差异**(踩坑提醒):
- 数据类(`Pet`)必须用 `abstract class Pet with _$Pet`(非 abstract 会报 `non_abstract_class_inherits_abstract_member`)
- Sealed Union 必须显式 `sealed class Foo with _$Foo`
- 弃用 `.when` / `.map`,改用 Dart 3 `switch` 表达式(见下方示例)

### 数据模型模板

```dart
// pet_models.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_models.freezed.dart';
part 'pet_models.g.dart';

enum PetSpecies { shibainu, corgi }
enum PetAction { idle, eat, drink, walk, run, sleep }
enum PetDirection { north, east, south, west }

@freezed
abstract class Pet with _$Pet {
  const factory Pet({
    required String id,
    required String name,
    required PetSpecies species,
    required double x,
    required double y,
    @Default(PetAction.idle) PetAction action,
    @Default(PetDirection.south) PetDirection facing,
  }) = _Pet;

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
}
```

生成完成后,`Pet` 自动获得:`copyWith({...})`、值相等 `==`、`hashCode`、`toString`、`fromJson` / `toJson`。

### Sealed Union 模板(`ViewState<T>` 等)

**位置**:`lib/shared/state/view_state.dart`(+ 生成产物 `view_state.freezed.dart`)  **Status:** `in-use`(被 `features/pet/pet_controller.dart`、`features/pet/pet_game.dart` import)

```dart
// shared/state/view_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cute_pixel/core/error/failures.dart';

part 'view_state.freezed.dart';

@freezed
sealed class ViewState<T> with _$ViewState<T> {
  const factory ViewState.loading() = Loading<T>;
  const factory ViewState.empty() = Empty<T>;
  const factory ViewState.error(Failure failure) = ErrorState<T>;
  const factory ViewState.data(T data) = Data<T>;
}
```

消费侧用 Dart 3 模式匹配:

```dart
final widget = switch (state.value) {
  Loading()       => const CircularProgressIndicator(),
  Empty()         => const EmptyView(),
  ErrorState(:final failure) => ErrorView(failure: failure),
  Data(:final data)          => onData(data),
};
```

### 代码生成

依赖 `build_runner` 一次性产出 `*.freezed.dart` 与 `*.g.dart`:

```bash
make codegen          # 一次性生成
make codegen-watch    # 开发期持续监听
```

(Makefile 在引入 freezed 时一并加上这两个 target。)

### 提交纪律

- `.freezed.dart` 与 `.g.dart` **必须提交**(避免 clone 后还要先跑生成才能 build)
- 生成产物已被 `analysis_options.yaml` exclude(见 §6),lint 不会扫
- 改了 `@freezed` 类,提交前必须重跑 `make codegen` 让产物同步

### 禁止

- 数据模型用手写 `fromJson` / `toJson`(用 freezed)
- 数据模型自己实现 `==` / `hashCode` / `copyWith`(用 freezed)
- 手改 `*.freezed.dart` / `*.g.dart`(每次重生成都会被覆盖)
- enum 用 `int` 编码而非 `String`(用 `EnumName.byName` / `.name`,后端契约对齐)
- controller 里直接操作 `Map<String, dynamic>`(必须经 model)

---

## 11. 跨模块通信

**标准**:`features/A/` 内部禁止 `import 'features/B/...'`(架构铁律 1)。需要跨模块时按下面 3 种方式选:

| 方式 | 用法 | 适合 |
|---|---|---|
| **A. 全局服务** | `app/app_binding.dart` 中 `Get.put<XxxService>(...)`,业务方 `Get.find<XxxService>()` | 用户信息、配置、Token、设备能力等长生命周期单例 |
| **B. 共享响应式状态** | `shared/state/xxx_rx.dart` 暴露 `Rx<T>`,各方订阅同一引用 | 主题、当前语言、跨模块联动的标志位 |
| **C. 事件总线** | `Get.bus.fire(XxxEvent)` / `Get.bus.on<XxxEvent>().listen(...)` | 松耦合通知(完成动作、登出、外部推送) |

**禁止**:
- A controller `Get.find<BController>()` —— 强耦合 controller,坏味道
- 在 `core/` 或 `shared/` 中 import `features/...`(违反铁律 3)
- 重复 import 跨模块的私有 widget(应迁到 `shared/widgets/`)

---

## 12. 时间与存档

像素 app 通用底座的两条收口规则,细节见各自的 ADR/README。

**时间驱动**:用 `lib/core/time/game_clock.dart` 的 `GameClock`(GetxService),按需订阅 `tick1s` / `tick1m` / `tick10m`;离线/重启 catch-up 走 `GameClock.catchUp(lastSavedAt)`。**禁止** controller 内 `Timer.periodic`。理由与替代方案见 [ADR-007](decisions/ADR-007-game-clock-as-singleton.md)。

**游戏存档**:用 `lib/core/storage/save_store/` 的 `SaveStore<T>` + `SaveEnvelope<T>{version, savedAt, payload}`,schema 升级走 `SaveMigrator<T>` 链。**禁止** 直接 `prefs.setString` 存 JSON / 不带版本号持久化。用法、DI 注册、迁移示例见 [save_store/README.md](../lib/core/storage/save_store/README.md);策略见 [ADR-008](decisions/ADR-008-save-versioning-with-migrator.md)。

**位置**:`lib/core/time/game_clock.dart` **Status:** `scaffolded`;`lib/core/storage/save_store/` **Status:** `scaffolded`(`SaveStoreImplPrefs` 已基于 `shared_preferences` 实装,可直接 DI 注入,**Status:** `in-use`)。

---

## A. 依赖清单

下面是 conventions 引入的包,**第一次实际用到时**才装。装的时候顺手更新本表的"已装"列。

### 立即引入(第一个数据模型出现前必须装)

| 包 | 类型 | 版本 | 用途 | 已装 |
|---|---|---|---|---|
| `freezed_annotation` | dependencies | latest | freezed 注解 | ✓ |
| `json_annotation` | dependencies | latest | json_serializable 注解 | ✓ |
| `freezed` | dev_dependencies | latest | freezed 代码生成器 | ✓ |
| `json_serializable` | dev_dependencies | latest | JSON 代码生成器 | ✓ |
| `build_runner` | dev_dependencies | latest | 触发代码生成 | ✓ |

### 用到时引入

| 包 | 类型 | 版本 | 用途 | 引入时机 | 已装 |
|---|---|---|---|---|---|
| `dio` | dependencies | latest | HTTP client | 实现 `core/network/` 时 | ✓ |
| `flutter_secure_storage` | dependencies | latest | Token 安全存储 | 实现 `core/auth/` 时 | ✓ |
| `shared_preferences` | dependencies | latest | 游戏存档落盘(`SaveStore`) | 启用 `SaveStoreImplPrefs` 时 | ✓ |
| `logger` | dependencies | latest | 日志门面 | 实现 `core/logging/` 时 | ✓ |
| `flutter_localizations` | SDK | — | i18n 框架 | 第一个 ARB 文件时 | ✓ |
| `intl` | dependencies | latest | i18n 配套 | 同上 | ✓ |
| `mocktail` | dev_dependencies | latest | 测试 mock | 写第一个 controller 测时 | ✓ |

`logger` 包名查重时注意有同名第三方包,使用 `pub.dev/packages/logger`(由 `leisim` 维护)。

