---
id: ADR-001
title: 状态管理选 GetX 不选 Riverpod
date: 2026-05-03
status: Accepted
---

## Context

参考仓库 `spec_flow_frontend` 使用 Riverpod 作为状态管理方案,但 cute_pixel 项目从一开始就分歧选择了 GetX。后续看到代码里 `Get.lazyPut` / `GetxController` / `Rx<T>` 全套时,需要明确这是有意决定,不是抄漏。

## Decision

cute_pixel 状态管理统一使用 **GetX**。模块标准三件套:`{module}_binding.dart`(`Get.lazyPut`)+ `{module}_controller.dart`(`GetxController`)+ `{module}_page.dart`(`Obx`)。

## Alternatives Considered

- **Riverpod**:参考仓库 `spec_flow_frontend` 默认方案,生态主流;未选,理由:GetX 路由 + DI + 状态一站式,API 更简单、可读性更好,对学习场景与小到中等规模 app 更顺手。

## Consequences

- 跨模块通信走 GetX 三种方式(全局服务 / 共享 Rx / 事件总线),见 conventions §11。
- 不引入 Riverpod 相关依赖与 codegen,避免双状态管理库共存。
- 与 `spec_flow_frontend` 不能直接照抄状态层代码,需要按 GetX 重写。
