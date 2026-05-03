---
name: cute-pixel-module-gen
description: >
  cute_pixel 系列(像素风 Flutter+GetX+Flame 架构)业务模块生成 Skill,适用于基于 cute_pixel 底座的项目。
  当用户要在仓库新建一个业务模块、起个 feature、生成模块脚手架时使用此 Skill。
  触发场景包括:用户说 /cute-pixel-module-gen、/cute-pet-module-gen(legacy)、"新建一个 health 模块"、"起个 family feature"、
  "按规范生成 pet_profile"、"scaffold a new module"、"加个新功能页面"等。
  即使用户没说"生成"二字,只要他们提供了模块名加用途描述并希望产出代码文件,也使用此 Skill。
  本 Skill 同时支持普通 Flutter 模块和需要 Flame 渲染的模块(可选扩展)。
---

# cute-pixel-module-gen

按当前项目的 architecture + conventions 生成一个新业务模块的完整脚手架。**核心策略:cp + sed**——直接拷贝 [lib/features/_template/](../../../lib/features/_template/)(被 lint+test 持续验证的"活模板"),然后机械替换名字。这比按文字模板手写更稳定,Agent 不容易跑偏。

## 必读文档

每次执行**重新读**(不靠记忆,规范以文档为准):

1. [CLAUDE.md](../../../CLAUDE.md) — 项目命令、4 条铁律
2. [doc/architecture.md](../../../doc/architecture.md) — Module-First Flat、命名约定、core/shared 边界
3. [doc/pixel-foundation.md](../../../doc/pixel-foundation.md) — Flame 集成契约(仅 Flame 模块需要)
4. [doc/conventions.md](../../../doc/conventions.md) — 11 节标准,着重 §1 错误、§4 i18n、§7 测试、§8 路由参数、§9 ViewState、§10 freezed、§11 跨模块通信、§12 时间与存档

## 工作流程

### Step 1 — 收集输入

跟用户确认这些,**不清楚就停下问**:

- **模块名**(snake_case,不与已有 `lib/features/*` 冲突;不能是 `_template` 自己)
- **PascalCase 名**(用于类名,默认从 snake_case 推导:`pet_profile` → `PetProfile`)
- **一两句用途描述**(写在用户确认后会进 SKILL 报告里)
- **是否需要后端数据**(yes → 保留 `_api.dart`;否则删掉,controller 直接用本地数据)
- **是否带路由参数**(yes → 在 `lib/shared/route_args/` 建 `{module}_route_args.dart`,**不在模块内**)
- **路由路径**(默认 `/{module}`)
- **是否使用 Flame**(yes → 走 Flame 扩展路径,见 Step 5)
- **用户可见字符串候选**(标题、按钮等,至少标题)

### Step 2 — 拷贝 _template/ 到新模块

```bash
cp -r lib/features/_template lib/features/{module}
cp -r test/features/_template test/features/{module}
```

然后**逐个文件**重命名(`_template_*.dart` → `{module}_*.dart`):

```bash
cd lib/features/{module}
for f in _template_*.dart; do mv "$f" "${f/_template/{module}}"; done
# freezed 产物同样改:_template_models.freezed.dart → {module}_models.freezed.dart
# .g.dart 同理
cd -
# test 同样
cd test/features/{module}
for f in _template_*.dart; do mv "$f" "${f/_template/{module}}"; done
cd -
```

### Step 3 — 内容替换(sed)

每个文件做两次替换:

```bash
# snake_case 的标识符(import 路径、part 指令、文件名引用)
find lib/features/{module} test/features/{module} -name "*.dart" -exec sed -i '' "s/_template/{module}/g" {} \;

# PascalCase 的类名(Template → {Module}PascalCase,例如 PetProfile)
find lib/features/{module} test/features/{module} -name "*.dart" -exec sed -i '' "s/Template/{ModulePascalCase}/g" {} \;
```

