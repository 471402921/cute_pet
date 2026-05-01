# Tech Pack 模板

> 复制本文件到 `design/{NN}-{module}.md` 后填写。**前置条件**:对应 PRD-Lite 已定稿。

---

## 1. 关联 PRD

`../prd/{NN}-{module}.md`(链上)

## 2. 模块定位

- **属于哪个 feature**:`lib/features/{module}/`
- **依赖哪些 core/shared 能力**:
- **被哪些其它模块依赖**:

## 3. 领域模型(domain/)

### 实体(entities/)

```dart
// 纯 Dart,无任何框架引用
class Pet {
  final String id;
  final String name;
  final PetSpecies species;
  // ...
}
```

### 值对象(value_objects/)

(不可变 + 等值靠属性,例如 `Weight`, `BirthDate`)

### 仓储接口(repositories/)

```dart
abstract class PetRepository {
  Future<Pet?> findById(String id);
  Future<List<Pet>> findAll();
  Future<void> save(Pet pet);
}
```

## 4. 用例(application/, 可选)

简单模块可省略;有跨实体编排时填:

```dart
class CreatePetUseCase {
  final PetRepository _repo;
  // ...
}
```

## 5. 基础设施(infrastructure/)

### 数据来源
- 后端 API: `GET/POST ...`
- 本地存储: shared_preferences key `...` / SQLite 表 `...`

### DTO 与 converter
```dart
class PetDTO { ... }
extension on PetDTO { Pet toDomain() => ...; }
```

### 仓储实现
```dart
class PetRepositoryImpl implements PetRepository {
  final ApiClient _api;
  final LocalStorage _storage;
  // ...
}
```

## 6. UI(presentation/)

### 页面与路由
- 路由名:`AppRoutes.pet`
- 页面文件:`pet_page.dart`

### Controller 状态
```dart
class PetController extends GetxController {
  final pets = <Pet>[].obs;
  final loading = false.obs;
  // 暴露的方法:loadAll(), select(id), ...
}
```

### Binding
```dart
class PetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PetRepositoryImpl(...));
    Get.lazyPut(() => PetController(Get.find()));
  }
}
```

## 7. 错误处理

(列出可能的失败场景与对应的 Failure 类型)

- 网络失败 → `NetworkFailure` → UI 显示"网络异常"
- 数据不存在 → `NotFoundFailure` → UI 显示空状态
- ...

## 8. 测试要点

- domain/ 的实体/值对象/用例 → 纯单元测试(无 widget,无 mock framework)
- repository 实现 → mock 数据源
- controller → mock repository,断言 `obs` 状态变化
- page → widget test(快照核心交互)

## 9. 关键取舍

(写下做这个模块时**模型不容易自己想到**的决策与原因)

- 为什么 ... 而不是 ...
- ...

---

**状态**:草稿 / 评审中 / **已定稿**(只有定稿后才能开始写代码)
**最后修改**:YYYY-MM-DD
