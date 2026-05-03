---
name: cute-pixel-status
description: >
  cute_pixel 系列项目状态速查 Skill,适用于基于 cute_pixel 底座的项目。
  Agent 接手或人类回到一段时间没碰的项目时,**第一句话就该用它**——比 grep 整个 lib/ 快十倍,且不会漏。
  **任何"项目当前情况"问题都先走此 Skill**,不要凭记忆或盲 grep 答。
  触发场景包括:用户说 /cute-pixel-status、"现在项目什么状态"、"先看一眼"、
  "有哪些模块"、"core 服务有哪些可以用"、"测试覆盖到哪儿了"、
  "接手这个项目要先看什么"、"项目概况"、"项目结构"、"现在做到哪了"、
  "进度"、"哪些功能上了"、"看 manifest"、"show project status"等。
  本 Skill **只读、不修改**任何文件,纯粹回答"当前是什么状态"。
---

# cute-pixel-status

回答"现在项目是什么状态"的只读 Skill。读 [lib/_manifest.yaml](../../../lib/_manifest.yaml) 一份文件即可,不需要 grep 整个仓库。

## 工作流程

### Step 1 — 读 manifest

读 lib/_manifest.yaml(repo 根)(单一 ground truth)。

如果该文件不存在,告诉用户"项目没有 _manifest.yaml,可能不是 cute-pixel 系列项目,或还没初始化",停下问。

### Step 2 — 校验 manifest 与代码事实是否一致(快速版)

不做完整 audit(那是 cute-pixel-review skill 的事),只跑 3 条快查:
- `find lib/features -maxdepth 1 -mindepth 1 -type d` 的模块列表 vs manifest `features:` 的 `name` 列表
- `make test 2>&1 | tail -3` 的总用例数 vs manifest `tests.total`
- `find lib/core -mindepth 2 -name "*.dart" | wc -l` 与 manifest `core_services` 中 status != planned 的数目级是否一致(允许 ±2 误差,只为发现严重漂移)

如果有显著漂移(模块对不上、测试数差 5 个以上、core 文件多/少 3 个以上),**先告诉用户漂移在哪**,再回答原问题(因为后续答案可能基于过时数据)。

### Step 3 — 回答用户问题

按用户具体问题从 manifest 取数据回答:

| 用户问 | 取 manifest 哪段 |
|---|---|
| "有哪些模块" / "现在做到哪儿了" | `features:` |
| "可以用哪些 core 服务" / "AuthService 能用了吗" | `core_services:` 过滤 status |
| "测试覆盖怎么样" | `tests:` + 提示用 `make test-coverage` 看实际数 |
| "接下一步该做什么" | `gaps_to_close:` |
| "看了什么决定" / "为什么用 X" | `decisions:` 摘要,完整理由让用户自己看 ADR |
| "项目读哪个文档" | `docs:` |

### Step 4 — 不做的事

- **不修改任何文件**(包括 _manifest.yaml 自己——那由 module-gen / 接 core 服务时同步更新)
- **不替代 cute-pixel-review**(本 skill 只回答"是什么",不回答"哪儿写错了")
- **不执行 module-gen / test-gen**(用户要做事让他们显式调那些 skill)
- **不主动建议下一步要做什么**(除非用户直接问)
- **不 grep 大量代码**(2-3 条快查就够;真要审核漂移引导用户用 cute-pixel-review)

## 维护纪律

`lib/_manifest.yaml` 由这些事件触发更新(各 skill 自己负责):
- `cute-pixel-module-gen` 完成 → 在 `features:` 加新模块
- 把 core 服务从 planned 升到 in-use → 改 `core_services:` 对应项 status
- 写新 ADR → 在 `decisions:` 加摘要行
- `gaps_to_close:` 中某个 need 完成 → 整条删除

如果发现 manifest 长期不一致(比如几次 module-gen 后没人更新),用 cute-pixel-review 跑一次,把"manifest 漂移"作为 finding 报给用户,不要自己悄悄改。