**注意**:
- macOS `sed -i ''` 与 Linux `sed -i` 不同;按当前平台调整(开发机是 darwin)
- 别动 `_template_models.freezed.dart` / `_template_models.g.dart`——这些会被 `make codegen` 重生成,先 sed 内容,然后 codegen 会覆盖产物
- 替换后**人眼扫一遍** import 与类名,确保没误改框架字符串(`Template` 是常见词,grep 一下)

### Step 4 — 删掉用不到的文件 + 改 mock 数据

- 不需要后端数据 → 删 `{module}_api.dart`、`test/features/{module}/{module}_api_test.dart`,在 controller 里把 `_TemplateApi()` 替换成本地构造
- 不需要数据模型 → 删 `{module}_models.dart` 与产物,改 controller 不依赖模型(罕见,通常都需要)
- 改 mock 数据为符合本模块语义的占位(`TemplateItem(id: '1', name: 'placeholder')` → 真实业务对象)

### Step 5 — Flame 扩展(仅当 Step 1 选了 Flame)

如果模块要用 Flame:
- 额外读 [doc/pixel-foundation.md](../../../doc/pixel-foundation.md) "Flame 的位置" 与 "Controller ↔ Flame Game 同步契约"
- 参考 [lib/features/pet/](../../../lib/features/pet/) 加 `{module}_game.dart` + `components/{module}_component.dart`
- Flame Component **只负责渲染**,业务状态留在 controller(铁律)

### Step 6 — 路由参数(仅当 Step 1 选了路由参数)

在 `lib/shared/route_args/{module}_route_args.dart` 创建:

```dart
class {Module}RouteArgs {
  const {Module}RouteArgs({this.someId});
  final String? someId;
}
```

page 第一行:`final args = Get.arguments as {Module}RouteArgs;`(conventions §8)

### Step 7 — 加 l10n key(zh + en 同步)

在 `lib/l10n/app_zh.arb` 与 `lib/l10n/app_en.arb` **两份都加**所有 `{module}*` key。**只加一边算违规**(conventions §4)。命名 `{module}{Concept}` 小驼峰。

`_template` 已有的 `templateTitle / templateEmpty / templateRetry` 三个 key 是给模板用的,新模块**不要**复用这些 key,加自己的(`{module}Title` 等)。

### Step 8 — 注册路由

- `lib/app/app_routes.dart`:加 `static const {module} = '/{module}';`
- `lib/app/app_pages.dart`:加 `GetPage(name:..., page:..., binding:...)` 并 import

### Step 9 — 验证

按顺序跑,任一步失败**停下报告**,不自动修:

```bash
make codegen      # 重新生成 .freezed.dart / .g.dart(对新模块名)
make fmt
make analyze      # 包含 check-arch + flutter analyze,必须 0 issue / 0 violation
make test         # 必须全过(模板自带的 3 个测试改名后应继续过)
```

### Step 10 — 报告

告诉用户:
- 创建了哪些文件(分组列出 lib + test + ARB + 路由两处 + 可选的 route_args)
- analyze + test 结果
- 下一步建议:改 mock 数据 / 实现具体方法 / 接后端

**不主动**调用 review 或 test-gen。

## 为什么 cp + sed 而不是按模板手写

- **稳定性**:`_template/` 被 `make analyze` + `make test` 持续验证,任何架构升级会先打到模板,skill 自动跟进。
- **Agent 友好**:模型只做机械替换不创造内容,出错率显著低于按文字模板逐字写。
- **真实性**:模板是真编译的代码,不会出现"模板里写了 import 但实际类不存在"这种文档腐烂。

[references/module-templates.md](references/module-templates.md) 与 [references/flame-extension.md](references/flame-extension.md) 仍保留,作为**说明文档**(每个文件为什么这么写)而非生成模板。

## 不做

- 不动 `core/` `shared/` `app/` 之外的全局文件(除路由两处与 `shared/route_args/` 可选)
- 不引入新依赖(`make add` 是用户决定)
- 不自动 commit
- 不写 PRD / Tech Pack(那是 doc-prd / doc-techpack 的事,本 skill 不跨阶段)
- 不复用 `_template` 已有的 ARB key(那些只给模板用)
