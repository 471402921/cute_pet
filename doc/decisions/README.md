# Architectural Decision Records (ADRs)

ADR(架构决策记录)是对一项**非显然的架构/技术选择**的简短书面记录,目的是让未来的人(或 Agent)在看到代码时能区分"漂移"和"有意为之的例外"。

## 什么时候写 ADR

只在**未来读者可能会质疑**的决策时写:非显然的技术选型(选了 A 但参考项目都用 B)、边界/范围约束(某工具只在某模块用)、踩过坑后的固定写法、排除某方案的理由。命名约定/目录结构/代码风格不写 ADR,放 conventions/architecture。

## 模板字段

```markdown
---
id: ADR-NNN
title: <决策标题>
date: YYYY-MM-DD
status: Accepted | Superseded by ADR-NNN | Deprecated
---

## Context
<2-3 句:背景与触发原因>

## Decision
<1-2 句:实际决定做什么>

## Alternatives Considered
- <方案 A>:<为什么没选>
- <方案 B>:<为什么没选>

## Consequences
- <好处或代价>
- <对后续工作的约束>
```

## 命名

`ADR-NNN-short-slug.md`,NNN 三位零填充、严格递增。例:`ADR-001-state-management-getx.md`。

## 修改纪律

ADR **只追加,不修改**。已 Accepted 的决策若被推翻,新建一条 ADR(状态 Accepted),并把旧 ADR 状态改为 `Superseded by ADR-NNN`(只改 status 一行)。
