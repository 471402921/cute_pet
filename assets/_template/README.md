# `assets/_template/` — sprite 目录脚手架(骨架,非真物种)

> ⚠️ 这是 cute_pixel 像素 sprite 资源的**目录模板**,**不是**真物种,**不要**在 pubspec.yaml 启用进 bundle。要接真 sprite 时,从这里 cp 出去改名。

## 起新 sprite 的步骤

```bash
# 1. 拷贝模板到目标 namespace(假设 pet 模块的 pets/ namespace)
cp -r assets/_template assets/pets/shibainu

# 2. 改 manifest.json:
#    - species: "_template" → "shibainu"
#    - displayName: 替换为『柴犬』之类
#    - 各 action 的 frameCount / stepTime / directional 按你的 PNG 实际调

# 3. 出 PNG 放进 assets/pets/shibainu/(命名规则见下方)

# 4. pubspec.yaml 启用 namespace(去掉 flutter.assets 那段的注释,改 namespace)

# 5. make get 后在 Flame Component 里 Sprite.load('pets/shibainu/idle_south.png')
```

## 目录与 PNG 命名规则

```
assets/{namespace}/{species}/
├── manifest.json           # 必须,本文件结构
├── idle_north.png          # directional: true → 4 张方向图
├── idle_east.png
├── idle_south.png
├── idle_west.png
├── walk_north.png          # 同上
├── walk_east.png
├── walk_south.png
├── walk_west.png
├── eat.png                 # directional: false → 1 张所有方向共用
├── drink.png
└── sleep.png
```

- **directional: true** 的 action → 4 张 PNG,后缀 `_{north|east|south|west}.png`
- **directional: false** 的 action → 1 张 PNG,无方向后缀
- PNG 是 sprite sheet:横向铺 `frameCount` 帧,每帧 `tileSize.w × tileSize.h` 像素

## 完整 schema 与字段含义

见 [doc/pixel-foundation.md "Sprite 资源约定"](../../doc/pixel-foundation.md#sprite-资源约定)。

## 不做的事

- **不**在本目录放真 PNG(模板就是模板,无视觉资源)
- **不**在 pubspec.yaml 启用 `assets/_template/`(本目录不进 build bundle)
- **不**写 species 专属逻辑在这里(逻辑归 `lib/features/{module}/{module}_animation_loader.dart` 等)
