# Tech Pack 模板 — core 服务(前端基础设施)

> 复制本文件到 `doc/design/core-{service}.md` 后填写。**前置条件**:对应 ADR **已存在**(无 ADR 不开 core 服务——任何引入新依赖、新跨切抽象、新生命周期模式的决策都得先有 ADR 锁住理由)。

> 本模板对齐 [architecture.md](../../architecture.md) 的 `core/` 边界(基础设施零件,业务无关)。core 服务**不属于**任何 feature,跨模块共享单点。

---

## 1. 关联 ADR

- **ADR 路径**:`doc/decisions/ADR-NNN-{slug}.md`
- **ADR 标题**:`{完整标题}`
- **服务路径**:`lib/core/{service}/`
- **当前 Status**(对照 [_manifest.yaml](../../../lib/_manifest.yaml) `core_services`):`planned`(本 TechPack 落完 + 实装 → `scaffolded`,首个 features import → `in-use`)

> 若用户跳门禁:`> ⚠️ skip-spec: <reason> (ADR bypass acknowledged)` 写在第一行,后续仍要补 ADR。

---

## 2. 服务定位

### 2.1 边界(做什么 / 不做什么)

- **做什么**(一句话):`...`
- **不做什么**(显式 out of scope):`...`(例:`不做 cloud sync`、`不做 token 刷新策略,只做 token 存取`)
- **跨切关注点 vs 业务语义**:必须 100% 跨切,无业务语义。若发现某能力只服务一个 feature,应该归 `features/{module}/` 而不是 `core/`(参考铁律 #2)

### 2.2 外部依赖

| 包 | 版本 | 已装 | 用途 | ADR 关联章节 |
|---|---|---|---|---|
| `dio` | `^5.x` | ✓/待装 | HTTP client | ADR-NNN §3 |
| ... | ... | ... | ... | ... |

> 引入任何**新**依赖必须在 ADR 里讲清"为什么选这个、跟同类方案的对比、风险"。pubspec.yaml 启用走 `make add PKG=<name>`(CN 镜像)。

### 2.3 核心接口(abstract)

```dart
// lib/core/{service}/{service}.dart
abstract class XxxService {
  Future<...> doSomething(...);
  Stream<...> get observableThing;
}
```

- 接口暴露什么(方法 + 流 + 配置)
- **不**暴露的内部细节(实现类/拦截器栈/拓扑)

---

## 3. 实现选择

### 3.1 实装类

- **文件**:`lib/core/{service}/{service}_impl_{flavor}.dart`(例:`http_client_impl_dio.dart`、`save_store_impl_prefs.dart`)
- **与 abstract 的关系**:`implements XxxService`(总是接口在前,impl 在后)
- **是否预留多 impl 接入点**:
  - `否`(只有这一种实装,后续真要换走重构)
  - `是`(可能有 fake / cloud / mock 三种,在 §4 DI 提供切换点)

### 3.2 配套类型(若有)

- 错误类型:走 `core/error/failures.dart` 的 sealed `Failure` 还是新起?(优先扩 Failure)
- 配置类型:`@freezed XxxConfig`?
- 事件类型:`sealed class XxxEvent`?

---

## 4. DI 注册与生命周期

### 4.1 注册位置

- `lib/app/app_binding.dart`(全局服务,默认)
- 或单独的 `core/{service}/{service}_binding.dart`(若注册逻辑复杂)

### 4.2 注册方式

| 方式 | 何时用 | 例 |
|---|---|---|
| `Get.lazyPut<X>(() => X())` | 首次 `Get.find` 时构造,大多数 service 用这个 | api、storage |
| `Get.put<X>(X(), permanent: true)` | 启动就要在,跨页面常驻 | GameClock、Env |
| `Get.putAsync<X>(() async => await X.create())` | 构造需要 await(如 `SharedPreferences.getInstance`) | SaveStore impl |

**本服务用**:`...`,**Why**:`...`

### 4.3 启动时机

- 冷启动**必须**注册前置项(如 SaveStore 依赖 Env / Logger)?列出顺序
- 是否要在 `main()` `await` 完成才能 `runApp`?(如 first-launch DB 初始化)

---

## 5. 错误与可测性

### 5.1 错误模型

- 走 `core/error/failures.dart` 的 sealed `Failure` 体系
- 本服务可能产生哪些 `Failure` 子类?(列出来,新加的子类**也**写进 conventions §1 错误流水线)

### 5.2 测试策略

| 层 | 测什么 | 工具 |
|---|---|---|
| 接口契约 | abstract `XxxService` 的预期行为约束 | 共享 test helper |
| impl 单元 | 实装类的具体行为(mock 外部包) | mocktail(对照 ADR-004) |
| 集成 | 真依赖 + 本服务 + 一个调用方 | flutter_test |

- **测试覆盖率目标**:对照 conventions §7 "core 服务" 一栏(若没有则补)
- **fake / in-memory impl**:是否需要为下游 features 测试提供 fake 版本?(如 `SaveStoreImplFake` 用 `Map<String,String>` 内存模拟 prefs)

---

## 6. 关键取舍

> 模型自己想不到的、半年后会被人质疑的选择都写下来,带 **Why**。例:
>
> - 为什么用 `dio` 不用 `http` — Why: 拦截器/取消/上传进度更全面,ADR-NNN §3 详述
> - 为什么 SaveStore 用 `Get.lazyPut` 而不是 `putAsync` — Why: SharedPreferences.getInstance 在 Dart 层有缓存,首次稍慢但后续零成本
> - 为什么不预留多 impl 接入点 — Why: YAGNI,真要换 impl 时机械替换比预留抽象层更便宜
>
> 与 ADR 的关系:ADR 是"为什么要这个服务",§6 是"实装层面的子决策"。两者互补,不重复。

(若没有非显然取舍,写"无,实装严格按 ADR-NNN + conventions/architecture 默认")

---

**状态**:草稿 / 评审中 / **已定稿**(只有定稿后才能开始实装)
**最后修改**:YYYY-MM-DD
