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
make analyze             # check-arch + flutter analyze
make test                # 跑全部测试
make eval-skills         # 验证 cute-pixel-* skills 没漂出架构
make run [DEVICE=<id>]   # flutter run
```

## Agent 协作

仓库带 `cute-pixel-*` 系列 skill 在 `.claude/skills/`:

- `/cute-pixel-status` — 看当前项目什么状态
- `/cute-pixel-module-gen` — 起个新业务模块(`cp lib/features/_template/` + sed)
- `/cute-pixel-review` — 架构与可读性审核(只报告,不改)
- `/cute-pixel-test-gen` — 按 conventions §7 四层金字塔补测试

每个 skill 启动时**重新读** architecture/conventions/CLAUDE.md,规范变了改文档就够,skill 不动。

## Fork 出新像素 app 的快路径

1. `git clone` 到新名字 / 改 `pubspec.yaml` 的 `name:` / 改所有 `package:cute_pixel/` 引用
2. 删 `lib/features/pet/`(或保留作为参考)
3. 改 `assets/{namespace}/`(`pets/` → 你的 `plants/` 或 `fishes/`)
4. 用 `/cute-pixel-module-gen` 起你的第一个业务模块

剩下就靠 [doc/pixel-foundation.md](doc/pixel-foundation.md) + 4 条铁律 + `make analyze` 一路兜住。
