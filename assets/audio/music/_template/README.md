# `assets/audio/music/_template/` — 背景音乐目录脚手架(骨架,非真音乐)

> ⚠️ cute_pixel **背景音乐(循环播放)** 资源模板。**不是**真音乐,**不要**在 pubspec.yaml 启用。
>
> 一次性短促音效走 [`assets/audio/sfx/_template/`](../../sfx/_template/)。

## 起新音乐的步骤

```bash
# 1. 拷贝模板
cp -r assets/audio/music/_template assets/audio/music/main_theme

# 2. 文件放进 assets/audio/music/main_theme/

# 3. pubspec.yaml 启用 - assets/audio/music/main_theme/

# 4. 通过 'audio/music/main_theme/music.ogg' 加载循环播放
```

## 文件格式与命名

```
assets/audio/music/{musicId}/
└── music.ogg               # 必须,.ogg 格式
```

- 一首音乐一个目录
- 时长不限,但注意循环点(loop point)在 .ogg metadata 标记或调用方处理
- 采样率 44100Hz,**立体声**(背景音乐建议双声道)

## 依赖说明

同 [`audio/sfx/`](../../sfx/_template/) 的音频播放包说明。

## 不做

- **不**放真音乐 / **不**进 bundle
- **不**用过大文件(单首 > 5MB 应考虑流式加载,见 pubspec 说明)
