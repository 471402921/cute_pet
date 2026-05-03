# doc/

cute_pixel 项目的文档区。**先写清楚,再动手做东西**。

## 目录约定

| 文件/目录 | 写什么 | 何时写/读 |
|---|---|---|
| `architecture.md` | 模块边界、目录结构、4 条铁律、Flame 集成契约、后端契约 | 一次性写定,有大改时更新;**写代码前必读** |
| `conventions.md` | 错误处理、i18n、测试、日志、lint、路由、状态等具体编码标准 | 一次性写定,加新标准时更新;**写代码前必读** |
| `pixel-foundation.md` | 像素底座专属(Flame、sprite、渲染器、像素纯度、输入抽象、资源懒加载) | 起像素 app 必读 |
| `decisions/` | ADR — 非显然技术决策的理由记录(GetX/Flame/freezed/spec-driven 等) | 决策做完就追加 |
| `prd/` | PRD-Lite 产物 — 产品要做什么、不做什么、用户是谁、第一版范围 | 任何新功能动代码前;**模板在** [`.claude/skills/cute-pixel-doc-prd/references/prd-template.md`](../.claude/skills/cute-pixel-doc-prd/references/prd-template.md),通过 `/cute-pixel-doc-prd` skill 生成 |
| `design/` | TechPack 产物 — 模块结构、状态形状、数据流、关键技术取舍 | PRD 定稿后,模块开工前;**模板在** [`.claude/skills/cute-pixel-doc-techpack/references/techpack-template.md`](../.claude/skills/cute-pixel-doc-techpack/references/techpack-template.md),通过 `/cute-pixel-doc-techpack` skill 生成 |

`architecture.md` 与 `conventions.md` 的边界:
- **architecture** 回答 "**什么放哪里**"(结构、契约、不变式)
- **conventions** 回答 "**怎么写**"(标准、模板、禁止项)

## 流程

```
想法 → prd/{NN}-{module}.md (聊明白做什么)
     → design/{NN}-{module}.md (聊明白怎么做)
     → 写代码(features/{module}/, 遵循 architecture + conventions)
     → review (人工或后续 skill)
```

**不跨阶段**:没有定稿 PRD 不写 Tech Pack,没有定稿 Tech Pack 不写代码。**这条由 cute-pixel-* skill 强门禁兜底**(见 [decisions/ADR-009](decisions/ADR-009-spec-driven-with-strong-gates.md))。
**不自动推进**:每阶段完成后,人工确认才进入下一阶段。

## 命名

- `prd/{NN}-{module}.md` — 编号方便排序,例如 `01-pet-profile.md`
- `design/{NN}-{module}.md` — 与 PRD 一一对应
- 中文写正文,英文写技术名词
