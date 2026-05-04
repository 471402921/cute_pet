# `assets/sprites/_template/` — 角色 sprite 目录脚手架(骨架,非真物种)

> 🚨 **DEPRECATED — pixellab 决议后未重做**
>
> 本模板预先于 [asset-lab-plan.md](../../../asset-lab-plan.md) 决定写出,schema / 目录结构 / PNG 命名都跟 pixellab.ai 导出格式不一致(4 方向 vs 8 方向、sprite sheet vs frame-per-file、字段名全不同)。
> **请勿基于本模板新增 sprite**;cute-pixel-module-gen 等 skill 也不应读取本目录的 schema。
> 等首个 pixellab 导出 sprite 真要进 cute_pet 时,本模板按真实 pixellab 结构重建,届时删除本警告。

> ⚠️ 这是 cute_pixel **角色/生物类** sprite 资源的目录模板。**不是**真物种,**不要**在 pubspec.yaml 启用进 bundle。要接真 sprite 时,从这里 cp 出去改名。
>
> 道具图标走 [`assets/items/_template/`](../../items/_template/),UI 元素走 [`assets/ui/`](../../ui/),特效走 [`assets/effects/_template/`](../../effects/_template/)。

## 起新 sprite 的步骤

```bash
# 1. 拷贝模板到目标 namespace(假设 pet 模块的 pets/ namespace)
cp -r assets/sprites/_template assets/sprites/pets/shibainu

# 2. 改 **新拷出来的** assets/sprites/pets/shibainu/manifest.json
#    (不是模板原件 assets/sprites/_template/manifest.json,后者永远不动):
#    - species: "_template" → "shibainu"
#    - displayName: 替换为『柴犬』之类
#    - 各 action 的 frameCount / stepTime / directional 按你的 PNG 实际调

# 3. 出 PNG 放进 assets/sprites/pets/shibainu/(命名规则见下方)

# 4. pubspec.yaml 启用 namespace(在 flutter.assets 下加 - assets/sprites/pets/shibainu/)

# 5. make get 后在 Flame Component 里 Sprite.load('sprites/pets/shibainu/idle_south.png')
```

## 目录与 PNG 命名规则

```
assets/sprites/{namespace}/{species}/
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

## namespace 怎么取

`assets/sprites/{namespace}/` 下按业务语义分组,例如:
- `pets/` — 宠物
- `npcs/` — NPC
- `enemies/` — 敌人
- `players/` — 主控角色

不要按模块名(`features/X` 内部命名)切分——namespace 是 sprite 的**业务分类**,跨模块复用。

## 完整 schema 与字段含义

见 [doc/pixel-foundation.md "Asset 资源约定"](../../../doc/pixel-foundation.md#asset-资源约定)。

## 不做的事

- **不**在本目录放真 PNG(模板就是模板,无视觉资源)
- **不**在 pubspec.yaml 启用 `assets/sprites/_template/`(本目录不进 build bundle)
- **不**写 species 专属逻辑在这里(逻辑归 `lib/features/{module}/{module}_animation_loader.dart` 等)
