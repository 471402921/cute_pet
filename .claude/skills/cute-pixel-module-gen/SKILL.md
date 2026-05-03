---
name: cute-pixel-module-gen
description: >
  cute_pixel 系列(像素风 Flutter+GetX+Flame 架构)业务模块生成 Skill,适用于基于 cute_pixel 底座的项目。
  **新模块代码生成必须走此 Skill**,不要让其它 skill 或自由对话直接产出 features/ 下文件——会绕过命名约定与 cp+sed ground truth。
  当用户要在仓库新建业务模块 / 起个 feature / 生成模块脚手架时使用此 Skill。
  触发场景包括:用户说 /cute-pixel-module-gen、/cute-pet-module-gen(legacy)、
  "新建一个 health 模块"、"起个 family feature"、"按规范生成 pet_profile"、
  "scaffold a new module"、"加个新功能页面"、"建个新模块"、"搞个新 feature"、
  "按 spec 起脚手架"、"spec 都有了开始写代码"、"把 X 实现一下"等。
  即使用户没说"生成"二字,只要他们提供了模块名加用途描述并希望产出代码文件,也使用此 Skill。
  本 Skill 同时支持普通 Flutter 模块和需要 Flame 渲染的模块(可选扩展);依赖 PRD + TechPack 定稿(强门禁)。
---

# cute-pixel-module-gen

按当前项目的 architecture + conventions 生成一个新业务模块的完整脚手架。**核心策略:cp + sed**——直接拷贝 [lib/features/_template/](../../../lib/features/_template/)(被 lint+test 持续验证的"活模板"),然后机械替换名字。这比按文字模板手写更稳定,Agent 不容易跑偏。

## 必读文档

每次执行**重新读**(不靠记忆,规范以文档为准):

1. [CLAUDE.md](../../../CLAUDE.md) — 项目命令、4 条铁律
2. [doc/architecture.md](../../../doc/architecture.md) — Module-First Flat、命名约定、core/shared 边界
3. [doc/pixel-foundation.md](../../../doc/pixel-foundation.md) — Flame 集成契约(仅 Flame 模块需要)
4. [doc/conventions.md](../../../doc/conventions.md) — 12 节标准,着重 §1 错误、§4 i18n、§7 测试、§8 路由参数、§9 ViewState、§10 freezed、§11 跨模块通信、§12 时间与存档

## Step 0 — Spec 门禁(强制,不可跳过)

模块生成前**必须先核对 PRD + TechPack**:

1. 询问/检测两个文件:
   - PRD 路径:`doc/prd/{NN}-{module}.md`
   - TechPack 路径:`doc/design/{NN}-{module}.md`
2. 各打开看文末 `**状态**:`:
   - 都 `已定稿` → 通过门禁,继续
   - 任一为 `草稿`/`评审中` 或文件不存在 → **拒绝生成代码**,引导用户:
     - 缺 PRD → `/cute-pixel-doc-prd {module}`
     - 缺 TechPack → `/cute-pixel-doc-techpack {module}`
     - 都没定稿 → 先确认 spec 再来
3. **例外路径**:用户显式说 `skip-spec: <原因>`(如 prototype/学习/throwaway demo),允许通过,但:
   - 把 reason 写进生成模块的 `{module}_binding.dart` 顶部注释:`// ⚠️ skip-spec: <reason> — generated without PRD/TechPack, audit trail`
   - 报告里高亮提醒用户后续要补 spec
4. 通过门禁后,**读 PRD §3 范围 + §7 验收标准、TechPack §2 文件清单 + §3 状态形状**,把这些当本次生成的 ground truth(优先级高于用户对话里的临时描述)

## 工作流程

### Step 1 — 收集输入(Spec 已通过门禁,补足模板需要的细节)

跟用户确认这些(若 TechPack 已写明则跳过对应项),**不清楚就停下问**:

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

每个文件做三次替换:

