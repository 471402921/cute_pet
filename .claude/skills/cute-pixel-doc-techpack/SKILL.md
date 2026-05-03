---
name: cute-pixel-doc-techpack
description: >
  cute_pixel 项目的 TechPack 编写 Skill,前端轻量版(对齐 Module-First Flat 而非 DDD 4 层)。
  适用于 cute_pet 等基于此底座的项目。
  当用户要新建/补全/审核 TechPack(技术方案)时使用此 Skill。
  触发场景包括:用户说 /cute-pixel-doc-techpack、"写 TechPack"、"出技术方案"、
  "create techpack"、"design doc <模块>"、"补全 design"、"PRD 定稿了开 TechPack"等。
  本 Skill 产出 doc/design/{NN}-{module}.md,严格按 doc/design/_TEMPLATE.md 6 节结构。
  **强门禁**:必须有定稿 PRD(doc/prd/{NN}-{module}.md 状态 = 已定稿)才能开工,没有就引导先写 PRD。
---

# cute-pixel-doc-techpack

按 [doc/design/_TEMPLATE.md](../../../doc/design/_TEMPLATE.md) 把定稿 PRD 翻成可写代码的技术方案,产出 `doc/design/{NN}-{module}.md`。

## 必读文档

每次执行**重新读**:

1. [doc/README.md](../../../doc/README.md) — 三阶段流程
2. [doc/design/_TEMPLATE.md](../../../doc/design/_TEMPLATE.md) — 6 节模板(对齐 Module-First Flat)
3. [doc/architecture.md](../../../doc/architecture.md) — 模块边界、4 条铁律、core/shared
4. [doc/pixel-foundation.md](../../../doc/pixel-foundation.md) — Flame 集成契约(Flame 模块必读)
5. [doc/conventions.md](../../../doc/conventions.md) — §1 错误 / §7 测试 / §10 freezed / §11 跨模块 / §12 时间存档
6. [lib/_manifest.yaml](../../../lib/_manifest.yaml) — 看 core/* 当前 Status,planned 的不能 import

## 强门禁(Step 0,不可跳过)

执行任何动作前**必须先核对 PRD**:

1. 询问/检测 PRD 路径:`doc/prd/{NN}-{module}.md`
2. **打开** PRD,检查文末 `**状态**:` 一行
3. 状态判定:
   - `已定稿` → 通过门禁,继续
   - `草稿` / `评审中` → **拒绝**,告诉用户:"PRD 还没定稿,请先确认 PRD,或显式说 `skip-spec: <原因>`(仅限 prototype/throwaway demo,会写进 TechPack 头部留 audit trail)"
   - 文件不存在 → **拒绝**,引导:"先调用 `/cute-pixel-doc-prd {module}` 写 PRD"
4. `skip-spec` 例外路径:把用户给的原因写进 TechPack 第一行 `> ⚠️ skip-spec: <reason> (PRD bypass acknowledged)`,并照常生成

## 工作流程

### Step 1 — 把 PRD 解构成技术输入

通读 PRD,提取:
- §3 第一版范围 → §2.2 文件清单(MUST 部分)
- §4 业务规则 → §3 状态形状 + §4 数据流 (规则要在代码哪里落地)
- §5 数据 → §3 状态形状的 T (`Rx<ViewState<T>>` 的 T)
- §7 验收标准 → §5 测试要点 (每条 AC 至少对应一个测试场景)
- §0 Figma → 写进 TechPack §2 顶部作为 UI 决策的视觉依据

### Step 2 — 决定模块结构(对照 architecture.md)

- 读 lib/_manifest.yaml 看当前 features/ + core/* + shared/*
- 决定:
  - 是否需要 Flame(读 pixel-foundation.md 的 "Flame 的位置")
  - 是否带路由参数(yes → 在 shared/route_args/ 建)
  - 依赖哪些 core/* 服务(planned 的不能直接 import,要标 "依赖 X 实现完成后")
  - 是否需要新 core/* 服务(yes → 这是个**重决策**,在 §6 写明 + 建议加 ADR)

### Step 3 — 按模板生成初稿

按 [_TEMPLATE.md](../../../doc/design/_TEMPLATE.md) 6 节顺序:

| 节 | 重点 |
|---|---|
| §1 关联 PRD | 路径 + 版本 + 状态 |
| §2 模块结构 | Flame? 路由参数? core 依赖? 文件清单(对齐 architecture.md Module-First Flat) |
| §3 状态形状 | controller 的 `Rx<ViewState<T>>` 中 T 是什么 + 何时 emit 各状态 |
| §4 数据流 | 端到端:tap → controller → api → state → page |
| §5 测试要点 | 4 层 (models/api/controller/page) 的覆盖率目标 + 必测项 |
| §6 关键取舍 | 非显然决策 + Why |

### Step 4 — 决策项 + 联动检查

生成完后**主动 prompt 用户确认**这些(写在最后摘要里):
- 是否需要新 core/* 服务?(若是 → 建议 ADR-NNN)
- 路由参数命名是否唯一?(对照 lib/shared/route_args/)
- l10n key 命名是否冲突?(对照 lib/l10n/app_zh.arb 现有 keys)
- 是否需要 SaveStore 版本?(若是 → §3 写明 SaveEnvelope.version 起始 = 1)
- 是否需要 GameClock 频道订阅?(若是 → §4 写明哪个 tick)

### Step 5 — 输出文件 + 设状态

- 写入 `doc/design/{NN}-{module}.md`(NN 与 PRD 一致)
- 文末 `**状态**:` 默认 = `草稿`
- 用户明说"定稿这版"才改 `已定稿`

### Step 6 — 报告

告诉用户:
- 创建的文件路径
- 引用的 PRD 路径 + 版本 + 状态
- 模块复杂度评估:简单(只 page+controller+api) / 中等(带 Flame 或新 core 服务) / 复杂(跨模块 + 新存档 schema)
- §6 关键取舍条数
- **下一步**:`定稿这版 TechPack` → 然后 `/cute-pixel-module-gen {module}` 起脚手架

## 不做

- **强门禁**:PRD 未定稿绝不开工,只接受显式 `skip-spec: <reason>` 例外
- 不写后端 SQL/字段表/API 设计(那归后端 TechPack 在 spec_flow 仓库)
- 不写完整代码示例,只写"状态形状"骨架(完整代码归 module-gen)
- 不假设业务规则没在 PRD 里讲过的事 — 停下回查 PRD,实在缺则要求用户先补 PRD
- 不动 lib/ 代码,**只**写 doc/design/
- 不主动调 module-gen(用户确认 TechPack 定稿后才能进下一阶段)
