# Tech Pack 模板(前端 / Module-First Flat)

> 复制本文件到 `design/{NN}-{module}.md` 后填写。**前置条件**:对应 PRD-Lite 已**定稿**(状态 = 已定稿)。

> 本模板对齐 [architecture.md](../architecture.md) 的 Module-First Flat + [pixel-foundation.md](../pixel-foundation.md) 的 Flame 契约。前端 TechPack **不写**后端字段表/SQL/API 设计——那些归后端 TechPack。

---

## 1. 关联 PRD

- **PRD 路径**:`../prd/{NN}-{module}.md`
- **PRD 版本**:`v0.1`
- **状态匹配**:本 TechPack 草稿对应 PRD 哪一稿(PRD 改了要回过来更新本节)

---

## 2. 模块结构(对照 architecture.md)

### 2.1 模块归属与依赖

- **模块路径**:`lib/features/{module}/`
- **是否使用 Flame**:`否 / 是(走 pixel-foundation.md "Flame 的位置")`
- **是否带路由参数**:`否 / 是 → lib/shared/route_args/{module}_route_args.dart`
- **路由路径**:`/{module}`
- **依赖的 core/* 服务**(必须 Status ≥ scaffolded,见 architecture.md 状态标记):
  - `lib/core/error/failures.dart` ✅ in-use
  - `lib/core/time/game_clock.dart` (scaffolded) — 是/否使用
  - `lib/core/storage/save_store/` (scaffolded) — 是/否使用
  - 其它…
- **依赖的 shared/* 资源**:
  - `lib/shared/widgets/state_view_builder.dart` (in-use) — 默认用
- **被哪些其它 module 引用**:`无 / route_args 被 home 引用 / ...`

### 2.2 像素底座维度(对照 [pixel-foundation.md](../../../doc/pixel-foundation.md) 4 节)

> 任何渲染像素图、处理键盘鼠标、加载体积 asset 的模块都该回答这 4 题。纯表单/列表型模块全填"无"也要写,留个 audit trail。

- **渲染器选择(web)**:`默认跟 app(CanvasKit)` / `本模块对 HTML renderer 有特殊偏好,理由:...`
- **像素纯度**:本模块**是否渲染** sprite / 图片 / 自定义画图?
  - `否`(纯文字/按钮/列表)
  - `是` → 所有 `Image.asset(...)` / `Sprite` 必须 `FilterQuality.none` + 整数缩放比;字体若用位图字体在此声明;参考 [pixel-foundation.md "像素纯度自检"](../../../doc/pixel-foundation.md#像素纯度自检)
- **输入语义**:本模块需要哪些输入(一旦 `core/input/` scaffolded 就在此声明订阅)?
  - `仅 tap`(手机 + web 鼠标点击,默认)
  - `PrimaryAction / SecondaryAction / Move / 其它` → 列出来 + 在 web 上对应的键位预期(如 WASD / 方向键)
- **资源懒加载**:本模块初始 asset 大小估算?
  - `<5MB` → 走默认(随 app bundle 一起加载)
  - `>=5MB` → 列出懒加载策略(按 species/action 拆 / 进入 page 时再加载 / 预加载触发条件等),参考 [pixel-foundation.md "资源懒加载"](../../../doc/pixel-foundation.md#资源懒加载)

### 2.3 文件清单(本模块要新建/改的)

| 文件 | 是否新建 | 备注 |
|---|---|---|
| `{module}_page.dart` | 新建 | Scaffold + StateViewBuilder |
| `{module}_controller.dart` | 新建 | 状态唯一真理 |
| `{module}_binding.dart` | 新建 | Get.lazyPut |
| `{module}_models.dart` | 新建 / 不需要 | freezed 数据类 |
| `{module}_api.dart` | 新建 / 不需要 | mock 优先 |
| `lib/shared/route_args/{module}_route_args.dart` | 新建 / 不需要 | 跨模块契约 |
| `{module}_game.dart` + `components/` | 新建 / 不需要 | 仅 Flame 模块 |
| `lib/app/app_routes.dart` | 改 | 加 `static const {module} = '/...'` |
| `lib/app/app_pages.dart` | 改 | 加 GetPage |
| `lib/l10n/app_zh.arb` + `app_en.arb` | 改 | 加 `{module}*` keys(双语) |

---

## 3. 状态形状

```dart
// {module}_controller.dart
final state = Rx<ViewState<List<XxxItem>>>(const ViewState.loading());
// 其它 .obs 字段(若有):
// - selectedId: Rxn<String>()
// - filter: Rx<XxxFilter>(...)
```

- **何时 emit Loading**:`load()` 入口
- **何时 emit Empty**:`api 返回空列表`
- **何时 emit Error**:`catch on Failure`
- **何时 emit Data**:`api 返回非空列表`

---

## 4. 数据流(端到端)

```
User tap → page.onTap → controller.{action}()
                      → api.{call}()  → returns Future<XxxItem>
                      → controller updates state
                      → Obx() rebuilds page
```

- **API 形态**:mock 阶段返回 `Future<List<XxxItem>>` 写死;真接后端时 catch DioException → 抛 Failure 子类
- **存档**(若有):`SaveStore<XxxSave>` + `SaveEnvelope` version `1`,初版 migrators 列表为空
- **跨模块通信**(若有):`Get.find<SomeService>()` / `Rx<...>` / `Get.bus.fire(XxxEvent)`(对照 conventions §11)

---

## 5. 测试要点(对照 conventions §7)

| 层 | 测什么 | 覆盖率目标 |
|---|---|---|
| models | fromJson↔toJson 往返 / defaults / copyWith | ≥90% |
| api | mock 阶段:返回非空、id 不重复、字段合理 | ≥80% |
| controller | mock api,3 状态(Data/Empty/Error)+ 每个公开方法 1 用例 | ≥70% |
| page | 关键不可逆操作(删除/提交)的 widget 测 | ≥50%(关键路径必写) |

---

## 6. 关键取舍(写下非显然的决策)

> 模型自己想不到的、半年后会被人质疑的选择都写下来,带 **Why**。例如:
>
> - 为什么用 `ListView` 而不是 `CustomScrollView` — Why: 列表项数 < 100,常规 ListView 性能足够,后者会增加学习成本
> - 为什么 controller 暴露 `Rx<List>` 而不是 `Rx<ViewState<List>>` 套两层 — Why: ...

(若没有非显然取舍,写"无,均按 conventions/architecture 默认")

---

**状态**:草稿 / 评审中 / **已定稿**(只有定稿后才能开始写代码)
**最后修改**:YYYY-MM-DD
