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
| `cute-pixel-doc-prd` | 无 | (features 流程起点) |
| `cute-pixel-doc-techpack` (features 模式) | **强** | PRD 文件存在 + 状态 = 已定稿 |
| `cute-pixel-doc-techpack` (core 模式) | **强** | 对应 ADR 文件存在(无 PRD,因 core 无业务面) |
| `cute-pixel-module-gen` | **强** | PRD + TechPack 都存在 + 都已定稿 |
| `cute-pixel-test-gen` | **强** | PRD §7 验收标准存在(状态 = 已定稿) |
| `cute-pixel-review` | 软 | features 路径看 PRD+TechPack;core 路径看 ADR+core TechPack;无则报告里标"无对照" |
| `cute-pixel-status` | 无 | 只读 |

**features 与 core 的双轨流程**:

```
features 流程:  doc-prd → doc-techpack(features) → module-gen(cp+sed) → test-gen
core 流程:      ADR     → doc-techpack(core)     → 手工实装             → review
```

为什么 core 流程没有 module-gen:core 服务太异构(NetworkClient ≠ SaveStore ≠ AuthService),没有可复用模板能 cp+sed。手工实装 + review 兜底就够。

为什么 core 用 ADR 替代 PRD:core 服务无业务面,不存在产品需求;但**任何 core 服务的引入都是架构决策**,必须有 ADR 锁住"为什么、用哪个包、什么权衡"。ADR 兼任 spec gate,零成本复用已有体系。

**例外路径**:用户显式 `skip-spec: <原因>`(prototype/学习/throwaway demo)允许通过,但 reason 必须落进生成的 binding 注释/test 文件头/TechPack 头部,留 audit trail。

PRD 模板加 §0 设计参考(Figma 链接槽,可 TBD 但不能删节)— 提前为团队协作布局。

TechPack 模板对齐 Module-First Flat,**不**写后端 SQL/API 设计,**不**做分期策略。core TechPack 单独一份模板(`techpack-core-template.md`),结构平行但内容针对基础设施。

## Alternatives Considered

- **沿用 doc/README.md 文字约定不加技术门禁**:被否决。文字约定 Agent 可以"忘记",真实跑起来漂移 100%。
- **TechPack 设软门禁(按复杂度判断是否要)**:用户原话"techpack也用强门禁,没有prd就不行"——前端流程要稳要严,留一个统一的强门禁(TechPack 无 PRD 不开工)+ skip-spec 例外,比按复杂度软判断更不容易破。
- **和后端 spec_flow 同等重(8 节 PRD + 多批次 TechPack)**:被否决。前端业务无 DB/事务/多服务联动,搬过来全是空壳层。

## Consequences

- 任何"凭空起手写代码"的请求,skill 会拒绝并引导到 doc-prd / doc-techpack(features)或 ADR / doc-techpack core 模式(core 服务)
- PRD 模板 §0 永远预留 Figma 链接槽,即使现在还没有设计师协作也不删
- skip-spec 例外只在用户**显式说**且原因写明时才放行,留可审计的尾巴
- review skill 在有 spec 的情况下会多审一节"D. spec 一致性"(features:§3 MUST 是否实现 / §7 AC 是否覆盖测试;core:ADR 锁定的约束/§2.2 依赖/§4 DI 是否在代码里真落地)
- doc-prd / doc-techpack 两个新 skill 自身**不**做门禁(prd 是流程起点,techpack 已门禁 PRD 或 ADR),不嵌套
- core 服务首次实装(network/auth/env/logging 等)走 core 模式 doc-techpack,而非 module-gen——module-gen 只服务 features/(features 内部高度同构,有 cp+sed 模板;core 异构,模板不可能)
