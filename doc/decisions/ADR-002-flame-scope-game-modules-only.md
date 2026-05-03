---
id: ADR-002
title: Flame 仅限游戏化模块,不外溢
date: 2026-05-03
status: Accepted
---

## Context

cute_pixel 内 features/pet/ 用 Flame 实现宠物动画(`features/pet/`)。Flame 是完整的游戏引擎,如果允许它扩散到 `core/` 或非游戏化 feature,会让原本"Flutter UI + GetX 状态"的简单心智模型被污染,跨模块工作时 Agent/人都要额外学 Flame。

## Decision

Flame 是**使用它的模块的实现细节**,只能出现在该模块的 `features/{game-module}/` 内部(目前只有 `pet/`,新游戏化模块按需可加)。**不**进入 `core/`、`shared/` 或非游戏化 feature。

## Alternatives Considered

- **全面游戏化(Flame 主导整个 app shell)**:被否决,本项目主体是 Flutter UI,只有宠物展示需要游戏循环。
- **把 Flame 抽到 `core/game/` 共享层**:违反 pixel-foundation.md "Flame 的位置" 与铁律 2(共享单点必须业务无关)。

## Consequences

- Flame Component **只负责渲染**,业务状态留在 GetX controller(pixel-foundation.md "Controller ↔ Flame Game 同步契约")。
- 新模块默认不引入 Flame;若要引入需明确该模块属于游戏化范畴。
- Flame 的 Component 可脱离 GetX 在纯 Flame 测试里跑(同节)。
