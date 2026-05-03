# A. 架构边界漂移

按需读:Step 3 审 "架构边界完整性" 时打开。

## 这条原则要拦的腐烂

4 条铁律(模块自治 / 共享单点 / 单向依赖 / 命名一致)被悄悄破坏。每被破一次都是单向门——后面想恢复要重构整片代码。

边界一旦模糊,Agent 在某模块工作时就**没法只读一个文件夹**了——必须扫整个仓才能搞清楚依赖,上下文成本指数上升。

## 怎么看出来

打开范围内文件,关注这几类信号(具体怎么找:扫 import、看跨模块的相似 widget、看文件命名):

### 信号 1 — features 互引(违反铁律 1)

`features/A/` 内部出现 `import 'package:cute_pixel/features/B/...'`。常见来源:
- 模块 A 偷用模块 B 的 widget(应迁到 `shared/widgets/`)
- 模块 A 偷用模块 B 的 model(应迁到 `shared/`,或两个模块各自定义等价类型)

### 信号 2 — `core/` 或 `shared/` 引用 features(违反铁律 3)

`lib/core/` 或 `lib/shared/` 内部出现 `import 'package:cute_pixel/features/...'`。这是反向依赖,**严重**,因为 core/shared 是被 features 依赖的下游,不能反过来引用上游。

### 信号 3 — 跨模块 widget 实际复制粘贴

不是 import,但代码长得几乎一样。判断标准:
- 类名相似(`PetCard` vs `HealthCard`)
- 视觉/交互逻辑明显是同一种
- 改一个时另一个大概率也要跟着改

应该提到 `shared/widgets/`,统一一份。

### 信号 4 — 命名漂离 `{module}_*.dart`(违反铁律 4)

`features/{module}/` 下文件不带模块名前缀(除了 `widgets/` 子目录里的私有 widget)。这种漂移会**直接破坏未来 skill 的扫描**(skill 靠命名找文件)。

### 信号 5 — `app/` 混入业务

`lib/app/` 应该只装路由 / 主题 / 全局 binding。出现业务相关常量、模型、enum 就要拉回对应 feature 或 `shared/`。

## 报告时

每条问题写:
- 违反的具体铁律
- 触发的具体文件 + 行号(让用户能跳过去)
- 修复方向(一句话):迁到 shared/、本 feature 内复制、删 import、重命名
