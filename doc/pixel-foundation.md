# Pixel Foundation

像素风 Flutter + GetX + Flame 应用的**通用底座**约定。本文与具体业务(features/pet/ 是当前内置的 demo)解耦 —— 任何想做下一款像素风 app(种菜、养鱼、小镇 demo 等)的人或 Agent,读完本文加 [architecture.md](architecture.md) + [conventions.md](conventions.md) 三件套,就能起一个新项目。

> 状态标记 `planned | scaffolded | in-use` 的含义见 [architecture.md "状态标记说明"](architecture.md#状态标记说明)。

## 目标与适用范围

适用于:

- **像素风**(pixel art)— 强调 pixel-perfect 渲染,放大不糊、整数缩放、方向贴图分离
- **Flutter UI + Flame 局部游戏化** — 主体是 Flutter Material/Cupertino UI(列表、表单、设置),只在动画/精灵展示模块嵌 Flame
- **移动 + Web 单代码库** — iOS / Android / macOS / Windows / Web 一份代码,但要求开发者明确知道每个平台的差异(尤其 Web)
- **业务大头在后端** — 客户端薄,见 [architecture.md "设计目标"](architecture.md#设计目标)

不适用于:

- **全屏游戏(Flame 主导整个 app shell)** — 那应当直接用 Flame + 极少量 Flutter,不必背 GetX/Module-First Flat 这套约束
- **3D / 高 DPI 矢量风** — 本文很多约定(`FilterQuality.none`、整数缩放)对它们是负收益

## Flame 的位置

> 完整 ADR 见 [ADR-002](decisions/ADR-002-flame-scope-game-modules-only.md)。

Flame 是**使用它的模块的实现细节**,只能出现在该模块的 `features/{game-module}/` 内部。**不**进入 `core/`、`shared/`、或非游戏化 feature。一个 Flame 模块允许的扩展结构(以 features/pet/ 为例):

```
features/pet/
├── pet_page.dart                  # Scaffold + GameWidget + Flutter Overlay 控制面板    [in-use]
├── pet_controller.dart            # 业务状态唯一真理(pets 列表、当前选中、动作)         [in-use]
├── pet_binding.dart                                                                    [in-use]
├── pet_models.dart                # Pet + PetAction + PetDirection + PetSpecies(纯 Dart) [in-use]
├── pet_api.dart                                                                        [in-use]
├── pet_game.dart                  # FlameGame:监听 Controller → 同步 PetComponent      [in-use]
├── pet_manifest.dart              # manifest.json 模型 + 解析(真接 sprite 时加)        [planned]
├── pet_animation_loader.dart      # 加载 manifest + 构建 SpriteAnimation 字典(真接 sprite 时加) [planned]
└── components/
    └── pet_component.dart         # PositionComponent,applyState(action, direction)    [in-use]
```

**关键**:Flame Component **只负责渲染**,不持有业务状态。业务状态(饥饿度、健康、当前动作等)在 `{module}_controller.dart`。这条原则使 Component 可以脱离 GetX 在纯 Flame 测试里跑。

## Controller ↔ Flame Game 同步契约

为避免业务状态 Controller 和 Component 双 source of truth:

```
{Module}Controller (.obs<List<Entity>>)
        │
        │  ever() 监听变化
        ▼
   {Module}Game.on{Entities}Changed(newList)
        │
        │  与当前 {Entity}Component 列表做 diff:
        │  - 新增 Entity      → world.add({Entity}Component(entity))
        │  - 删除 Entity      → component.removeFromParent()
        │  - 现有 Entity 状态变 → component.applyState(state)
        ▼
   {Entity}Component.applyState(state)
        │
        │  只做一件事:
        ▼
   切换当前显示的 SpriteAnimation(或占位渲染)
```

**Component 不订阅 Controller**,只暴露 `applyState()` 让 Game 推。换个 app 主体只换名字 `Pet → Plant / Fish / Villager`,模式不变。

参考实现见 [lib/features/pet/pet_game.dart](../lib/features/pet/pet_game.dart)。

## Sprite 资源约定

每个实体一个文件夹,内含 manifest 与 PNG。`assets/{namespace}/` 的 namespace 由具体 app 决定(本仓库 features/pet/ 用 `pets/`,种菜 app 可用 `plants/`,养鱼可用 `fishes/`),manifest schema 通用:

```
assets/{namespace}/{species}/
├── manifest.json
├── idle_north.png       (directional: true 时,4 张 north/east/south/west)
├── idle_east.png
├── idle_south.png
├── idle_west.png
├── eat.png              (directional: false 时,1 张所有方向共用)
├── sleep.png
└── ...
```

### manifest.json schema

```json
{
  "species": "shibainu",
  "displayName": "柴犬",
  "tileSize": { "w": 64, "h": 64 },
  "actions": {
    "idle":  { "frameCount": 4, "stepTime": 0.20, "directional": true  },
    "walk":  { "frameCount": 6, "stepTime": 0.12, "directional": true  },
    "run":   { "frameCount": 6, "stepTime": 0.08, "directional": true  },
    "eat":   { "frameCount": 6, "stepTime": 0.15, "directional": false },
    "drink": { "frameCount": 6, "stepTime": 0.15, "directional": false },
    "sleep": { "frameCount": 4, "stepTime": 0.40, "directional": false }
  }
}
```

**字段说明**

- `tileSize`:每帧像素尺寸(SpriteAnimation 切帧依据)
- `frameCount`:该动作的帧数
- `stepTime`:每帧持续秒数
- `directional`:`true` 加载 4 个方向的 PNG;`false` 加载单张所有方向共用

**扩展原则**(零代码改动是底座的核心承诺)

- **加新实体** = 新建 `assets/{namespace}/{new_species}/` + 一份 manifest + PNG;只需 `Species` enum 加一项
- **加新动作** = manifest 里加一行 + 出图;只需 `Action` enum 加一项
- **加 8 方向** = 改 `Direction` enum + 改加载逻辑;少量改动

## 渲染器选择(Web)

### 为什么必要

Flutter Web 有两种渲染器后端,默认与体验差异巨大:

| 渲染器 | 包体 | 渲染一致性 | Flame 兼容性 |
|---|---|---|---|
| **CanvasKit**(skwasm) | +2MB wasm,首屏多一次下载 | 与 mobile 一致(像素表现稳定) | 完整支持 |
| **HTML renderer**(已废弃,Flutter 3.27 起 removed) | 轻 | 文字/动效与 mobile 有差异 | 部分功能(自定义 shader、blend mode)不工作 |

像素风对"放大不糊、color blending 一致"敏感,跨平台像素表现必须可预期。HTML renderer 在 Flutter 3.27 已被移除,所以新项目实质上**只有 CanvasKit 一条路**,但首屏 wasm 下载成本必须正视(配合下面"资源懒加载")。

### 推荐做法

- Web 构建保持默认(CanvasKit)。**不要**关闭 wasm
- `web/index.html` 自定义 loading,**首屏先显示骨架**(纯 HTML/CSS,几 KB),Flutter 起来后再渲染
- `flutter build web --wasm` 启用 skwasm,bundle 更小、性能更好(需要 Flutter 3.22+ 与 cross-origin headers)
- 监控首屏:lighthouse 跑一次,LCP > 4s 就要看是不是在首屏拉了不必要的 sprite(转交"资源懒加载")

### 当前实现状态

`planned` — 本仓库 **尚未启用 web 平台**(`web/` 目录不存在,grep 也无 `kIsWeb` 引用)。第一次 `flutter create --platforms=web` 时按本节执行。

## 像素纯度自检

### 为什么必要

Flutter `Image` widget 默认 `FilterQuality.low`(双线性插值),把 16×16 sprite 放大到 128×128 会产生灰色过渡像素 —— 像素风看上去糊一层雾。Flame 的 `SpriteComponent` 也走 `Paint.filterQuality`,同样默认 low。常见踩坑:

- 在 mobile 上看着像素清晰(物理像素与逻辑像素 1:1 时插值不可见),Web 上 1.0 → 1.25 缩放就糊
- 缩放比是 1.7、2.3 这种非整数时,任何 `FilterQuality` 都救不回来

### 推荐做法

1. **全局禁用插值**:
   - Flame:`Flame.images = Images()` 后,`Paint paint = Paint()..filterQuality = FilterQuality.none;` 传给 `SpriteComponent(paint: paint)` 或全局覆盖 `_pixelArtPaint`
   - Flutter:`Image.asset(..., filterQuality: FilterQuality.none, isAntiAlias: false)`,自定义 `ImageProvider` 时同样
2. **整数缩放比**:Game world 的 logical size 设成 sprite 原始 tileSize 的整数倍(例:tileSize 64 × camera zoom ∈ {1, 2, 3, 4})。`GameWidget` 不要用 `BoxFit.contain` 让框架算缩放
3. **bitmap 字体策略**:像素风 UI 文字也得统一 —— 要么走 bitmap font(Flame 的 `BitmapFont`),要么 TTF 但 `TextStyle(fontFamily: 'PixelFont')` + 像素字号取整数倍

### 开发期"像素纯度自检页"(planned)

建议建一个开发期 route(只在 `kDebugMode` 下挂载,不进生产路由表):

```
/__pixel-check
├── 一张 16×16 测试 sprite,以 ×1 / ×2 / ×4 / ×8 / ×3.5(故意非整数)五种比例并排显示
├── 每张图标注当前 FilterQuality
└── 肉眼判断:整数倍 + none = 锐利;非整数倍 = 锯齿但不糊;low = 雾感
```

凡新接入 sprite 资源、升级 Flutter/Flame 大版本、新增 web 平台后,跑一次自检页对比截图。

### 当前实现状态

`planned` — grep `lib/` 无任何 `FilterQuality` / `filterQuality` / `BitmapFont` 出现。pet 模块当前是占位渲染(色块 + 文字),还没有真 sprite,所以问题尚未暴露。**接 sprite 第一刻就要落本节**。

## 输入抽象

### 为什么必要

移动端是 tap / drag(`onTap` / `onPanUpdate`),Web 是 mouse(`onTap` 也工作)+ keyboard(WASD / 方向键),桌面再加滚轮、右键。如果 features/ 内部直接 `if (kIsWeb) ... else ...` 或同时挂 `GestureDetector` + `RawKeyboardListener`,会出现:

1. 每个 feature 都重复一遍平台分支,语义事件分散在十处
2. 单元测试得 mock 平台 — 没法测语义("用户想前进"),只能测"用户按了 W 键"
3. 加手柄/触控屏笔时全仓库改

### 推荐做法

`core/input/`(planned)对外暴露**语义事件**,平台映射在 core 内部完成,features/ 只订阅语义流:

```dart
// core/input/input_event.dart  [planned]
sealed class InputEvent {}
class PrimaryAction extends InputEvent {}              // tap / left-click / Enter
class SecondaryAction extends InputEvent {}            // long-press / right-click / Esc
class Move extends InputEvent { final Offset delta; } // drag / WASD / arrow keys
// (未来扩展:Zoom / Pan / Hover / GamepadButton)

// core/input/input_service.dart  [planned]
abstract class InputService {
  Stream<InputEvent> get events;
}

// 平台实现在 core/ 内部:
//   MobileInputService:GestureDetector → events
//   WebInputService:GestureDetector + Focus + HardwareKeyboard → events
// 注入由 app_binding.dart 按 defaultTargetPlatform 选一个
```

features/ 里:

```dart
// features/pet/pet_controller.dart
class PetController extends GetxController {
  final InputService _input = Get.find();
  StreamSubscription? _sub;

  @override
  void onInit() {
    _sub = _input.events.listen((e) {
      if (e is PrimaryAction) _selectNextPet();
      if (e is Move) _movePet(e.delta);
    });
  }
}
```

**features/ 不出现 `if (kIsWeb)`、不出现 `RawKeyboardListener`**,平台差异止于 `core/input/`。

### 当前实现状态

`planned` — `lib/core/input/` 目录尚未创建,grep 无 `kIsWeb` / `HardwareKeyboard` / `RawKeyboard`。当前 pet 交互极简(只有 Flutter Overlay 上几个按钮),不需要键盘 — 但接入 web 或加自由移动那一刻就需要本节。

## 资源懒加载

### 为什么必要

移动端 50MB asset 没人在意(应用商店包体几百 MB 是常态),Web 50MB 是首屏灾难 —— 用户在白屏期间已经流失。像素风 sprite 看似小(每张 PNG 几 KB),但**多物种 × 多动作 × 多方向**很快累加:

> 10 个物种 × 6 个动作 × 4 个方向 × 8 帧/张 = 240 张 PNG ≈ 6-15MB(取决于 tileSize)

首屏只需要"主页 + 当前选中宠物的 idle"(< 50KB)。把全部 sprite 写进 `pubspec.yaml` 的 `flutter.assets` 不分级别 = 一次下载全套。

### 推荐做法

按 `species` × `action` 分级加载,Flame 的 `Images.load` 是异步的,用一个加载策略包起来:

```
启动顺序(planned):
  1. main.dart → runApp           [不加载任何 sprite,几 KB]
  2. 首屏 home_page 渲染          [纯 Flutter UI,无 sprite]
  3. 用户进入 pet_page
       ├─ 立即:加载当前选中物种的 idle (1 个 species × 1 action ≈ 100KB)
       ├─ 后台 idle frame:预加载该物种其它常用动作 (walk, eat)
       └─ 用户切到其它物种时:再加载该物种的 idle
  4. 设置页/统计页等无 sprite 的功能,完全不触发任何 sprite 下载
```

实现方向(均 planned):

- `pet_animation_loader.dart` 暴露 `loadIdle(species)` / `loadAction(species, action)`,内部维护 LRU 缓存(Web 上限 50MB,mobile 不限)
- `pubspec.yaml` 用目录通配符 `assets/pets/` 让 Flutter 知道资源位置,但实际加载由 `Images.load` 控制时机
- Web 上额外:配合 service worker 缓存策略,二次访问命中本地

### 当前实现状态

`planned` — `assets/` 目录尚未创建,pet 模块还是占位渲染。第一次接真 sprite 时本节与"渲染器选择"一并落地。

## 与具体 app 的边界

本文是底座的**契约**,不是底座的**代码**(底座代码分散在 `core/`、`shared/`、模块内 Flame 集成里)。fork 一个新像素 app 时:

| 复用 | 说明 |
|---|---|
| `architecture.md` + `pixel-foundation.md` + `conventions.md` | 三件套整体复用,不动 |
| `core/` + `shared/` | 整体复用,新 app 内可扩展 |
| `lib/app/` 骨架(routes / theme / binding) | 复用骨架,routes 列表清空重填 |
| `features/` | **完全清空,按新 app 业务重建** |
| `assets/{namespace}/` | namespace 重命名(`pets` → 新 app 的实体) |
| 三个 `cute-pixel-*` skill | 复用(skill 本身不绑业务) |

新 app 第一个动作:在 `doc/` 写自己的 `prd/` + `design/`,然后 `/cute-pixel-module-gen` 起第一个模块。
