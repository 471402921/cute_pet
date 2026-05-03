# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

本文件给 Claude Code(claude.ai/code)在 cute_pixel 仓库工作时提供入口指引。

## 项目是什么

cute_pixel 是像素风 Flutter + GetX + Flame **通用底座**,内置 cute_pet(features/pet/)作为首个 demo app。Flame 用于需要游戏化/动画化的模块(目前是 [features/pet/](lib/features/pet/));新模块按需可用,但只在该模块内部用,不外溢到其它 feature 或 `core/` `shared/`。

## 写代码前必读(顺序)

1. [doc/architecture.md](doc/architecture.md) — 通用 Flutter+GetX 模块边界、4 条铁律、core/shared 边界、后端契约
2. [doc/pixel-foundation.md](doc/pixel-foundation.md) — 像素底座专属(Flame 集成、sprite 契约、渲染器/像素纯度/输入抽象/资源懒加载)
3. [doc/conventions.md](doc/conventions.md) — 12 条编码标准(P0:错误/环境/认证/i18n/日志/lint/测试;P1:路由/状态/JSON/跨模块/时间存档)
4. [doc/decisions/](doc/decisions/) — ADR 体系(8 条,记录每个非显然技术决策的理由)
5. [doc/README.md](doc/README.md) — `prd/` 与 `design/` 的写作流程

(根目录 [README.md](README.md) 是 cute_pixel 项目对外简介,不是 Claude 入口。先看本文件。)

**Agent 接手前先读 [lib/_manifest.yaml](lib/_manifest.yaml)** 看当前模块/服务/测试状态——比 grep 整个 lib/ 快十倍且不会漏。或调用 `/cute-pixel-status` skill。

**铁律(违反就是设计错)**:
1. `features/A/` 不得 import `features/B/`
2. 跨模块共享只放 `core/` 或 `shared/`
3. 依赖严格单向:`features/* → core/* + shared/* → 外部包`
4. 文件名遵守 `{module}_*.dart` 约定

## 命令(必须走 Makefile,不要直接 flutter pub)

国内网络下 pub.dev 不可达,Makefile 把镜像变量(`pub.flutter-io.cn` / `storage.flutter-io.cn`)绑死在常用 flutter 命令上。`make` 看完整列表。

```bash
make get                 # flutter pub get
make add PKG=<name>      # flutter pub add <name>     (DEV=1 / SDK=flutter 可选)
make codegen             # build_runner 一次性生成 *.freezed.dart / *.g.dart
make codegen-watch       # build_runner 持续监听
make run [DEVICE=<id>]   # flutter run(多设备时必传 DEVICE)
make analyze             # check-arch + flutter analyze(必须 0 issue / 0 violation)
make check-arch          # 4 条铁律机械检查(已串进 analyze,也可单独跑)
make eval-skills         # cute-pixel-* skill 漂移自检(改 skill 或架构后跑一次)
make fmt-check           # dart format --set-exit-if-changed
make test                # flutter test
make test-coverage       # flutter test --coverage
# 跑单个测试文件(Makefile 没包,直接走 flutter):
#   flutter test test/features/pet/pet_controller_test.dart
```

任何要联网拉 pub 包的命令**都走 make target**。Makefile 里没的就**先扩展 Makefile**,不要绕过。

## 关键技术选型

- **状态管理** GetX(`Get.lazyPut` 三件套:binding + controller + page)
- **数据建模** freezed + json_serializable(`abstract class X with _$X` 是 freezed 3.x 必须)
- **错误** sealed `Failure` 体系在 [lib/core/error/failures.dart](lib/core/error/failures.dart)
- **状态视图** `ViewState<T>` + `StateViewBuilder`(loading/empty/error/data 统一展示)
- **i18n** `gen-l10n` + zh/en 双语 ARB 同步维护(`lib/l10n/`)
- **Flame** 用于游戏化/动画模块(参考 [lib/features/pet/](lib/features/pet/)),Component 不持有业务状态,业务状态在 controller
- **Lint 严格度** [analysis_options.yaml](analysis_options.yaml) 开了 `strict-casts/inference/raw-types`,`avoid_print` 是 error 不是 warning;改完代码先跑 `make analyze`

## 模块结构(Module-First Flat)

顶层布局:
- [lib/app/](lib/app/) — 路由表、主题、全局 binding(改路由就在这里)
- [lib/core/](lib/core/) — 基础设施:`error/`(in-use)、`time/GameClock`(scaffolded)、`storage/save_store/`(scaffolded);`network/` `auth/` `env/` `logging/` `utils/` 仍 planned
- [lib/shared/](lib/shared/) — 跨模块复用:`widgets/StateViewBuilder`、`route_args/{module}_route_args.dart`(路由参数统一住这,避免 features 互引)
- [lib/features/](lib/features/) — 业务模块,内部按下面 flat 结构;`_template/` 是模板源(给 module-gen skill 用,不是真业务)

```
features/{module}/
├── {module}_page.dart         Scaffold + widget 组合,只组合不写业务
├── {module}_controller.dart   GetxController,业务状态唯一真理
├── {module}_binding.dart      Get.lazyPut 注入
├── {module}_models.dart       数据类 + enum(纯 Dart,freezed)
├── {module}_api.dart          后端调用
└── widgets/                   模块内私有 widget
```

参考样板:[lib/features/pet/](lib/features/pet/)。

**路由参数**`{module}_route_args.dart` 不在模块内,统一放 [lib/shared/route_args/](lib/shared/route_args/)(跨模块契约,避免 features 互引)。

## 可用 Skills(项目本地 `.claude/skills/`)

cute_pixel 用的 skills 命名为 `cute-pixel-*` 一族(对应"像素风 app 通用底座",可在 fork 出去的下一个像素 app 复用):

| Skill | 触发词 | 用途 |
|---|---|---|
| `/cute-pixel-status` | "现在项目什么状态" / "先看一眼" | 读 [lib/_manifest.yaml](lib/_manifest.yaml) 回答模块/服务/测试当前状态(只读) |
| `/cute-pixel-module-gen` | "新建模块 X" / "起个 X feature" | `cp -r lib/features/_template/` + sed,跑 codegen+analyze+test 验证 |
| `/cute-pixel-review` | "review features/X" / "审一下" | 按 4 条铁律 + 12 条 conventions + ADR 扫违规(只报告) |
| `/cute-pixel-test-gen` | "给 X 写测试" / "补测试" | 按 conventions §7 四层金字塔补测试 |

每个 skill 内部都**运行时读 architecture.md / conventions.md / 本文件**,不抄规范。规范变了改文档就够,skill 不动。

## Skills 调用纪律

- **不跨阶段**:没有 PRD 不应去做 Tech Pack;没有 Tech Pack 不应去 module-gen 一个真业务模块(占位/学习除外)
- **不自动推进**:每个 skill 完成后停下,等用户确认再走下一步
- **稳定优先**:有疑问时停下问,不自行假设业务规则
