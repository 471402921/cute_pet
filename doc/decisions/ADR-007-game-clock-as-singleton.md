---
id: ADR-007
title: GameClock 作为 core/ 单例 GetxService
date: 2026-05-03
status: Accepted
---

## Context

像素 app 里大量逻辑由时间驱动:宠物每 N 分钟饿一点、植物每小时长一格、商店每 24 小时刷新。如果每个 controller 各起 `Timer.periodic`,会出现 N 个不同节奏并存,且离线 / 重启后的 catch-up 没有统一入口,容易腐烂。

## Decision

时间源统一收口在 `lib/core/time/game_clock.dart` 的单例 `GameClock`(GetxService)。它暴露三档预设流(`tick1s` / `tick1m` / `tick10m`)与 `catchUp(DateTime lastSavedAt)` 接口。所有时间驱动的业务**必须**订阅它,**禁止** controller 自行 `Timer.periodic`。

## Alternatives Considered

- **每个 controller 自起 Timer.periodic**:被否决,原因即上述 Context —— N 套节奏 + 没人写 catch-up + 测试时不可注入 fake clock。
- **每个 controller 各持一个 GameClock 实例**:被否决,失去单点 catch-up 与全局节奏一致性。

## Consequences

- 测试时通过构造参数注入 `clock: () => fixedNow` 即可换 fake clock 取当前时间。
- 离线 / 后台回前台 / 重启后的 catch-up 集中在 `GameClock.catchUp`,业务方拿 elapsed Duration 自行决定补几次。
- 未来加"暂停/加速""应用生命周期监听"只改一处。

## Known limitations

- **`tick1s` / `tick1m` / `tick10m` 是真 wall-clock `Stream.periodic`**,与 `clock` 注入分离——`clock` 只换"取当前时间"的来源,**不**换 stream 节奏。结果:测试想"推进 5 分钟看 tick1m 触发 5 次"做不到(stream 真等 5 分钟)。一致的两条路:
  - **业务侧**:tick 是 best-effort 节奏信号,业务**不要**靠 tick 数累计,要靠**绝对时间差**(通过 `now()` 或 `catchUp(lastSavedAt)`)。后台/暂停期间漏的 tick 永远不补播;补偿走一次性 catchUp。
  - **测试侧**:测节奏触发逻辑,直接调订阅回调 + 推进 fake `clock`(单元测);测累计时长,用 catchUp 一次性返回 elapsed,断言业务正确处理。
- 若未来真需要"可推进的虚拟时钟"(同时控制取时与节奏),需要把 `Stream.periodic` 换成可注入的 `Stream<Tick>` 工厂,并在本 ADR 加修订条目。当前 mobile-only 阶段不阻塞。
