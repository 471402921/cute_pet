# `assets/` — cute_pixel 资源目录导航

按**资源类型**分目录,每类下都有 `_template/` 骨架(不进 bundle)+ 真资源 namespace。要起新资源时,从对应类型的 `_template/` 拷贝改名,**不要**手撸目录结构。

## 类型一览

| 目录 | 装什么 | 格式 | 模板 |
|---|---|---|---|
| [`sprites/`](sprites/) | 角色/生物精灵图(宠物、NPC、敌人) | PNG sprite sheet + manifest.json | [`sprites/_template/`](sprites/_template/) |
| [`items/`](items/) | 道具/物品图标(食物、装备、收藏) | PNG icon (静态或小动画) + manifest.json | [`items/_template/`](items/_template/) |
| [`ui/`](ui/) | 通用 UI 元素 | PNG (按钮 / 图标 / 9-slice 边框) | [`ui/buttons/_template/`](ui/buttons/_template/) 等 |
| [`scenes/`](scenes/) | 场景背景图、视差层 | PNG (单图或分层) | [`scenes/_template/`](scenes/_template/) |
| [`effects/`](effects/) | 特效动画(粒子、过渡) | PNG sprite sheet | [`effects/_template/`](effects/_template/) |
| [`tilemaps/`](tilemaps/) | 瓦片集 + Tiled 地图数据 | PNG tileset + .tmx / .json | [`tilemaps/_template/`](tilemaps/_template/) |
| [`audio/`](audio/) | 音效与音乐 | .ogg / .wav | [`audio/sfx/_template/`](audio/sfx/_template/) [`audio/music/_template/`](audio/music/_template/) |
| [`fonts/`](fonts/) | 像素字体(位图字体或 TTF) | .ttf / .fnt + .png | [`fonts/_template/`](fonts/_template/) |

## 通用约定

1. **每类资源用自己类型的模板**,不要混用(sprite 的 manifest 跟 item 的不一样)
2. **`_template/` 不进 bundle**——pubspec.yaml 的 `flutter.assets:` 永远不要加 `_template/` 路径
3. **按 namespace 分组**,如 `assets/sprites/pets/{species}/`、`assets/items/food/{itemId}/`
4. **像素资源整数尺寸,无插值**——见 [doc/pixel-foundation.md "像素纯度"](../doc/pixel-foundation.md#像素纯度)
5. **新资源都要在 pubspec.yaml 启用对应 namespace**,否则 build 时拿不到

## 不做

- **不**按业务模块分(`assets/pet_module/` 这种是反的)——asset 跨模块共享,按类型分才合理
- **不**在资源目录写业务逻辑(逻辑归 `lib/features/{module}/`)
- **不**在 `assets/` 根放散落的 PNG——必须先选类型目录

## 完整契约

[doc/pixel-foundation.md "Asset 资源约定"](../doc/pixel-foundation.md#asset-资源约定) 是唯一真理。本 README 只是导航。
