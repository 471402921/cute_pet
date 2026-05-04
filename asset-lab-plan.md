# asset-lab 计划(决议版)

> 状态: **决议**,讨论结束。本文是落地参考,可执行。
> 由 sprite-lab-proposal.md 演化而来,经多轮讨论收口。
> 落点: 暂存 cute_pet 根目录;asset-lab 立仓后随之搬过去,本文留 cute_pet 内做决策记录。

---

## 0. TL;DR(决议摘要)

| 项 | 决议 |
|---|---|
| 工具定位 | 独立轻量 Web 工具,**两条主线: sprite 键盘交互预览 + 场景编排** |
| 与 pixellab 关系 | pixellab 生成"零件"(团队账户 + MCP),asset-lab 负责"预览交互 + 场景编排",分工不重复 |
| 资源覆盖 | 7 类(sprite / item / ui / scene / effect / tilemap / audio),除字体外全要 |
| 技术栈 | 纯 HTML + Vanilla JS + Canvas 2D,零构建零依赖 |
| 仓库位置 | 独立 repo `asset-lab`,不混入 cute_pet |
| 数据契约 | sprite 类跟随 pixellab `metadata.json`;场景另用自定义 `scenes/{level}.json`(简单 schema) |
| 设计师 | 1 人;后续多人时各自 fork,不做团队 git workflow |
| game_meta.json | sprite-lab 不实装;**槽位预留在 cute_pet**;未来按需 vibe-code 长出编辑 UI |
| cute_pet 通用 loader | defer 到第一个 sprite 真要进 cute_pet 时再做 |
| 编辑能力增长策略 | MVP 只读;按设计师真实痛点 vibe-code 长(CC 改 ~30~80 行/能力) |

---

## 1. 背景

