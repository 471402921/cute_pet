# Flame 模块扩展指引

按需读:Step 4(Flame 子分支)时打开。本文件给目的、关键陷阱、示意片段——不给完整可粘贴模板。

## 核心原则

**Flame Component 只负责渲染,不持有业务状态**。业务状态(实体属性、当前动作、定位)在 controller。Game 监听 controller 状态,做 diff,推给 Component。

**为什么**:
- Component 能脱离 GetX 在纯 Flame 测试里跑(纯 component 测试)
- 业务状态有唯一真理,不会"controller 一份、component 一份"两边脱同步
- 后续真接 sprite 时只动 component 内部渲染,controller / game 不动

详见 [doc/pixel-foundation.md](../../../../doc/pixel-foundation.md) 的 "Controller ↔ Flame Game 同步契约" 章节。

## 文件追加

在普通模块基础文件之上,**额外**加:

```
features/{module}/
├── ... (基础文件)
├── {module}_game.dart            FlameGame:监听 controller → diff → 推 Component
└── components/
    └── {module}_component.dart   PositionComponent,只暴露 applyXxx() 接口
```

接 sprite 时再加:`{module}_manifest.dart`(JSON 解析)+ `{module}_animation_loader.dart`(SpriteAnimation 字典)。manifest schema 见 architecture.md。

## `{module}_game.dart`

**关键陷阱**:
- 用 GetX `Worker`(`ever<...>`)订阅 controller.state,**必须**在 `onRemove` 里 `dispose()`,否则泄漏
- diff 模式:从 controller 拿新 list → 跟当前 components 集合比 → 删 / 加 / 更新

**示意结构**:

```dart
class SomeGame extends FlameGame {
  SomeGame(this._controller);
  final SomeController _controller;
  final Map<String, SomeComponent> _components = {};
  Worker? _worker;

  @override
  Future<void> onLoad() async {
    _worker = ever<ViewState<List<SomeItem>>>(
      _controller.state,
      _onStateChanged,
    );
    _onStateChanged(_controller.state.value);
  }

  @override
  void onRemove() {
    _worker?.dispose();
    super.onRemove();
  }

  void _onStateChanged(ViewState<List<SomeItem>> state) {
    if (state is! Data<List<SomeItem>>) return;
    // diff 逻辑:删消失的 → 加新的 → 更新已有的(applyItem)
  }
}
```

## `components/{module}_component.dart`

**关键陷阱**:
- Component 暴露的接口是 `applyXxx(NewItem item)` —— Game 调,Component 内部决定怎么渲染
- 占位阶段(无 sprite)用 `RectangleComponent` + `TextComponent` 显示状态/标签
- 接 sprite 后只换内部渲染部件(`SpriteAnimationComponent`),`applyXxx` 接口签名不变

**示意结构**(占位版):

```dart
class SomeComponent extends PositionComponent {
  SomeComponent({required SomeItem item})
    : _item = item,
      super(
        position: Vector2(item.x, item.y),
        size: Vector2(96, 96),
        anchor: Anchor.center,
      );

  SomeItem _item;
  // 内部渲染部件(占位:Rectangle + Text;真 sprite:SpriteAnimationComponent)

  @override
  Future<void> onLoad() async {
    // add(...) 子组件
  }

  void applyItem(SomeItem item) {
    _item = item;
    position = Vector2(item.x, item.y);
    // 更新渲染:换颜色 / 换动画 / 换标签
  }
}
```

## Page 嵌入 Game

**关键陷阱**:Flame 模块的 page **必须用 `StatefulWidget`**,不能用 `GetView`/`StatelessWidget`。原因:`GameWidget(game: ...)` 接收的 game 实例不能跟着 build 重建,否则每次 setState 整个 Flame 世界都重置。

**示意结构**:

```dart
class SomePage extends StatefulWidget {
  const SomePage({super.key});
  @override
  State<SomePage> createState() => _SomePageState();
}

class _SomePageState extends State<SomePage> {
  late final SomeController _controller;
  late final SomeGame _game;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SomeController>();
    _game = SomeGame(_controller);  // 实例化一次,不跟 build 重建
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          // 上层 Flutter Overlay 控制面板...
        ],
      ),
    );
  }
}
```

## 接 sprite 时的换法

接真 sprite **不需要**改 game / page / controller,只需:

1. 加 `{module}_manifest.dart` 解析 manifest.json
2. 加 `{module}_animation_loader.dart` 加载 + 构建 SpriteAnimation 字典
3. 修 `{module}_component.dart` 的渲染部件:`RectangleComponent` → `SpriteAnimationComponent`
4. `applyItem` 内部:从字典查对应 (action, direction) 的 SpriteAnimation,赋给渲染组件

接口不变 = 影响范围最小 = 漂移风险最低。
