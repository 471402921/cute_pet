# Module File 指引

> **本文档定位**:主流程已改为 `cp -r lib/features/_template/ + sed` 替换(见 [SKILL.md](SKILL.md) 的"为什么 cp + sed")。本文件保留作为**每个模板文件的设计意图说明**,不再用于"按文字模板手写"。读模板代码时如果不理解某段为什么这么写,翻这里。

按需读:理解 `_template/` 里某个文件的设计原因时打开。本文件给**目的、关键陷阱、示意片段**——不给完整可粘贴模板,真模板在 [lib/features/_template/](../../../../lib/features/_template/)。

## 通用纪律

- 所有 import 用 `package:cute_pixel/...`,不用相对路径
- 用户可见字符串走 `AppLocalizations.of(context)!.{key}`,**不硬编码**
- 无注释最好;有 `// WHY: ...` 注释更好(架构反 default 选择必须留迹)

---

## `{module}_models.dart`

**目的**:模块的纯 Dart 数据载体,值等价、不可变、可往返 JSON。

**关键陷阱**:
- freezed 3.x 数据类**必须** `abstract class`,否则报 `non_abstract_class_inherits_abstract_member`
- enum 用字符串编码(`.byName` / `.name`),跟后端契约对齐
- 不要 `import 'package:flutter/...'` 或 `package:get/...`(domain 性质,纯 Dart)

**示意结构**:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{module}_models.freezed.dart';
part '{module}_models.g.dart';

enum SomeStatus { active, inactive }

@freezed
abstract class SomeItem with _$SomeItem {
  const factory SomeItem({
    required String id,
    @Default(SomeStatus.active) SomeStatus status,
    // 业务字段...
  }) = _SomeItem;

  factory SomeItem.fromJson(Map<String, dynamic> json) =>
      _$SomeItemFromJson(json);
}
```

---

## `{module}_api.dart`

**目的**:模块与后端通信的唯一入口,屏蔽 Dio / HTTP 细节,返回业务模型。

**MVP 阶段**:返回 mock 数据,加 `Future.delayed` 模拟网络延迟。

**接后端时**:catch `DioException` → 抛 `Failure` 子类(见 conventions §1)。**不让** `DioException` 漏到业务层。

**示意结构**(mock 版):

```dart
import 'package:cute_pixel/features/{module}/{module}_models.dart';

class SomeApi {
  Future<List<SomeItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [/* 1-2 条 mock */];
  }
}
```

---

## `{module}_controller.dart`

**目的**:业务状态唯一真理 + 用户交互入口。**不**直接调 widget,**不**关心 UI。

**列表型**用 `Rx<ViewState<List<X>>>`;**单实体型**用 `Rxn<X>` 或 `Rx<ViewState<X>>`。

**关键陷阱**:
- 状态更新必须**新建对象**(`copyWith` + 重发 `ViewState.data(newList)`),不要 mutate `.obs<List>` 内部
- `unawaited(load())` 在 `onInit` 调用,要 `import 'dart:async'`
- 局部更新(改一条记录的某字段)走"取列表 → 替换匹配项 → 重发整个 list"模式

**示意结构**:

```dart
class SomeController extends GetxController {
  SomeController(this._api);
  final SomeApi _api;

  final state = Rx<ViewState<List<SomeItem>>>(const ViewState.loading());

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const ViewState.loading();
    try {
      final items = await _api.fetchItems();
      state.value = items.isEmpty
          ? const ViewState.empty()
          : ViewState.data(items);
    } on Failure catch (f) {
      state.value = ViewState.error(f);
    }
  }

  // 局部更新示意
  void updateOne(String id, SomeItem Function(SomeItem) modify) {
    final current = state.value;
    if (current is! Data<List<SomeItem>>) return;
    final updated = [
      for (final i in current.data) i.id == id ? modify(i) : i,
    ];
    state.value = ViewState.data(updated);
  }
}
```

---

## `{module}_binding.dart`

**目的**:GetX 依赖注入。

**示意**(几乎所有模块都长这样):

```dart
class SomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(SomeApi.new);
    Get.lazyPut(() => SomeController(Get.find()));
  }
}
```

需要全局共享的服务(如 AuthService)放 [lib/app/app_binding.dart](../../../../lib/app/app_binding.dart),不是 module binding。

---

## `shared/route_args/{module}_route_args.dart`(带参数路由时)

**位置**:`lib/shared/route_args/{module}_route_args.dart`(**不**在 `features/{module}/` 内,跨模块契约,避免 features 互引,见 [architecture.md](../../../../doc/architecture.md) "Module-First Flat" 一节)

**目的**:消灭 `Get.arguments['id']` 弱类型,让路由参数有编译期检查。

**示意**:

```dart
class SomeRouteArgs {
  const SomeRouteArgs({required this.id});
  final String id;
}
```

page 第一行强转:`final args = Get.arguments as SomeRouteArgs;`

---

## `{module}_page.dart`

**目的**:Scaffold + widget 组合。**不写业务**,业务全在 controller。

**列表/详情型**:用 `StateViewBuilder<T>` 包,自动处理 loading/empty/error/data。

**关键陷阱**:
- Flame 模块的 page 用 `StatefulWidget`,**不**用 `GetView`(`GameWidget` 不能跟 build 重建,要在 `initState` 实例化一次)
- 所有 `Text(...)`、`AppBar(title:...)`、SnackBar 文字走 l10n,不硬编码

**示意结构**(列表型,无 Flame):

```dart
class SomePage extends GetView<SomeController> {
  const SomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.someTitle)),
      body: StateViewBuilder<List<SomeItem>>(
        state: controller.state,
        onData: (items) => /* 列表/详情视图 */,
        onRetry: controller.load,
      ),
    );
  }
}
```

---

## ARB key 命名

加 key 时 `app_zh.arb` 与 `app_en.arb` **两份同时改**。命名 `{module}{Concept}` 小驼峰,跨模块复用的用 `common*` 前缀(`commonRetry` / `commonEmpty` / `commonLoading`)。
