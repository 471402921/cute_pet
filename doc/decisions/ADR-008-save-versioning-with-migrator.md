---
id: ADR-008
title: 游戏存档版本化 + Migrator 链
date: 2026-05-03
status: Accepted
---

## Context

游戏存档的 schema 会随版本演进(加字段、改字段、拆字段)。如果存档不带版本号,代码升级后旧用户的存档要么解析失败,要么默默错位。`shared_preferences` / 文件 / `flutter_secure_storage` 这些原始存储都不带 schema 版本管理,需要在上面包一层。

## Decision

所有持久化的游戏存档统一套 `SaveEnvelope<T>{version, savedAt, payload}`(`lib/core/storage/save_store/`)。版本升级走 `SaveMigrator<T>` 链:每条 migrator 处理一个 `fromVersion -> toVersion` 步骤,作用于**原始 JSON map**(不是 typed payload,因为旧字段可能在新 freezed 类里不存在)。`SaveStore<T>` 在 `load()` 时自动遍历 migrator 链直到匹配 `currentVersion`。

## Alternatives Considered

- **不带版本号**:被否决,任何 schema 变更都会破坏存量用户存档。
- **破坏式升级:发现版本不匹配就清存档**:被否决。学习项目可以,但生产 app 不能让用户丢数据;且本架构定位是"像素 app 通用底座",必须从一开始就守住。
- **二进制存档(protobuf 等)**:被否决,JSON 已够用且可读,Migrator 直接操作 map 比 binary descriptor 简单。

## Consequences

- 改 freezed payload schema **必须** bump `currentVersion` + 加一条 migrator + 测试覆盖跨版本 migrate(任何修改 payload schema 的 PR 都要包含这三件事)。
- Token 等敏感数据**不**用本机制(走 `flutter_secure_storage` + `AuthService`,见 conventions §3),`SaveStore` 仅给游戏存档。
- 多端云同步 / 加密 / 二进制存档不在本机制内,未来需要时另开 ADR。
