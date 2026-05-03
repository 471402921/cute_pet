# `assets/scenes/_template/` — 场景背景目录脚手架(骨架,非真场景)

> ⚠️ cute_pixel **场景背景图/视差层**资源模板。**不是**真场景,**不要**在 pubspec.yaml 启用。
>
> 瓦片地图(可编辑、可重复使用瓦片)走 [`assets/tilemaps/_template/`](../../tilemaps/_template/);本目录是单图或预渲染分层背景。

## 起新场景的步骤

```bash
# 1. 拷贝模板
cp -r assets/scenes/_template assets/scenes/home_room

# 2. 出 PNG 放进 assets/scenes/home_room/(命名见下方)

# 3. pubspec.yaml 启用 - assets/scenes/home_room/

# 4. 通过 'scenes/home_room/bg.png' 加载
```

## 目录与 PNG 命名规则

```
assets/scenes/{sceneId}/
├── bg.png                  # 必须,主背景层
├── parallax_far.png        # 可选,视差远景(滚动慢)
├── parallax_mid.png        # 可选,中景
└── parallax_near.png       # 可选,近景(滚动快)
```

- 视差层独立 PNG,渲染顺序由调用方决定
- 像素艺术尺寸应是逻辑像素的整倍——见 [doc/pixel-foundation.md "像素纯度"](../../../doc/pixel-foundation.md#像素纯度)

## namespace 怎么取

按场景语义,如 `home_room`、`forest_day`、`battle_arena`。**不**按模块切分。

## 不做

- **不**放真 PNG / **不**进 bundle
- **不**把场景做成可编辑瓦片图——用 [`assets/tilemaps/`](../../tilemaps/) 才对