```bash
# snake_case 的标识符(import 路径、part 指令、文件名引用)
find lib/features/{module} test/features/{module} -name "*.dart" -exec sed -i '' "s/_template/{module}/g" {} \;

# PascalCase 的类名(Template → {Module}PascalCase,例如 PetProfile)
find lib/features/{module} test/features/{module} -name "*.dart" -exec sed -i '' "s/Template/{ModulePascalCase}/g" {} \;

# 删除模板顶部的 ⚠️ TEMPLATE 警告块(8 行,从 "// ⚠️ TEMPLATE" 起到下一个空行止)
find lib/features/{module} test/features/{module} -name "*.dart" \
  ! -name "*.freezed.dart" ! -name "*.g.dart" \
  -exec sed -i '' '/^\/\/ ⚠️ TEMPLATE/,/^$/d' {} \;
```

**注意**:
- macOS `sed -i ''` 与 Linux `sed -i` 不同;按当前平台调整(开发机是 darwin)
- 别动 `_template_models.freezed.dart` / `_template_models.g.dart`——这些会被 `make codegen` 重生成,先 sed 内容,然后 codegen 会覆盖产物
- 替换后**人眼扫一遍** import 与类名,确保没误改框架字符串(`Template` 是常见词,grep 一下)
- **第三条 sed 必须在前两条之后跑**:删警告块依赖 `// ⚠️ TEMPLATE` 这个标志行,前两条 sed 不会改全大写 `TEMPLATE`,所以标志稳定。模板原件保留警告(对 _template/ 编辑者它是真的:"你在改种子,不在改业务"),cp 出去的衍生模块由本步去掉

### Step 4 — 删掉用不到的文件 + 改 mock 数据

- 不需要后端数据 → 删 `{module}_api.dart`、`test/features/{module}/{module}_api_test.dart`,在 controller 里把 `_TemplateApi()` 替换成本地构造
- 不需要数据模型 → 删 `{module}_models.dart` 与产物,改 controller 不依赖模型(罕见,通常都需要)
- 改 mock 数据为符合本模块语义的占位(`TemplateItem(id: '1', name: 'placeholder')` → 真实业务对象)

### Step 5 — Flame 扩展(仅当 Step 1 选了 Flame)

如果模块要用 Flame:
- 额外读 [doc/pixel-foundation.md](../../../doc/pixel-foundation.md) "Flame 的位置" 与 "Controller ↔ Flame Game 同步契约"
- 参考 [lib/features/pet/](../../../lib/features/pet/) 加 `{module}_game.dart` + `components/{module}_component.dart`
- Flame Component **只负责渲染**,业务状态留在 controller(铁律)
- 如果模块要接真 sprite(不只是占位色块),按 [doc/pixel-foundation.md "起新 sprite 的步骤"](../../../doc/pixel-foundation.md#起新-sprite-的步骤) 起 `assets/sprites/{namespace}/{species}/`(从 [assets/sprites/_template/](../../../assets/sprites/_template/) cp 起步,**不要**手撸目录结构)。其它资源类型(道具图标、UI 元素、背景、特效等)走对应 `assets/{type}/_template/`,导航见 [assets/README.md](../../../assets/README.md)

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

`_template` 已有的 `templateTitle / templateEmpty` 两个 key 是给模板用的,新模块**不要**复用这些 key,加自己的(`{module}Title` 等)。重试按钮**复用** `commonRetry`(跨模块共享),不要起 `{module}Retry`。

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
- **更新了 [lib/_manifest.yaml](../../../lib/_manifest.yaml) 的 `features:` 列表**(必须做,否则 `cute-pixel-status` 会漂移;在 `features:` 末尾追加新模块条目,字段对照已有项填)
- 下一步建议:`/cute-pixel-test-gen {module}` 按 PRD §7 AC 补测试 → `/cute-pixel-review features/{module}` 检查 spec 一致性

**不主动**调用 review 或 test-gen(只在报告里建议,等用户显式触发)。

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
