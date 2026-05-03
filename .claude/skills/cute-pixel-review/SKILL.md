---
name: cute-pixel-review
description: >
  cute_pixel 系列(像素风 Flutter+GetX+Flame 架构)的架构与上下文健康度审核 Skill,适用于基于 cute_pixel 底座的项目。
  **代码 review / 架构 review / 合规检查任何场景都必须走此 Skill**——它能拦住 lint 看不出的架构漂移和意图丢失。
  当用户想检查代码是否还守得住架构、未来开发会不会越来越难懂、文档与代码是否对得上,或做 code review / PR review 时使用此 Skill。
  触发场景包括:用户说 /cute-pixel-review、/cute-pet-review(legacy)、
  "审一下 features/health"、"看看代码漂没漂移"、"review 这个模块"、
  "检查代码合规"、"未来好维护吗"、"code review"、"审查代码"、
  "架构 review"、"合规检查"、"PR review"、"merge 前看一下"、
  "这模块写得怎么样"等。
  本 Skill 关注**结构完整性**(架构边界、模块自治)、**可读性**(注释、命名、意图传达)、**未来摩擦**(新人/Agent 上手成本),不重复 lint 的细节工作。
  本 Skill **只报告,不修改**任何文件。
---

# cute-pixel-review

按当前项目的 architecture 与 conventions,审核指定范围代码的**架构健康度**与**上下文可读性**。

## 这个 Skill 解决什么

为什么要做 review:lint 能查格式与硬错误,但**架构会偷偷漂移**(模块边界变模糊、common 池混入业务逻辑),**意图会逐渐失传**(代码做对但没人知道为什么)。半年后想加新模块或换人接手,看到一坨"对但读不懂"的代码,就会进入"上下文腐烂"——AI 和人都难再扩展。

本 Skill 拦在前面,以**原则**而非**条款**为粒度审。条款级的 lint(避免 print、import 排序、避免 dynamic 等)是 `make analyze` 和 `make fmt-check` 的事,本 Skill 不重复扫。

## 必读文档

每次执行**重新读**:

1. [CLAUDE.md](../../../CLAUDE.md) — 4 条铁律速查
2. [doc/architecture.md](../../../doc/architecture.md) — 完整架构契约
3. [doc/conventions.md](../../../doc/conventions.md) — 12 节标准

## Step 0 — Spec 软门禁(不强制,但有的话用)

review 不强制要求 PRD/TechPack 存在,但**如果存在,必须读出来做对照**——审核不只是看代码符不符合 lint/architecture,更要看实现有没有偏离 spec。

1. 询问/检测:
   - `doc/prd/{NN}-{module}.md` 存在? 状态? 取 §3 范围 + §7 验收标准
   - `doc/design/{NN}-{module}.md` 存在? 状态? 取 §2 文件清单 + §6 关键取舍
2. 若 spec 存在:在审核报告里加一节 **"D. spec 一致性"**:
   - PRD §3 MUST 项是否都有对应 controller 方法/page widget?
   - PRD §7 AC 项是否都有对应测试覆盖?
   - TechPack §2 文件清单 vs 实际 lib/features/{module}/ 是否一致?(漂移要列出来)
   - TechPack §6 关键取舍是否在代码注释里有体现?(不强求,但加分项)
3. 若 spec 不存在:报告顶部加一行提醒:"**无 PRD/TechPack 对照**,本次只能审架构/可读性/未来摩擦,无法判断实现是否偏离需求。如果这模块本该有 spec,建议先 `/cute-pixel-doc-prd {module}` 补 PRD 再回来 review"

## 工作流程

### Step 1 — 确定范围

向用户确认审核范围,**不要默认全仓**(噪声太大):
- 单模块路径(`features/pet`)
- 多个模块或 `lib/` 全仓
- git 增量(`git diff --name-only main...HEAD` + 未提交的)

排除自动生成产物(`*.g.dart`、`*.freezed.dart`、`lib/l10n/app_localizations*.dart`)。

### Step 2 — 跑 lint 基线先

先跑 `make analyze` + `make fmt-check`。如果有 issue,**告诉用户先修这些**再做架构 review,否则细节噪音会盖过架构问题。

### Step 3 — 三个原则维度审核

按下面 3 条原则审。**每条原则**对应一份 reference 详细描述了"怎么看出问题"——按需读,不要凭记忆扫表:

| 原则 | 它要拦住的腐烂 | 详细信号 |
|---|---|---|
| **A. 架构边界完整性** | 4 条铁律被悄悄破坏(features 互引、共享单点失守、`core/`/`shared/` 反向依赖 features) | [references/drift-signals.md](references/drift-signals.md) |
| **B. 意图可读性** | 代码做对但 WHY 没传达(注释缺位 / 滥用、命名模糊、关键决策没留迹) | [references/readability-signals.md](references/readability-signals.md) |
| **C. 未来摩擦面** | 新模块加进来时会绊到的隐藏陷阱(双源真理、孤儿文件、隐式依赖、规范与代码脱钩) | [references/friction-signals.md](references/friction-signals.md) |

每个原则下,只报"**有理由相信会让未来开发者/Agent 困惑**"的问题。**不报**纯个人审美、**不报** lint 已经拦的事。

### Step 4 — 输出报告

输出 markdown 报告。格式见 [references/report-template.md](references/report-template.md)。

核心是**证据驱动**:每条问题给出**文件/行号**(让用户能直接跳到)+ **读到时第一反应会是什么**(把"我作为 Agent 读到这会困惑")写出来 + **修复方向**(一句话,不写代码)。

### Step 5 — 不修

明确告诉用户:本 Skill 只报告。修复让用户人工或显式触发对应改动。批量修复倾向于把**审核者**和**实施者**搅在一起,降低判断质量。

## 不做

- 不重复 `make analyze` / `make fmt-check` 已经能拦的事(print、import 排序、`dynamic` 等)
- 不修任何文件
- 不对自动生成的 `*.freezed.dart` / `*.g.dart` / `app_localizations*.dart` 报警
- 不基于个人偏好提建议(必须能映射到 architecture 或 conventions 的某条原则)
- 不"顺便"调用 module-gen 或 test-gen
