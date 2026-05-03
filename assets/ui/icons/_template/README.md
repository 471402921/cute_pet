# `assets/ui/icons/_template/` — UI 图标目录脚手架(骨架,非真图标)

> ⚠️ cute_pixel **UI 图标**资源模板。**不是**真图标,**不要**在 pubspec.yaml 启用。
>
> 业务图标(食物、装备等)走 [`assets/items/_template/`](../../../items/_template/);多状态按钮走 [`assets/ui/buttons/_template/`](../buttons/_template/)。

## 起新图标的步骤

```bash
# 1. 拷贝模板
cp -r assets/ui/icons/_template assets/ui/icons/settings

# 2. 出 PNG 放进 assets/ui/icons/settings/(命名见下方)

# 3. pubspec.yaml 启用 - assets/ui/icons/settings/

# 4. 通过 'ui/icons/settings/icon.png' 加载
```

## 目录与 PNG 命名规则

```
assets/ui/icons/{iconId}/
└── icon.png                # 必须,单帧像素图标
```

- 像素图标尺寸建议是 8 的倍数(8/16/24/32/48...),便于整数缩放
- 单图标无 manifest——目录名即语义,简单到不用元数据

## namespace 怎么取

按界面区域或功能分:
- 直接平铺(`settings`、`back`、`close` 等通用图标)
- 或子目录分组,如 `assets/ui/icons/nav/`、`assets/ui/icons/social/`

## 不做

- **不**放真 PNG / **不**进 bundle
- **不**把多状态按钮塞进来(那是 buttons/)
