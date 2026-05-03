# `assets/ui/buttons/_template/` — 按钮目录脚手架(骨架,非真按钮)

> ⚠️ cute_pixel **按钮**资源模板。**不是**真按钮,**不要**在 pubspec.yaml 启用。
>
> 单图标走 [`assets/ui/icons/_template/`](../../icons/_template/),9-slice 弹窗边框走 [`assets/ui/frames/_template/`](../../frames/_template/)。

## 起新按钮的步骤

```bash
# 1. 拷贝模板
cp -r assets/ui/buttons/_template assets/ui/buttons/primary

# 2. 出 PNG(命名规则见下方)放进 assets/ui/buttons/primary/

# 3. pubspec.yaml 启用 - assets/ui/buttons/primary/

# 4. 通过 'ui/buttons/primary/normal.png' 加载
```

## 目录与 PNG 命名规则

```
assets/ui/buttons/{buttonId}/
├── normal.png              # 必须,默认状态
├── pressed.png             # 必须,按下状态
├── disabled.png            # 可选,禁用状态
└── hover.png               # 可选(桌面/web 才有意义)
```

- 同一按钮三种状态 PNG **像素尺寸必须一致**(避免按下时跳位)
- 9-slice 边距如有,在 widget 调用处显式声明,本目录不存元数据

## 不做

- **不**在本目录放真 PNG
- **不**在 pubspec.yaml 启用 `assets/ui/buttons/_template/`
- **不**把业务图标当按钮(业务图标如食物图标走 `assets/items/`)
