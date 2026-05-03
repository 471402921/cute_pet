# `assets/fonts/_template/` — 像素字体目录脚手架(骨架,非真字体)

> ⚠️ cute_pixel **字体**资源模板。**不是**真字体,**不要**在 pubspec.yaml 启用。
>
> 像素艺术 app 通常用**位图字体**(BMFont)而非 TTF——TTF 缩放会反锯齿,破坏像素纯度。

## 起新字体的步骤

### 选项 A:位图字体(推荐,像素纯度好)

```bash
# 1. 拷贝模板
cp -r assets/fonts/_template assets/fonts/pixel_zh

# 2. 用 BMFont / hiero 等工具导出:
#    - font.fnt(字符 metric 描述,纯文本)
#    - font.png(字符图集 sprite sheet)

# 3. pubspec.yaml 启用 - assets/fonts/pixel_zh/

# 4. 加载需配合包(如 flame_bitmap_font 或自写解析)
```

### 选项 B:TTF 字体(常规 Flutter 字体)

```bash
# 1. 拷贝模板
cp -r assets/fonts/_template assets/fonts/pixel_ttf

# 2. 放进 font.ttf

# 3. pubspec.yaml 用 fonts 段(不是 assets):
#    fonts:
#      - family: PixelZh
#        fonts:
#          - asset: assets/fonts/pixel_ttf/font.ttf

# 4. Flutter 内通过 TextStyle(fontFamily: 'PixelZh') 使用
```

## 目录结构

```
assets/fonts/{fontId}/
├── font.fnt                # 选项 A:BMFont 描述
├── font.png                # 选项 A:字符图集
└── font.ttf                # 选项 B:TTF 字体文件
```

(实际只取一种方案)

## 依赖说明

位图字体加载需自写解析或引入第三方包,首个用到时起 ADR。

## 不做

- **不**放真字体 / **不**进 bundle
- **不**用 TTF 渲染过小字号(< 12px 像素纯度差,改用位图字体)
