# `assets/ui/frames/_template/` — 9-slice 边框/弹窗目录脚手架(骨架,非真边框)

> ⚠️ cute_pixel **9-slice 边框**资源模板(用于弹窗、面板、对话气泡等)。**不是**真边框,**不要**在 pubspec.yaml 启用。

## 起新 frame 的步骤

```bash
# 1. 拷贝模板
cp -r assets/ui/frames/_template assets/ui/frames/dialog

# 2. 出 PNG 放进 assets/ui/frames/dialog/

# 3. pubspec.yaml 启用 - assets/ui/frames/dialog/

# 4. 在 widget 调用处声明 9-slice 边距(N9PatchImage 或自定义 NinePatch)
```

## 目录与 PNG 命名规则

```
assets/ui/frames/{frameId}/
├── frame.png               # 必须,完整一张图(含四角+四边+中心)
└── slice.json              # 可选,9-slice 边距声明(left/top/right/bottom 像素)
```

- `slice.json` 示例:`{"left": 8, "top": 8, "right": 8, "bottom": 8}`
- 没有 slice.json → 调用方自己传 EdgeInsets
- 设计 frame 时**四角必须为像素整倍**,边可拉伸,中心可平铺

## 不做

- **不**放真 PNG / **不**进 bundle
- **不**把背景图当 frame(背景图走 `assets/scenes/`)
- **不**写阴影模糊等非像素风元素(违反像素纯度)
