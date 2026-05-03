---
name: cute-pixel-doc-techpack
description: >
  cute_pixel 项目的 TechPack(技术设计文档 / 设计文档)编写 Skill,前端轻量版(对齐 Module-First Flat 而非 DDD 4 层),适用于基于 cute_pixel 底座的项目。
  **PRD 定稿后必须调用此 Skill 写 features TechPack 才能进入 module-gen**;**core 服务首次实装也必须先来此 Skill 写 core TechPack(门禁是对应 ADR 已存在)**。中间任何步都不能跳——module-gen 会拦没 TechPack 的请求,core 实装无 TechPack 也会被 review skill 标违规。
  当用户要新建/补全/审核 TechPack / 技术方案 / 设计文档(features 模块或 core/ 服务都算)时使用此 Skill。
  触发场景包括:用户说 /cute-pixel-doc-techpack、"写 TechPack"、"出技术方案"、
  "create techpack"、"design doc <模块>"、"补全 design"、"PRD 定稿了开 TechPack"、
  "技术设计文档"、"设计文档"、"技术方案设计"、"tech spec"、"technical design"、
  "把 PRD 翻成方案"、"PRD 写好了下一步"、"接后端要写设计"、"core/network 设计"、
  "core 服务的 techpack"、"接入 SaveStore 怎么设计"、"core service design"等。
  本 Skill 双模式:**features 模式**产出 doc/design/{NN}-{module}.md,门禁 = PRD 定稿;**core 模式**产出 doc/design/core-{service}.md,门禁 = 对应 ADR 已存在。
---

# cute-pixel-doc-techpack

把已定稿的 spec(features 模块的 PRD 或 core 服务的 ADR)翻成可写代码的技术方案。**双模式**,门禁与模板随模式切。

## 模式判定(Step 0 之前先做)

| 模式 | 触发 | 输入门禁 | 产出 | 模板 |
|---|---|---|---|---|
| **features**(默认) | 用户给的目标是 features 模块名(如 `health` / `family` / `pet_profile`) | PRD `doc/prd/{NN}-{module}.md` 状态 = `已定稿` | `doc/design/{NN}-{module}.md` | [references/techpack-template.md](references/techpack-template.md) |
| **core** | 用户给的目标含 `core/` 前缀(如 `core/network` / `core/auth` / `core/env`) | ADR `doc/decisions/ADR-NNN-{slug}.md` **存在**(无所谓 Status,只要有就算) | `doc/design/core-{service}.md` | [references/techpack-core-template.md](references/techpack-core-template.md) |

**判定规则**:
- 用户输入字串包含 `core/` 或 `core ` 前缀 → core 模式
- 用户输入是普通模块名 → features 模式
- 不确定就停下问:"你要给 features 模块写 TechPack,还是给 core 服务写?"

**为什么 core 没有 PRD**:core 服务是基础设施(无业务面),没人为"接后端"写 PRD。但**任何 core 服务的引入都是架构决策**——必须先有 ADR 记录"为什么要、用哪个包、什么权衡",ADR 兼任本 skill 的强门禁。

## 必读文档

每次执行**重新读**:

