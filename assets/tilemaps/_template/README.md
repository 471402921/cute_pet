# `assets/tilemaps/_template/` — 瓦片地图目录脚手架(骨架,非真地图)

> ⚠️ cute_pixel **瓦片地图**资源模板(配合 [Tiled](https://www.mapeditor.org/) 编辑器使用)。**不是**真地图,**不要**在 pubspec.yaml 启用。
>
> 静态背景图(无瓦片复用)走 [`assets/scenes/_template/`](../../scenes/_template/);本目录是可编辑、可重复瓦片的地图数据。

## 起新地图的步骤

```bash
# 1. 拷贝模板
cp -r assets/tilemaps/_template assets/tilemaps/forest

# 2. 用 Tiled 编辑器:
#    - 打开 assets/tilemaps/forest/map.tmx
#    - 替换 tileset.png 为你的瓦片集
#    - 编辑地图层

# 3. 导出 .json(File → Export As → JSON map files)到同目录

# 4. pubspec.yaml 启用 - assets/tilemaps/forest/

# 5. 在 Flame 用 flame_tiled 加载 'tilemaps/forest/map.json'
```

## 目录与文件命名规则

```
assets/tilemaps/{mapId}/
├── map.tmx                 # Tiled 工程文件(开发用,可不进 bundle)
├── map.json                # 必须,运行时加载格式
└── tileset.png             # 必须,瓦片图集(被 map.json 引用)
```

- 多 tileset 的地图 → 多个 `tileset_*.png`,在 .tmx/.json 中按相对路径引用
- 推荐瓦片大小:16×16 或 32×32(像素整倍)

## 依赖说明

需要 [`flame_tiled`](https://pub.dev/packages/flame_tiled) 包(本仓库默认未添加;首个用到时通过 `make add PKG=flame_tiled` 加入,并起一个 ADR 记录)。

## 不做

- **不**放真资源 / **不**进 bundle
- **不**把单图背景做成 tilemap(那是过度设计)
