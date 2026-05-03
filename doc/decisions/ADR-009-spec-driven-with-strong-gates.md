---
id: ADR-009
title: Spec-driven 强门禁 (PRD → TechPack → 代码)
date: 2026-05-03
status: Accepted
---

## Context

cute_pixel 早期可以靠"对话里描述模块"直接生成代码,但项目升级为通用底座后,这种工作流问题暴露:Agent 容易"按对话临时凑",不同 session/不同模型(包括便宜模型)产出会漂;PRD/TechPack 流程虽然写在 doc/README.md 里,但 skill 不强制,执行起来形同虚设。参考 spec_flow 的四阶段 SOP,但前端不需要后端那么重(无权限矩阵、无分期策略、无 DB schema)。

## Decision

每个 cute-pixel-* skill 在执行入口加 **Step 0 Spec 门禁**,门禁强度按角色分:

| Skill | 门禁 | 必须的输入 |
|---|---|---|
| `cute-pixel-doc-prd` | 无 | (流程起点) |
| `cute-pixel-doc-techpack` | **强** | PRD 文件存在 + 状态 = 已定稿 |
| `cute-pixel-module-gen` | **强** | PRD + TechPack 都存在 + 都已定稿 |
| `cute-pixel-test-gen` | **强** | PRD §7 验收标准存在(状态 = 已定稿) |
| `cute-pixel-review` | 软 | spec 存在则用作对照,不存在则报告里标"无对照" |
| `cute-pixel-status` | 无 | 只读 |

**例外路径**:用户显式 `skip-spec: <原因>`(prototype/学习/throwaway demo)允许通过,但 reason 必须落进生成的 binding 注释/test 文件头,留 audit trail。

PRD 模板加 §0 设计参考(Figma 链接槽,可 TBD 但不能删节)— 提前为团队协作布局。

TechPack 模板对齐 Module-First Flat,**不**写后端 SQL/API 设计,**不**做分期策略。

## Alternatives Considered

- **沿用 doc/README.md 文字约定不加技术门禁**:被否决。文字约定 Agent 可以"忘记",真实跑起来漂移 100%。
- **TechPack 设软门禁(按复杂度判断是否要)**:用户原话"techpack也用强门禁,没有prd就不行"——前端流程要稳要严,留一个统一的强门禁(TechPack 无 PRD 不开工)+ skip-spec 例外,比按复杂度软判断更不容易破。
- **和后端 spec_flow 同等重(8 节 PRD + 多批次 TechPack)**:被否决。前端业务无 DB/事务/多服务联动,搬过来全是空壳层。

## Consequences

- 任何"凭空起手写代码"的请求,skill 会拒绝并引导到 doc-prd / doc-techpack
- PRD 模板 §0 永远预留 Figma 链接槽,即使现在还没有设计师协作也不删
- skip-spec 例外只在用户**显式说**且原因写明时才放行,留可审计的尾巴
- review skill 在有 spec 的情况下会多审一节"D. spec 一致性"(§3 MUST 是否实现 / §7 AC 是否覆盖测试)
- doc-prd / doc-techpack 两个新 skill 自身**不**做门禁(prd 是流程起点,techpack 已门禁 PRD),不嵌套
