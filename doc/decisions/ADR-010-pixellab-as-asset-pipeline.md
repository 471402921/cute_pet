---
id: ADR-010
title: Asset 管线以 pixellab.ai 为上游,asset-lab 只做预览/编排,cute_pet 只做消费
date: 2026-05-04
status: Accepted
---

## Context

设计师产 sprite 的工作启动后,暴露三个问题:
1. 用 cute_pixel(Flutter+GetX+Flame+codegen+lint+test)调一张图链路太长——为生产准备的链路不适合 5 秒 iteration
2. 设计师手上的工具是 [pixellab.ai](https://www.pixellab.ai/),自带 8 方向 + 动画生成 + 单 sprite 预览,但**不做**场景编排、跨资源交互预览、项目级资源管理
3. cute_pet 的 [assets/{type}/_template/manifest.json](../../assets/sprites/_template/manifest.json) 是 pixellab 决定**之前**写的(4 方向 / sprite sheet / 自造字段名),与 pixellab 实际导出格式(8 方向 / frame-per-file / `metadata.json` schema)完全不一致

需要一次性把"asset 从产出到消费"的完整管线锁定,避免每次接资源都重新讨论。

## Decision

**三段式管线,职责严格不重叠**:

```
[pixellab.ai]  →  [asset-lab]   →  [git repo]   →  [cute_pet]
 生成零件         多图交互预览      版本管理        运行时消费
                  场景编排
```

| 角色 | 做什么 | 不做什么 |
|---|---|---|
| **pixellab.ai**(团队订阅 + MCP) | AI 生成 sprite/items/maps/tilesets,导出 metadata.json + pngs;Characters 模块自带单 sprite 预览 | 场景编排、跨资源交互预览、资源库管理 |
| **asset-lab**(独立 repo,纯 HTML+Canvas) | 键盘交互预览(切方向/动画)、多资源同屏预览、声明式场景编排(scenes/{level}.json) | 任何 AI 生成、任何编辑 UI(MVP)、自定义 sprite/items schema |
| **git** | 资源 + 场景版本管理 | - |
| **cute_pet** | 运行时消费 metadata.json + 可选 game_meta.json sidecar | 复刻 pixellab 生成、复刻 asset-lab 预览 |

**数据契约**:
- sprite/items 等"长什么样"的元数据 → 严格跟随 **pixellab metadata.json**(不发明 schema)
- 场景描述 → 自定义 **scenes/{level}.json**(asset-lab 维护,简单 schema)
- "游戏怎么用"的元数据(锚点/动画 fps/碰撞框)→ 未来的 **game_meta.json sidecar**,槽位预留在 cute_pet,**字段定稿延后**到首个 sprite 真要进 cute_pet 时

**cute_pet 端的 deferred 项**:
- 通用 sprite loader 不预建,等首个 pixellab sprite 真要进 cute_pet 时再实装(YAGNI;asset-lab 阶段先把契约打磨稳)
- 现 [assets/{sprites,items,effects}/_template/](../../assets/sprites/_template/) 三个模板已加 DEPRECATED 警告,触发"真重做"的事件 = 首个 pixellab 资源进入 cute_pet
- [doc/pixel-foundation.md](../pixel-foundation.md) "Asset 资源约定"段同步加 deprecation 警告,新 loader 方案随真实资源接入一起重写

完整方案细节见 [asset-lab-plan.md](../../asset-lab-plan.md)。

## Alternatives Considered

- **造一个"sprite-lab"覆盖生成 + 预览**:被否决。重复造 pixellab 的 AI 生成轮子,且 pixellab 的生成质量(8 方向 + skeleton 动画 + tileset)不是我们能短期复刻的
- **完全不做 asset-lab,用 pixellab 自带预览 + 直接进 cute_pet**:被否决。pixellab 没有场景编排和跨资源交互预览,设计师做完一只 sprite 想看"它在森林背景里叼着骨头"的效果就只能等 cute_pet 工程师介入,迭代速度反而变慢
- **用 Tiled / LDtk 替代 asset-lab**:LDtk 80% 功能(瓦片图层编辑)我们用不上(pixellab 的 create_map 直接出完整背景图);剩下 20%(对象自由放置)自己写更轻、更贴合 vibe-code 工作流
- **用 Flutter Web + Flame 做 asset-lab(框架一致论)**:被否决。设计师装 Flutter SDK + 处理 build_runner + Flutter Web 冷启动 30s 这套门槛与 vibe-code 的 5 秒 iteration 目标冲突;且"框架一致 → 代码可复用"是错觉,真复用只有 ~30 行 SpriteAnimation 切片代码
- **现在就把 _template 重写成 pixellab schema**:被否决。我们手上没有真 pixellab 资源在 cute_pet 里,猜的 schema 还是会再改一次;deferred + 加警告比"现在猜"更稳

## Consequences

- **不在 cute_pet 加任何 asset-lab / pixellab 集成代码** —— asset-lab 是独立 repo,管线分隔严格
- **cute_pet 现有 _template / pixel-foundation.md "Asset 资源约定"被冻结** —— 加了 DEPRECATED 警告,任何 skill / Agent 看到必须停手;真重做与首个 pixellab 资源进入是同一个原子动作
- **module-gen / test-gen 等 skill 不需要改** —— 它们生成的是 lib/features/ 代码,不碰 assets/;只是它们若读 _template/ 里的 manifest schema 来推断 loader 形状会错,所以 _template/README.md 顶部警告必须保留到真重做完成
- **未来 game_meta.json schema 需要单独的 ADR**(或并入下一份"通用 sprite loader" TechPack)—— 字段细节随首个真 sprite 接入定稿
- **设计师工作流跨 3 个工具**(pixellab + Claude Code + asset-lab)—— 但 git 是统一交付物,cute_pet 工程师只看 git,不需要关心设计师怎么协作
- **pixellab 团队订阅($50/mo Tier 3)是依赖** —— 失去订阅 = 设计师无法生成新资源,但已生成的资源(在 git 里)不受影响
