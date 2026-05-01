# doc/

cute_pet 项目的文档区。**先写清楚,再动手做东西**。

## 目录约定

| 目录 | 写什么 | 何时写 |
|---|---|---|
| `prd/` | PRD-Lite — 产品要做什么、不做什么、用户是谁、第一版范围 | 任何新功能动代码前 |
| `design/` | Tech Pack — 数据模型、API、状态流、关键技术取舍 | PRD 定稿后,模块开工前 |
| `architecture.md` | 跨模块的架构决定(DDD Light 分层、common 目录约定等) | 一次性写定,有大改时更新 |

## 流程参考(简化自 spec_flow)

```
想法 → prd/{module}.md (聊明白做什么)
     → design/{module}.md (聊明白怎么做)
     → 写代码(features/{module}/)
     → review (人工或后续 skill)
```

不跨阶段:没有定稿 PRD 不写 Tech Pack,没有定稿 Tech Pack 不写代码。
不自动推进:每阶段完成后,人工确认才进入下一阶段。

## 命名

- `prd/{NN}-{module}.md` — 编号方便排序,例如 `01-pet-profile.md`
- `design/{NN}-{module}.md` — 与 PRD 一一对应
- 中文写正文,英文写技术名词
