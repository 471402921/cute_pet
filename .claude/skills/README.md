# `.claude/skills/` — cute-pixel-* skill 套件

cute_pixel 项目的本地 Claude Code skill 集合,命名 `cute-pixel-*`。任何基于 cute_pixel 底座 fork 出去的项目(种菜/养鱼/小镇 demo……)直接复用这套 skill,不用重写。

## Spec → 代码 流水线(每步强门禁)

```
/cute-pixel-doc-prd → /cute-pixel-doc-techpack → /cute-pixel-module-gen → /cute-pixel-test-gen
   (起点,无门禁)        (PRD 必须定稿)              (PRD+TechPack 都定稿)     (PRD §7 AC 必须定稿)
                                                                                     ↓
                                                                        /cute-pixel-review (软门禁)
```

详细决策见 [doc/decisions/ADR-009](../../doc/decisions/ADR-009-spec-driven-with-strong-gates.md)。

## Skill 清单

| Skill | 门禁 | 一句话用途 | 入口 |
|---|---|---|---|
| `cute-pixel-status` | 无 | 读 `lib/_manifest.yaml` 回答"项目当前是什么状态"(Agent 接手第一句话该用) | [SKILL.md](cute-pixel-status/SKILL.md) |
| `cute-pixel-doc-prd` | 无 | 写 PRD-Lite(8 节,含 Figma 链接槽),产 `doc/prd/{NN}-{module}.md` | [SKILL.md](cute-pixel-doc-prd/SKILL.md) |
| `cute-pixel-doc-techpack` | PRD 定稿 | 写 TechPack(6 节,对齐 Module-First Flat),产 `doc/design/{NN}-{module}.md` | [SKILL.md](cute-pixel-doc-techpack/SKILL.md) |
| `cute-pixel-module-gen` | PRD + TechPack 定稿 | `cp -r lib/features/_template/` + sed 起新模块 | [SKILL.md](cute-pixel-module-gen/SKILL.md) |
| `cute-pixel-test-gen` | PRD §7 AC 定稿 | 按 conventions §7 四层金字塔 + AC 写测试 | [SKILL.md](cute-pixel-test-gen/SKILL.md) |
| `cute-pixel-review` | 软(有 spec 则做对照) | 4 条铁律 + 12 条 conventions + spec 一致性,**只报告** | [SKILL.md](cute-pixel-review/SKILL.md) |

**例外**:用户显式 `skip-spec: <原因>` 可越任何强门禁(prototype/throwaway 用),原因落进生成代码的 binding 注释做 audit trail。

## 目录约定

每个 skill 一个文件夹,**自治**:

```
cute-pixel-{name}/
├── SKILL.md           ← 唯一入口,frontmatter (name + description) 决定触发,markdown 正文是给 Agent 读的指令
└── references/        ← 模板/详细信号/template,SKILL.md 按需引用(progressive disclosure)
    └── *.md
```

**模板必须在 skill 自带的 `references/` 里**——历史上把 `prd-template.md` / `techpack-template.md` 放过 `doc/{prd,design}/_TEMPLATE.md`,造成"两份事实"漂移风险,已迁回 references/(见 commit `4ab3b3f`)。

## 维护纪律

| 触发事件 | 要做的事 |
|---|---|
| 改了 architecture.md / conventions.md / pixel-foundation.md | 不用动 skill —— skill 启动时**重新读** doc,自动跟随 |
| 改了某个 SKILL.md 或 references/ 里的模板 | 跑 `make eval-skills` 验证没漂(检查 `_template/` ground truth + cp+sed flow + frontmatter 一致性) |
| 加新 cute-pixel-* skill | ① SKILL.md 框架(name + 推式 description + 必读文档 + Step 0 门禁/无门禁说明 + 工作流程) ② 在 [CLAUDE.md "可用 Skills" 表](../../CLAUDE.md) 加一行 ③ `make eval-skills` 跑一遍 |
| 接入新 core/* 服务,从 planned 升 in-use | 改 [lib/_manifest.yaml](../../lib/_manifest.yaml) 的 `core_services:` Status |
| 完成一次 `module-gen` | skill 自己负责更新 `_manifest.yaml` 的 `features:` 列表 |

## 不在这里

- `cute-pet-*` 系列 skill 已重命名为 `cute-pixel-*`(2026-05-03,见 commit `c207510`)。legacy `/cute-pet-*` 触发词在每个 SKILL.md frontmatter 里仍保留,可以无缝过渡。
- 全局 Claude Code skill(如 `skill-creator`、`update-config`、`lark-*`、`pdf` 等)不在本仓库,在 `~/.claude/skills/`。

## 起新像素 app 的 fork 流程

1. `git clone https://github.com/471402921/cute_pixel.git my_new_app/`
2. 改 `pubspec.yaml` 的 `name:` + 全局替 `package:cute_pixel/` import
3. 删 `lib/features/pet/`(或保留作为参考 demo)
4. `/cute-pixel-doc-prd <module>` 起第一个业务模块 PRD
5. 后面照流水线走

整套 `.claude/skills/` + `tools/` + `doc/{architecture,conventions,pixel-foundation,decisions}/` 都是底座,跨 app 直接复用。