1. [doc/README.md](../../../doc/README.md) — 三阶段流程
2. **模板**:features 模式读 [references/techpack-template.md](references/techpack-template.md);core 模式读 [references/techpack-core-template.md](references/techpack-core-template.md)
3. [doc/architecture.md](../../../doc/architecture.md) — 模块边界、4 条铁律、core/shared
4. [doc/pixel-foundation.md](../../../doc/pixel-foundation.md) — Flame 集成 + 像素纯度 + 输入抽象 + 资源懒加载契约。**features 模式涉及任何 sprite/图片渲染、键盘鼠标输入、或大体积 asset 的模块都必读**(几乎所有像素 app 模块都涉及其中至少一项);core 模式按需(如 `core/input/` 实装必读输入抽象节)
5. [doc/conventions.md](../../../doc/conventions.md) — features 模式重 §1/§7/§10/§11/§12;core 模式重 §1 错误 + §2 环境 + §3 认证 + §5 日志(看与本服务相关的)
6. [lib/_manifest.yaml](../../../lib/_manifest.yaml) — 看 core/* 当前 Status,planned 的不能 import(features 模式);本服务从 planned → scaffolded(core 模式)

## Step 0 — Spec 强门禁(强制,不可跳过)

执行任何动作前**必须先核对对应 spec**:

### features 模式

1. 询问/检测 PRD 路径:`doc/prd/{NN}-{module}.md`
2. **打开** PRD,检查文末 `**状态**:` 一行
3. 状态判定:
   - `已定稿` → 通过门禁,继续
   - `草稿` / `评审中` → **拒绝**,告诉用户:"PRD 还没定稿,请先确认 PRD,或显式说 `skip-spec: <原因>`(仅限 prototype/throwaway demo,会写进 TechPack 头部留 audit trail)"
   - 文件不存在 → **拒绝**,引导:"先调用 `/cute-pixel-doc-prd {module}` 写 PRD"

### core 模式

1. 询问/检测 ADR 路径:`doc/decisions/ADR-NNN-{slug}.md`(若用户没给具体 ADR,先 `ls doc/decisions/` 找匹配的)
2. **打开** ADR,确认它真在讨论本服务(不是顺手抓的)
3. 状态判定:
   - 文件存在且内容相关 → 通过门禁,继续
   - 文件不存在 → **拒绝**,引导:"core 服务的引入是架构决策,先写 ADR 记录'为什么要这个服务、用哪个包、跟同类方案的对比、风险'。可手写或在 doc/decisions/ 加 `ADR-NNN-{slug}.md` 文件;参考 `doc/decisions/ADR-007-game-clock-as-singleton.md` 结构"
   - 仅模糊相关(如想接后端但只有 ADR-001 状态管理在手) → **拒绝**,要求先写专门 ADR

### `skip-spec` 例外路径(两种模式都适用)

把用户给的原因写进 TechPack 第一行:
- features 模式:`> ⚠️ skip-spec: <reason> (PRD bypass acknowledged)`
- core 模式:`> ⚠️ skip-spec: <reason> (ADR bypass acknowledged)`

照常生成,在最后报告里高亮提醒后续要补 spec。

## 工作流程

### Step 1 — 把 spec 解构成技术输入

**features 模式**:通读 PRD,提取:
- §3 第一版范围 → §2.3 文件清单(MUST 部分)
- §4 业务规则 → §3 状态形状 + §4 数据流(规则要在代码哪里落地)
- §5 数据 → §3 状态形状的 T(`Rx<ViewState<T>>` 的 T)
- §7 验收标准 → §5 测试要点(每条 AC 至少对应一个测试场景)
- §0 Figma → 写进 TechPack §2 顶部作为 UI 决策的视觉依据

**core 模式**:通读 ADR,提取:
- "为什么要这个服务" → TechPack §2.1 边界
- "用哪个包" → §2.2 外部依赖
- "跟同类方案的对比 / 权衡" → §6 关键取舍(直接引用 ADR §3/§4 编号,不重复)
- "风险 / 限制" → §3 实现选择 + §5 错误与可测性

### Step 2 — 决定结构(对照 architecture.md)

**features 模式**:
- 读 lib/_manifest.yaml 看当前 features/ + core/* + shared/*
- 决定:是否需要 Flame、是否带路由参数、依赖哪些 core/* 服务(planned 的不能直接 import 要标"依赖 X 实装完成后")、是否需要新 core/* 服务(yes → 这是个**重决策**,在 §6 写明 + 建议拆出来走 core 模式重新走流程)

**core 模式**:
- 读 lib/_manifest.yaml `core_services` 看本服务 Status(应该是 `planned`,落 TechPack 后升 `scaffolded`)
- 决定:DI 注册方式(lazyPut / put permanent / putAsync)、是否需要 abstract+impl 分离、错误模型是否扩 Failure、是否预留多 impl 接入点(默认 YAGNI 不预留)
- **不**决定:业务语义(core 无业务,纯跨切)

### Step 3 — 按模板生成初稿

按对应模板的 6 节顺序填(features 模板 §1-6,core 模板 §1-6 结构平行但内容不同):

| 节 | features 重点 | core 重点 |
|---|---|---|
| §1 | 关联 PRD(路径 + 版本 + 状态) | 关联 ADR(路径 + 标题 + 当前 Status) |
| §2 | 模块结构(Flame? 路由参数? core 依赖? 文件清单) | 服务定位(边界 + 外部依赖 + abstract 接口) |
| §3 | 状态形状(`Rx<ViewState<T>>`) | 实现选择(impl 类 + 配套类型) |
| §4 | 数据流(end-to-end:tap → controller → api → state → page) | DI 注册 + 生命周期(在哪注册、哪种方式、启动时机) |
| §5 | 测试要点(4 层覆盖率) | 错误与可测性(Failure 子类 + fake/mock 策略) |
| §6 | 关键取舍(非显然决策 + Why) | 关键取舍(实装层子决策,不重复 ADR) |

### Step 4 — 决策项 + 联动检查

生成完后**主动 prompt 用户确认**这些(写在最后摘要里):

**features 模式**:
- 是否需要新 core/* 服务?(若是 → 建议 ADR-NNN + 走 core 模式独立写一份 TechPack)
- 路由参数命名是否唯一?(对照 lib/shared/route_args/)
- l10n key 命名是否冲突?(对照 lib/l10n/app_zh.arb 现有 keys)
- 是否需要 SaveStore 版本?(若是 → §3 写明 SaveEnvelope.version 起始 = 1)
- 是否需要 GameClock 频道订阅?(若是 → §4 写明哪个 tick)

**core 模式**:
- 是否引入新 pubspec 依赖?(若是 → 走 `make add PKG=...`,版本写进 §2.2 表)
- 是否扩 sealed Failure?(若是 → conventions §1 错误流水线表也要更新)
- DI 方式选择是否合理?(对照 §4 表的"何时用")
- 是否需要 fake impl 给 features 测试用?(若是 → §5.2 列出来,作为后续工作)
- 实装完后 `lib/_manifest.yaml.core_services[本服务].status` 应升到 `scaffolded`(本 TechPack 落定稿后,实装第一刻顺手改 manifest)

### Step 5 — 输出文件 + 设状态

- **features 模式**:写入 `doc/design/{NN}-{module}.md`(NN 与 PRD 一致)
- **core 模式**:写入 `doc/design/core-{service}.md`(无 NN——core 不按编号,按服务名)
- 文末 `**状态**:` 默认 = `草稿`
- 用户明说"定稿这版"才改 `已定稿`

### Step 6 — 报告

告诉用户:

**通用**:
- 创建的文件路径
- 引用的 spec(features = PRD 路径+版本+状态;core = ADR 路径+标题)
- §6 关键取舍条数

**features 模式额外**:
- 模块复杂度评估:简单(只 page+controller+api) / 中等(带 Flame 或新 core 服务) / 复杂(跨模块 + 新存档 schema)
- **下一步**:`定稿这版 TechPack` → 然后 `/cute-pixel-module-gen {module}` 起脚手架

**core 模式额外**:
- 实装影响面:仅本服务 / 联动 features X/Y
- **下一步**:`定稿这版 TechPack` → 然后**手工实装**(core 服务无 module-gen,因为 core 太异构无 cp+sed 模板)→ 实装完跑 `/cute-pixel-review core/{service}` 兜底

## 不做

- **强门禁**:features PRD 未定稿绝不开工;core 无 ADR 绝不开工。只接受显式 `skip-spec: <reason>` 例外
- 不写后端 SQL/字段表/API 设计(那归后端 TechPack 在 spec_flow 仓库)
- 不写完整代码示例,只写"接口/状态形状"骨架(完整代码 features 归 module-gen,core 归手工实装)
- 不假设业务规则(features) / 架构决策(core) 没在 spec 里讲过的事 — 停下回查 spec,实在缺则要求用户先补 spec
- 不动 lib/ 代码,**只**写 doc/design/
- 不主动调下游 skill(features 用户确认 TechPack 定稿后才能进 module-gen;core 用户实装完才能跑 review)