设计师正在用 [pixellab.ai](https://www.pixellab.ai/) 产 sprite/items/maps/tilesets。pixellab 强项: AI 生成 + 单 sprite 内置预览。短板:

- 不做场景编排(把多个资源摆成一张关卡)
- 不做 sprite **交互**预览(键盘控制方向/动画切换/状态对比)
- 不做项目级资源管理(已有什么、版本、组织)

cute_pixel 是生产框架,链路太长,不适合调试。需要一个中间层工具。

→ asset-lab 填这三个空。pixellab 负责"零件",asset-lab 负责"预览 + 编排",git 负责"管理"。

---

## 2. 职责分工

```
设计师产能链路:
  [pixellab MCP/Web]  →  [asset-lab]  →  [git repo]  →  [cute_pet]
   生成 + 单图预览       多图交互预览     版本管理      运行时消费
                       场景编排
```

**pixellab 做的(asset-lab 不复刻)**:
- AI 生成各类资源
- 单 sprite 8 方向 + 动画 preview(Characters 模块自带)
- 资源导出 metadata.json + pngs

**asset-lab 做的(pixellab 不做)**:
- 键盘控制 sprite 状态(切方向、播/停动画、对比 idle/walk 切换手感)
- 多资源同屏预览(sprite 站背景上 + 道具围绕 + UI 叠层)
- 场景编辑(声明式 JSON,设计师 + CC 维护)

**git 做的**:
- 资源版本管理(asset-lab 仓本身 = 资源 + 场景 + 工具一起)

---

## 3. 资源类型矩阵

| 类型 | MVP? | 数据来源 | loader 复杂度 | 备注 |
|---|---|---|---|---|
| sprite(角色) | ✅ | pixellab metadata.json + pngs | 低 | 已有 husky chibi 样本 |
| item(道具) | ✅ | pixellab,大概率单 PNG | 极低 | |
| ui(按钮/图标/边框) | ✅ | pixellab 或手画,单 PNG / 9-slice | 低~中 | 9-slice 渲染稍复杂 |
| scene(背景) | ✅ | pixellab `create_map` 生成完整图 | 极低 | 单 PNG 直接显示 |
| effect(特效) | ✅ | pixellab,帧序列 PNG | 中 | 跟 sprite 动画机制共用 |
| tilemap(地图) | ⚠️ TBD | **待问设计师工具**(Tiled / pixellab tileset 自切 / 手切) | 100~500 行(差距 5×) | 工具确定后做,不阻塞 |
| audio(音效/音乐) | ✅ | DAW,.mp3/.wav | 低 | `<audio>` + 键盘绑定播放 |
| font(字体) | ❌ | - | - | 跳过 |

**tilemap 的开发节奏**: 不阻塞 MVP,设计师确认工具后单独加。loader 是插件式,加新类型不动 core。

---

## 4. 技术栈

**纯 HTML + Vanilla JS + Canvas 2D**(已决议)。

- 零构建、零依赖,设计师双击 index.html 或 `python -m http.server` 即可
- CC 改纯 JS 比改 Flutter/p5/Phaser 直觉,vibe-code 体验最优
- 拒绝引入: 任何 npm 包、任何 framework、任何构建步骤

**浏览器文件写入**(场景 JSON 维护、未来 game_meta 编辑器需要):
- 首选 [File System Access API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_Access_API)(Chromium 系)→ 直接写回设计师选定的文件
- 降级: 下载按钮(浏览器存到 Downloads,设计师手动拖回)

---

## 5. 仓库结构

```
asset-lab/
├── index.html              # 入口,模式选择 + 两个 canvas
├── core/                   # 通用基础设施
│   ├── renderer.js         # Canvas 渲染:背景 + 多 entity
│   ├── input.js            # 键盘事件 + 提示框生成
│   ├── scene_loader.js     # 读 scenes/{level}.json
│   └── version_guard.js    # 检查 metadata.json export_version
├── loaders/                # 每类资源一个加载器(扩展槽)
│   ├── sprite_loader.js    # MVP: pixellab metadata.json
│   ├── item_loader.js      # MVP: 单 PNG
│   ├── ui_loader.js        # MVP: 单 PNG / 9-slice
│   ├── scene_bg_loader.js  # MVP: 单 PNG
│   ├── effect_loader.js    # MVP: 帧序列
│   ├── audio_loader.js     # MVP: <audio>
│   └── tilemap_loader.js   # 占位 + README "等格式定再实装"
├── modes/                  # 两条主线
│   ├── sprite_preview.js   # 单 sprite 键盘交互预览
│   └── scene_preview.js    # 多资源场景预览
├── assets/                 # 设计师投放区(同构 cute_pet/assets/)
│   ├── sprites/{name}/     # pixellab 导出目录直接拷进来
│   ├── items/
│   ├── ui/
│   ├── scenes/             # 背景图
│   ├── effects/
│   ├── tilemaps/
│   └── audio/
├── scenes/                 # 场景编排 JSON
│   └── level_001.json
├── keymap.js               # 键盘绑定 + 资源选择
├── CLAUDE.md               # 给 CC 的护栏 + vibe-code 指引
└── README.md               # 给设计师的入门
```

---

## 6. MVP 范围

**两条主线 day-1 都要能跑**。

### 6.1 Sprite 预览模式

- 加载 `assets/sprites/{name}/metadata.json`(pixellab 格式)
- 按 `frames.rotations` 渲染 8 方向
- 按 `frames.animations` 列出可播动画
- 键盘: WASD/方向键切方向、1~9 切动画、空格 播/停、+/- 调缩放
- 提示框自动从 keymap 生成"按 X = Y"列表
- 显示当前 sprite 的 character.name / size / prompt
- 默认 4× 缩放(60×60 sprite 看清细节)

### 6.2 Scene 预览模式

- 加载 `scenes/{level}.json`,渲染 background → 按 entities 数组叠加
- 切换场景: keymap 数字键
- 设计师改 JSON → 浏览器刷新即生效

**scene.json schema(MVP,简单)**:
```json
{
  "background": "scenes/forest_clearing.png",
  "entities": [
    { "type": "sprite", "asset": "sprites/husky_chibi", "x": 120, "y": 200, "facing": "south" },
    { "type": "item",   "asset": "items/bone.png",      "x": 180, "y": 220 },
    { "type": "ui",     "asset": "ui/dialogue_frame.png", "x": 0, "y": 400 }
  ]
}
```

### 6.3 不做(MVP 边界)

- ❌ 任何编辑 UI(MVP 只读;编辑能力按设计师痛点 vibe-code 长)
- ❌ 物理 / 碰撞 / 动画状态机
- ❌ 多场景互相跳转 / 触发器
- ❌ 自己的 sprite/asset 生成(那是 pixellab 的事)
- ❌ 团队协作工具(单设计师,git CLI 即可)
- ❌ 自己的 manifest schema(pixellab 是上游)

---

## 7. 设计师工作流

```
1. clone asset-lab repo                           # 一次,5 分钟
2. 在 pixellab 生成资源(Web 或通过 CC + MCP)
3. 把 pixellab 导出目录拷进 assets/{type}/{name}/
4. 双击 index.html(或 npx serve)
5. 选 sprite 预览 / scene 预览模式
6. 键盘交互看效果
7. 想改场景: 跟 CC 说"把 husky 往左挪 50" → CC 改 scenes/*.json → 刷新
8. 想加新能力: 跟 CC 说"加个动画速度滑块" → CC 写 ~50 行 → 刷新
9. 满意 → git commit
10. 资源进 cute_pet → 直接拷 assets/{type}/{name}/ 进 cute_pet/assets/
```

---

## 8. cute_pet 端预留

asset-lab 是独立 repo,**不动 cute_pet 代码**。但 cute_pet 这边要预留两件事:

1. **[doc/pixel-foundation.md](doc/pixel-foundation.md) 加一节** "asset-lab 工作流",说明:
   - pixellab → asset-lab → cute_pet 链路
   - sprite 资源约定跟随 pixellab metadata.json
   - **game_meta.json sidecar 槽位预留**(字段细节等首个 sprite 接入时定)

2. **lib/core/ 不预建 sprite loader** —— defer 到第一个 sprite 真要进 cute_pet 时再实装。理由: YAGNI,等 asset-lab 把契约打磨完再写 loader,避免重写。

---

## 9. CC 护栏(asset-lab/CLAUDE.md 大纲)

设计师跟 CC chat 时,CC 要遵守:

- **零构建**: 不引 npm 包,不加 webpack/vite,不引 React/Vue/任何 framework
- **不动上游 schema**: pixellab metadata.json 是上游契约,不能改字段语义
- **scene JSON 简单优先**: 加字段前问设计师,避免 schema 漂移
- **vibe-code 增长**: 设计师说"加个 X" → 优先选 ~50 行能搞定的方案,不大刀阔斧
- **不引擎化**: 不要把 asset-lab 长成 Phaser/p5(那是 cute_pet 的事)
- **未来 game_meta 编辑器**: 字段定下时先跟设计师确认,再加 UI

---

## 10. 执行清单

- [ ] **1. 立独立仓库** `asset-lab`(GitHub,公开/私有按需)
- [ ] **2. 首版骨架**: index.html + core/ + loaders/sprite_loader.js + modes/sprite_preview.js
- [ ] **3. 跑通 sprite 预览**: husky chibi 加载 + 8 方向 + 动画播放
- [ ] **4. 加 scene_loader + scene_preview + 一个示例场景**
- [ ] **5. 填其余 loader**: item / ui / scene_bg / effect / audio
- [ ] **6. 写 CLAUDE.md + README.md**
- [ ] **7. 设计师试用 + 反馈 + vibe-code 迭代**
- [ ] **8. (异步)追问设计师 tilemap 工具,加 tilemap_loader**
- [ ] **9. (cute_pet 侧)doc/pixel-foundation.md 加 asset-lab 工作流说明 + game_meta 槽位备忘**
- [ ] **10. (cute_pet 侧)写 ADR-010 记录"为什么不做生成只做预览/编排"决策**

---

## 11. 不做的事(范围漂移防线)

- ❌ 在 cute_pet 加任何 asset-lab 相关代码
- ❌ 让 asset-lab 依赖 Dart/Flutter
- ❌ asset-lab 写 CI/lint(它是调试工具,不是产品)
- ❌ 复刻 pixellab 的生成能力
- ❌ 字体预览
- ❌ 多设计师 git workflow
- ❌ asset-lab 进化成游戏引擎(状态机/物理/触发器都不要)
