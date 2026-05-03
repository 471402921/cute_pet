# cute_pixel

像素风(pixel-art)移动端应用的 **Flutter + GetX + Flame 通用底座**。一份骨架,可以 fork 出多个像素风 app(养宠物、种菜、养鱼、小镇 demo……)。

仓库内置 **cute_pet**([lib/features/pet/](lib/features/pet/))作为首个 demo app。

## 这个底座解决什么

像素风 app 的常见需求往往会被低估:
- **像素纯度**(关掉双线性插值、整数缩放、bitmap 字体)
- **游戏循环**(宠物每 5 分钟饿一点 / 植物每小时长一格,需要全局 tick)
- **存档版本化**(更新 schema 不能搞坏老用户存档)
- **跨平台 input**(手机 tap、web 鼠标、键盘)
- **Flame 与 Flutter UI 共存**(Flame Component 不能持有业务状态,得让 GetX controller 当真理)

cute_pixel 把这些一次性约定好,新项目按 [doc/pixel-foundation.md](doc/pixel-foundation.md) 起手。

## 架构纲领(铁律,违反就是设计错)

详细见 [doc/architecture.md](doc/architecture.md):

1. `features/A/` 内任何 import 都不能跨到 `features/B/`(模块自治)
2. 跨模块共享只放 `core/` 或 `shared/`(共享单点)
3. 依赖严格单向:`features/* → core/* + shared/* → 外部包`(单向依赖)
4. 文件名遵守 `{module}_*.dart`(命名一致,Agent 看名字就懂职责)

`make check-arch` 机械检查这 4 条,串在 `make analyze` 里,提交前必跑。

## 文档地图

| 文件 | 干啥的 |
|---|---|
| [CLAUDE.md](CLAUDE.md) | 项目入口 + 命令清单(给 AI 也给人) |
| [doc/architecture.md](doc/architecture.md) | 通用 Flutter+GetX 模块架构 |
| [doc/pixel-foundation.md](doc/pixel-foundation.md) | 像素底座专属(Flame、sprite、渲染器、像素纯度、输入、懒加载) |
| [doc/conventions.md](doc/conventions.md) | 12 节编码标准(错误/i18n/测试/路由/freezed/时间存档…) |
| [doc/decisions/](doc/decisions/) | ADR 体系(每个非显然决策的理由,详见 [doc/decisions/README.md](doc/decisions/README.md)) |
| [lib/_manifest.yaml](lib/_manifest.yaml) | 项目状态机器可读索引(Agent 接手第一句话该读它) |

## 快速命令(走 Makefile,国内 pub 镜像已绑死)

```bash
make get                 # flutter pub get
make codegen             # build_runner 生成 *.freezed.dart / *.g.dart
make analyze             # check-all + flutter analyze
make check-all           # check-arch + check-assets + check-arb-sync(三守门)
make test                # 跑全部测试
make eval-skills         # 验证 cute-pixel-* skills 没漂出架构
make run [DEVICE=<id>]   # flutter run
```

## Agent 协作

仓库带 `cute-pixel-*` 系列 skill 在 `.claude/skills/`,**features 与 core 双轨流水线**:

```
features:  /cute-pixel-doc-prd → /cute-pixel-doc-techpack → /cute-pixel-module-gen → /cute-pixel-test-gen
core 服务: ADR(doc/decisions/) → /cute-pixel-doc-techpack core/X → 手工实装 → /cute-pixel-review core/X
```

- `/cute-pixel-status` — 看当前项目什么状态(读 `lib/_manifest.yaml`)
- `/cute-pixel-doc-prd` — 写 PRD-Lite(8 节,含 Figma 链接槽)
- `/cute-pixel-doc-techpack` — 写 TechPack;features 模式门禁 PRD 定稿,core 模式门禁 ADR 存在
- `/cute-pixel-module-gen` — 起新业务模块(`cp lib/features/_template/` + sed)
- `/cute-pixel-test-gen` — 按 conventions §7 四层金字塔 + PRD §7 AC 写测试
- `/cute-pixel-review` — 架构与可读性审核(任意路径,只报告)

每个 skill 启动时**重新读** architecture/conventions/CLAUDE.md,规范变了改文档就够,skill 不动。详细决策见 [doc/decisions/ADR-009](doc/decisions/ADR-009-spec-driven-with-strong-gates.md)。

## Fork 出新像素 app 的快路径

```bash
git clone https://github.com/471402921/cute_pixel.git my_new_app
cd my_new_app
bash tools/fork_rename.sh NEW_NAME=tomato_garden STRIP_PET=1
```

`fork_rename.sh` 7 步:改 `pubspec.yaml.name` → 全局 `package:cute_pixel/` import → `CutePixelApp` 类名 → 重置 ARB `appTitle` → 可选删 `features/pet/` → 重置 `_manifest.yaml` → 跑 `make check-all + analyze + test`。脚本本身写明了它**不**做的几件事(填 ARB 真值、清 git history 等)和已知雷区。

第一次 fork 跑下来踩到的新坑,反向 PR 回 `tools/fork_rename.sh`——这个脚本本身就是 fork 经验的存活点。

剩下就靠 [doc/pixel-foundation.md](doc/pixel-foundation.md) + 4 条铁律 + `make analyze` 一路兜住。
