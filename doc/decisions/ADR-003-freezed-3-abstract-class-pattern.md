---
id: ADR-003
title: freezed 3.x 数据类用 abstract class with _$X 模式
date: 2026-05-03
status: Accepted
---

## Context

freezed 从 2.x 升级到 3.x 后,数据类声明语法发生破坏性变更。沿用 2.x 的 `class Pet with _$Pet` 写法会触发 `non_abstract_class_inherits_abstract_member` 编译错误,Sealed Union 没显式 `sealed` 修饰也会报错。这是 Agent/人最容易踩的坑。

## Decision

按 conventions §10 "freezed 3.x 关键差异" 固定两种写法:

- 数据类:`@freezed abstract class Pet with _$Pet { ... }`
- Sealed Union(如 `ViewState<T>`):`@freezed sealed class ViewState<T> with _$ViewState<T> { ... }`

消费侧弃用 `.when` / `.map`,改用 Dart 3 `switch` 表达式做模式匹配。

## Alternatives Considered

- **手写 `==` / `hashCode` / `copyWith` / `fromJson`**:conventions §10 明确禁止,代码量多 60% 且易写错。

(降级到 freezed 2.x 未深入考虑过;锁定一个稳定版本即可,不在此 ADR 重新评估。)

## Consequences

- `make codegen` 必须在改 `@freezed` 类后跑,产物(`.freezed.dart` / `.g.dart`)必须提交。
- 模板代码已写进 conventions §10,新模块按模板抄即可。
- `Failure` 类除外:用 plain Dart sealed,不需要 `copyWith` / `toJson`。
