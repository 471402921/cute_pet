# `assets/items/_template/` — 道具图标目录脚手架(骨架,非真道具)

> ⚠️ 这是 cute_pixel **道具/物品类**资源的目录模板。**不是**真道具,**不要**在 pubspec.yaml 启用。要起新道具时从这里 cp 改名。
>
> 道具类型例:食物、玩具、装备、收藏品、货币图标。需要复杂动画时(如稀有道具旋转特效)走 [`assets/sprites/_template/`](../../sprites/_template/) 反而更合适。

## 起新道具的步骤

```bash
# 1. 拷贝模板到目标 namespace(如食物类)
cp -r assets/items/_template assets/items/food/apple

# 2. 改 **新拷出来的** assets/items/food/apple/manifest.json
#    (不是模板原件 assets/items/_template/manifest.json,后者永远不动):
#    - itemId: "_template" → "apple"
#    - displayName: 替换为『苹果』之类
#    - category / rarity 按业务调

# 3. 出 PNG 放进 assets/items/food/apple/(命名规则见下方)

# 4. pubspec.yaml 启用 namespace(在 flutter.assets 下加 - assets/items/food/apple/)

# 5. make get 后通过 'items/food/apple/icon.png' 加载
```

## 目录与 PNG 命名规则

```
assets/items/{category}/{itemId}/
├── manifest.json           # 必须,本文件结构
├── icon.png                # 必须,主图标(单帧或 sprite sheet)
└── icon@2x.png             # 可选,高清版本(2x DPI)
```

- 默认 icon **单帧 PNG**;若 manifest 标了 `frameCount > 1`,则按 sprite sheet 处理
- 像素资源不要给真 @2x/@3x(像素艺术应保留锯齿,缩放走 Flutter 的 nearest-neighbor)

## namespace 怎么取

`assets/items/{category}/` 按业务分类,例如:
- `food/` — 食物
- `toys/` — 玩具
- `equipment/` — 装备
- `currency/` — 货币

## 不做

- **不**在本目录放真 PNG
- **不**在 pubspec.yaml 启用 `assets/items/_template/`
- **不**写业务逻辑(道具效果/数值归 `lib/features/{module}/{module}_models.dart`)
