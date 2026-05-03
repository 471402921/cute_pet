# C. 未来摩擦面

按需读:Step 3 审 "未来摩擦面" 时打开。

## 这条原则要拦的腐烂

加新模块、改老模块、新人/Agent 接手时会**绊一下**的隐藏陷阱。这些陷阱在写的当下看不见,要"事后想象未来场景"才能识别。

跟 readability(意图传达)的区别:readability 是"看不懂"问题,friction 是"看懂了但接下来动作会被卡"问题。

## 怎么看出来

### 信号 1 — 双源真理

同一条规则在两个地方都写了,改一处忘了改另一处。常见来源:
- conventions.md 写了某条标准,某个 SKILL.md 也复制了一份(改 conventions 漏改 skill)
- 同一个常量在 `core/` 和某 feature 里都定义
- API endpoint 既在 `core/network/` 又在 feature `_api.dart`

判断:**任何"如果 X 变了,需要同时改 Y 和 Z 才不出错"的地方,都是一个未来 bug 等位**。

### 信号 2 — 孤儿文件 / 死代码

代码库里存在的文件,但没被任何地方 import。当下无害,但未来 Agent 看到会困惑("这真的没用?还是被忘了?"),还会污染搜索结果。要么删掉,要么 import 进入应有位置。

### 信号 3 — 隐式依赖(读不出来的耦合)

代码 A 依赖 B 但**编译期看不出来**:
- `Get.find<XxxController>()` 用了,但相关 binding 没有显式约定在哪里 `put`(运行时崩)
- ARB key 在代码里 `l10n.xxxKey` 用了,但 ARB 文件里漏了(运行时 null check 崩)
- 路由 `Get.toNamed('/foo')` 字符串硬写,而不是用 `AppRoutes.foo` 常量(改路由名漏一处)
- 文件名约定违反(`{module}_*.dart`)→ 未来 skill 扫描漏看

这些都是**只有运行时才暴露的耦合**。读代码时识别它们,标记出来。

### 信号 4 — 规范与代码脱钩(最严重)

doc/architecture.md 或 doc/conventions.md 立了规矩,但**最近新加的代码没遵守**。这比"老代码不合规"严重——意味着规范没在指导新开发,迟早整个仓漂离。

排查思路:看最近 3-5 个 commit 加的 features 文件,挑一条 conventions(如 §10 freezed 数据模型必带 abstract、§4 ARB 双语)对照。

发现一处就**报红色信号**——规范失效是最大腐烂源。

### 信号 5 — 测试缺失/过时(不是覆盖率问题)

不是"覆盖率不够"(那是 conventions §7 + test-gen 的事),是:
- `_controller.dart` 加了新公开方法,对应 controller_test 没动
- model 加了字段,fromJson↔toJson 测试没 cover 新字段
- 出现过 bug 的地方没补回归测试(commit message 改了 bug 但没新增测试)

判断:对照"近期变更" + "对应测试是否同步动了",而不是看绝对覆盖率。

### 信号 6 — 工作流约定被绕过

memory / CLAUDE.md / SKILL.md 描述的工作流被代码偷偷违反:
- 应该 `make get`,但脚本里写了 `flutter pub get`
- conventions §4 要 ARB 双语,但新 feature 只加了 zh
- 应该用 codegen 生成的文件被人手改了

让新人按字面学错,或者"为什么人家不照做我也不照做"。

## 报告时

每条问题写:
- **未来场景** —— 接下来谁会在什么动作时被绊
- **影响范围** —— 局部一个文件 / 整个模块 / 整个仓
- **修复方向** —— 删 / 重命名 / 加测试 / 加注释 / 改文档 / 加约束
