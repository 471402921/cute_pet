---
id: ADR-005
title: Module-First Flat 而非 DDD 4 层
date: 2026-05-03
status: Accepted
---

## Context

后端项目常用 DDD 4 层(presentation / application / domain / infrastructure),每层一目录。前端业务大头在后端,Flutter 端主要是 UI + 状态 + API 调用,如果照搬 4 层会产出大量空壳层(每个模块 4 个目录,各装 1-2 个文件),反而增加跨模块工作时的上下文负担 —— 而本项目首要目标就是减少这个负担。

## Decision

每个业务模块在 `features/{module}/` 内部**平铺**,按职责命名文件(`{module}_page.dart` / `_controller.dart` / `_binding.dart` / `_models.dart` / `_api.dart`),不嵌套层目录。复杂模块(如 Flame 的 pet)可加专属文件,仍保持平铺。**例外**:`{module}_route_args.dart` 因被外部 feature 引用,放 `shared/route_args/`,见 architecture.md "Module-First Flat" 一节。

## Alternatives Considered

- **DDD 4 层(presentation/application/domain/infrastructure)**:被否决,理由见 architecture.md "设计目标"(产生空壳层、增加上下文负担)。
- **按类型分目录(controllers/ / models/ / pages/)**:考虑过,被否决。前端业务不重,层级太多反而拖效率,做一个模块要跨多个目录,违反"做某个模块只看一个文件夹"的目标。

## Consequences

- 4 条铁律(模块自治、共享单点、单向依赖、命名一致)替代 DDD 分层做约束。
- 跨模块共享只能进 `core/` 或 `shared/`,不能从某 feature 横向 import。
- 文件命名 `{module}_*.dart` 强制,Agent 看名字就知道职责,无需读目录结构。
