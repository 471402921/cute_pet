---
id: ADR-011
title: Level 系统进 core/,Flame scope 扩展到 core/level/
date: 2026-05-04
status: Accepted
---

## Context

cute_pet 即将引入"院子"场景:背景空间 + 可摆放家具(带碰撞体积) + 点击宠物触发交互(叫/对话)。同时 [asset_lab](https://github.com/471402921/asset_lab) 已经把"关卡"做成一等公民(`levels/level_NNN.json`,map 当普通 entity,sprite/item/ui 按 z-order 叠)—— cute_pet 端缺一套消费契约。

这是 cute_pixel 从"pet companion app 底座"升到"像素 game 底座"的范围扩张,触发三处架构盲区:

1. [ADR-002](ADR-002-flame-scope-game-modules-only.md) 把 Flame 锁在 `features/{game-module}/` 内,**禁止进 core/** —— 但关卡(渲染 + 碰撞 + 锚点 + 触发器)天然是 Flame 强项,塞进 features/pet/ 会让下个 demo app(family/farm)复刻一遍,违反"加新实装时业务代码不动"的成熟度标准
2. [ADR-010](ADR-010-pixellab-as-asset-pipeline.md) + [pixel-foundation.md "Asset 管线"](../pixel-foundation.md#asset-管线pixellab--asset-lab--cute_pet) 没给 cute_pet 端 `levels/*.json` 留消费位置(asset-lab 当时设想是只产单 sprite,scenes JSON 仅作预览)
3. 没有"实体类型词汇"(map / sprite / collider / trigger / interactable)的契约,新增玩法机制无标准入口

LevelSpec 字段细节当前**无真实 yard level 例子**,asset-lab 那边 schema 也定不下来 —— 现在拍字段必返工。

## Decision

一次性锁三件强耦合的事(level 不可能不带 Flame,拆开读 ADR 要跨文件拼):

**(a) Flame scope 扩展**

允许 Flame 进入 **`core/level/`**(渲染、碰撞、锚点、触发器)。其它 `core/` / `shared/` / 非游戏化 feature 仍禁。本条 **supersedes ADR-002**;ADR-002 的核心精神(Flame 是渲染引擎,不污染业务/状态心智模型)在 `core/level/` 内仍然成立 —— Component 不持有业务状态,业务状态在 features/{module}/ 的 controller(同 [pixel-foundation.md "Controller ↔ Flame Game 同步契约"](../pixel-foundation.md#controller--flame-game-同步契约))。

**(b) Level 系统进 core/level/**

`core/level/` 是 **planned** 服务,提供:

| 组件 | 职责 |
|---|---|
| `LevelLoader` | 解析 `assets/levels/*.json` → LevelSpec |
| `LevelWorld`(FlameGame 子类) | 按 LevelSpec 实例化 entity、注册 collider/trigger、分发 tap/drag |
| LevelSpec 模型 | 数据契约;**字段全 deferred**,只锁命名空间 |

**实体词汇**(只声明命名空间,不展开字段):`map` / `sprite` / `collider` / `trigger` / `interactable`。新增 entity 类型 = 在词汇表加一项 + 对应 feature 注册 factory(见 (c))。

**LevelSpec schema 全 deferred**,只在 [pixel-foundation.md](../pixel-foundation.md) 占槽位 + 加 deferred 警告(同 ADR-010 game_meta.json sidecar 范式)。**触发事件 = 首个 yard level 真要进 cute_pet 那一刻原子动作**:届时一并落 LevelSpec 字段、core/level/ 实装、`assets/levels/` 目录建立、TechPack(`/cute-pixel-doc-techpack core/level`)定稿。

**(c) Entity registry = compile-time + binding-time register**

```dart
// core/level/level_world.dart  [planned]
typedef EntityFactory = Component Function(EntitySpec spec);

class LevelWorld extends FlameGame {
  final Map<String, EntityFactory> _registry = {};
  void register(String type, EntityFactory factory) => _registry[type] = factory;
  // loadFromSpec 内按 entity.type 查表 → factory(entity) → world.add
}

// features/pet/pet_binding.dart  [当前已存在,接 level 时加一行]
class PetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PetController>(() => PetController());
    Get.find<LevelWorld>().register('interactable:pet', PetComponent.fromSpec);
  }
}
```

加新 entity 类型 → 新 feature 在自己 binding 注册,**core/level/ 代码不动**(Open/Closed)。当前只 pet 一个 register,**不引入声明式 manifest** 那层抽象(YAGNI)。等 5+ feature 注册时再考虑升 manifest 不迟。

## Alternatives Considered

- **把 level 塞进 features/yard/ 而非 core/**:被否决。下个像素 app(family/farm)要复刻整套关卡逻辑,违反"成熟度判断标准"(优雅 = 加新实装时业务代码不动)
- **拆成 ADR-011(Flame scope)+ ADR-012(Level system)**:被否决。三件事强耦合(level 系统不可能不带 Flame),拆开读者要跨文件拼上下文,合并更内聚
- **声明式 manifest 注册 entity type**(类似 i18n ARB):被否决。当前只 pet 一个 register,引入 manifest 多维护一份配置 + 多一层间接,YAGNI;binding-time register 跟 GetX `Get.lazyPut` 三件套模式一致
- **让 cute_pet 直接消费 asset-lab 现有 schema**:被否决。asset-lab schema 是它渲染器的方便,cute_pet 还要碰撞/触发/可保存层,定 cute_pet 侧契约让 asset-lab 跟着导出更稳(同 ADR-010 数据契约思路:cute_pet 是消费侧,但**消费契约**定义权在 cute_pet 不在工具)
- **现在就定 LevelSpec 字段**:被否决。无真实 yard level 例子,猜的 schema 还是会再改一次;deferred + 加警告比"现在猜"更稳(同 ADR-010 game_meta sidecar 范式)
- **本 ADR 一并定编辑模式(摆家具 UI)**:被否决。前期 level 是预设的不给用户编辑,编辑模式属后期功能,后期单开 `features/yard_editor/`(或类似)feature 写自己的 PRD/TechPack 即可

## Consequences

- [ADR-002](ADR-002-flame-scope-game-modules-only.md) status 改为 `Superseded by ADR-011`;其余正文一字不动(遵循 [ADR README 修改纪律](README.md#修改纪律))
- `core/level/` 目录 + `assets/levels/` 目录**本次不建**,defer 到首个 yard level 进 cute_pet 时一并建(同 ADR-010 deferred 范式)
- [pixel-foundation.md](../pixel-foundation.md) 加 §Level 系统(planned)节 + Status snapshot 表加一行 + Asset 管线表 cute_pet 行补"消费 levels/*.json"
- 不影响 [ADR-010](ADR-010-pixellab-as-asset-pipeline.md):game_meta.json sidecar 是 sprite 元数据,与 level(asset 类型)正交;两条决议并行有效
- 不影响任何现有 `lib/` 代码:本 ADR 是契约不是实装
- LevelSpec 字段定稿、entity 词汇细化、collider/trigger 类型枚举、tap/drag 分发协议 等具体设计 → 首个 level 进 cute_pet 时通过 `/cute-pixel-doc-techpack core/level` 定 TechPack,门禁本 ADR(符合 [ADR-009](ADR-009-spec-driven-with-strong-gates.md) core 服务分支)
- cute-pixel-* skill 套件**本次不需要改** —— skill 不绑具体业务,门禁只看"对应 ADR 是否存在",本 ADR 存在后未来 core/level/ TechPack 才有据可依
- asset-lab 与 cute_pet 的 schema 契约关系明确:**cute_pet 是消费契约定义方**,asset-lab 跟着导出。asset-lab 怎么改内部预览都不影响 cute_pet,反过来 cute_pet 升级 LevelSpec 时需通知 asset-lab 同步导出器
