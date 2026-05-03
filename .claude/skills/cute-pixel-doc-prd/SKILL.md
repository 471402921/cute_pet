---
name: cute-pixel-doc-prd
description: >
  cute_pixel 项目的 PRD-Lite 编写 Skill,前端轻量版(参考 spec_flow 但去掉权限矩阵/分期等后端重物)。
  适用于 cute_pet 等基于此底座的项目。
  当用户要新建/补全/审核 PRD 时使用此 Skill。
  触发场景包括:用户说 /cute-pixel-doc-prd、"写 PRD"、"新建 PRD <模块>"、"补全 PRD"、"审核 PRD"、
  "create PRD"、"PRD 草稿"、"出个产品需求"等。
  本 Skill 产出 doc/prd/{NN}-{module}.md,严格按 doc/prd/_TEMPLATE.md 的 8 节结构 + Figma 链接槽。
  PRD 是后续 cute-pixel-doc-techpack / module-gen / test-gen 的强门禁前置。
---

# cute-pixel-doc-prd

按 [doc/prd/_TEMPLATE.md](../../../doc/prd/_TEMPLATE.md) 的标准结构编写 PRD-Lite,产出 `doc/prd/{NN}-{module}.md`。

## 必读文档

每次执行**重新读**:

1. [doc/README.md](../../../doc/README.md) — PRD/TechPack/code 三阶段流程 + 命名约定
2. [doc/prd/_TEMPLATE.md](../../../doc/prd/_TEMPLATE.md) — 8 节模板(含 §0 Figma 链接槽,**必填或留 TBD**)

## 工作流程

### Step 1 — 收集输入(不清楚就停下问)

- **模块名**(snake_case,与未来 `lib/features/{module}/` 对应)
- **一两句业务描述**(给谁用 / 解决什么 / 不解决什么)
- **Figma 文件 URL + 关键 frame URL**(若没有,显式标 TBD,不要跳过 §0)
- **是否参考已有 PRD 改写**(yes → 读那份后做 diff;no → 走从零模式)

### Step 2 — 自动定 NN 编号

```bash
ls doc/prd/ | grep -E '^[0-9]{2}-' | sed 's/-.*//' | sort -n | tail -1
```

最大现有 NN + 1 = 本次的 NN(零填充两位)。如果 `doc/prd/{NN}-{module}.md` 已存在,**停下问**用户是否覆盖。

### Step 3 — 按模板生成初稿,逐节确认

按 [_TEMPLATE.md](../../../doc/prd/_TEMPLATE.md) 8 节顺序生成,**每节生成后停下让用户确认**:

| 节 | 重点 |
|---|---|
| §0 设计参考 | Figma 链接(粘贴用户给的 URL,没有就 TBD) |
| §1 一句话概述 | 50 字内,给谁/解决什么 |
| §2 用户与场景 | 目标用户 + 核心场景 + 不服务的明确划掉 |
| §3 第一版范围 | MUST/SHOULD/WON'T 三段,WON'T 必填(防需求蔓延) |
| §4 关键业务规则 | 模型猜不出的:权限、状态机、数据约束、特殊例外 |
| §5 数据(高层) | 业务实体 + 关系,**不写表结构**(那是 TechPack 的事) |
| §6 用户旅程(可选) | 1-2 个关键路径的步骤 |
| §7 验收标准 | "给定...当...则..." 句式,每条可验证 |
| §8 已知风险与待定 | 留白比硬编不切实际的细节强 |

**不允许**:
- 写技术实现(那是 TechPack)
- 写后端字段表/SQL(那是后端 PRD/TechPack,本项目纯前端)
- 在 §3 留 TBD(MUST/SHOULD/WON'T 必须明确,不知道就停下问)
- 跳过 §0 Figma 槽(没有 Figma 标 TBD,不要删节)

### Step 4 — 输出文件 + 设状态

- 写入 `doc/prd/{NN}-{module}.md`
- 文末 `**状态**:` 默认 = `草稿`(只有用户明说"定稿这版"才改成 `已定稿`)
- `**最后修改**:` 填今天的 YYYY-MM-DD

### Step 5 — 报告 + 下一步建议

告诉用户:
- 创建的文件路径
- §0 Figma 是否完整(全 URL / 部分 TBD / 全 TBD)
- §3 范围摘要(MUST 几条 / WON'T 划掉了什么)
- §7 验收标准条数
- **下一步**:`定稿这版 PRD` → 然后 `/cute-pixel-doc-techpack {module}` 写技术方案

## 不做

- 不写 TechPack(那是 doc-techpack 的事,**本 skill 不跨阶段**)
- 不直接生成代码(必须经 module-gen,且 module-gen 强门禁要求 TechPack)
- 不假设业务规则,有疑问停下问用户
- 不写后端字段/接口设计(本项目 cute_pixel 是纯前端,后端契约在 spec_flow 那边定)
- 不动 lib/ 任何代码,**只**写 doc/prd/
- 不主动调 doc-techpack(用户确认 PRD 定稿后才能进下一阶段)
