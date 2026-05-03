---
id: ADR-006
title: 拆分像素底座文档与 app 架构文档
date: 2026-05-03
status: Accepted
---

## Context

cute_pixel 是用户做的第一个像素风 Flutter+GetX+Flame app,计划之二是将这套底座 fork 出去做下一个像素 app(种菜、养鱼、小镇 demo 等)。原 architecture.md 把"通用 Flutter+GetX 模块化约定"和"像素风/Flame 专属契约"(Flame 位置、Controller↔Game 同步、sprite manifest schema)混在一起,fork 时无法干净切走 —— 后者其实是底座的核心,不该埋在某一个 app 的架构文档里。

## Decision

doc 三层化:**architecture.md**(通用 Flutter+GetX 模块化:顶层目录、Module-First Flat、4 条铁律、core/shared、后端契约)/ **pixel-foundation.md**(像素底座:Flame 集成、sprite 约定、渲染器/像素纯度/输入抽象/资源懒加载)/ **apps/{name}/**(每个 app 专属业务文档,本期不创建)。CLAUDE.md "写代码前必读" 顺序为 architecture → pixel-foundation → conventions。

## Alternatives Considered

- **全部留在 architecture.md**:被否决。fork 出非像素项目时仍要带走 Flame 与 sprite 章节才能读懂 Module-First Flat 的引用,反过来 fork 出像素项目时也无法只复用底座章节。
- **拆成多文件但都写进 architecture/**:被否决。doc 顶层平铺更易索引,新文件名 `pixel-foundation.md` 自带语义。

## Consequences

- 目前 cute_pixel 仓库内只有 cute_pet(features/pet/) 一个 demo app,两份文档互相引用(相对 markdown link)。
- 未来 fork 像素 app 时,architecture + pixel-foundation + conventions + core/ + shared/ + lib/app/ 骨架可整体复用,只删 features/ 与 assets/{namespace}/ 重建。
- 未来 fork 非像素 Flutter+GetX app 时,只带走 architecture + conventions,pixel-foundation 不带。
- 三个 cute-pixel-* skill 不动(skill 运行时读文档,文档拆分对其透明)。
