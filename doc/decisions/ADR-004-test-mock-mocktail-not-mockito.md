---
id: ADR-004
title: 测试 mock 用 mocktail 不用 mockito
date: 2026-05-03
status: Accepted
---

## Context

Flutter 生态两套主流 mock 方案:`mockito`(老牌,需要 `build_runner` 生成 `*.mocks.dart`)与 `mocktail`(无代码生成,运行时 mock)。项目已经因 freezed/json_serializable 用了 build_runner,如果再叠 mockito 的 mock 生成,每改一次接口都要重跑 codegen,测试反馈环变长。

## Decision

测试 mock 统一使用 **mocktail**。在 `pubspec.yaml` 的 dev_dependencies 里只装 mocktail,不装 mockito。

## Alternatives Considered

- **mockito + build_runner**:考虑过,被否决。本项目大量任务由 Agent(且部分用便宜模型)执行,需要强调可读性与稳定性;mockito 加一层 codegen,产物不直接可读、改接口就要重跑,影响 Agent 反馈环。mocktail 写法直白(`when(() => api.fetchPets()).thenAnswer(...)`),Agent 出错率更低。
- **手写 fake 类**:未深入考虑过;在简单场景下可行,但 mocktail 已能覆盖,无需引入第二种风格。

## Consequences

- mock 类直接 `class _MockApi extends Mock implements PetApi {}`,无需运行 codegen 才能跑测试。
- conventions §7 提供的 controller 测样例已基于 mocktail 风格(`when(() => ...).thenAnswer(...)`)。
- 与 mockito 的 `@GenerateMocks` / `verify(...)` API 不通用,从其他项目拷过来的测试代码需要改写。
