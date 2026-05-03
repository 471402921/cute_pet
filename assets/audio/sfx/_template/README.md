# `assets/audio/sfx/_template/` — 音效目录脚手架(骨架,非真音效)

> ⚠️ cute_pixel **音效(短促一次性)** 资源模板。**不是**真音效,**不要**在 pubspec.yaml 启用。
>
> 循环播放的背景音乐走 [`assets/audio/music/_template/`](../music/_template/)。

## 起新音效的步骤

```bash
# 1. 拷贝模板
cp -r assets/audio/sfx/_template assets/audio/sfx/click

# 2. 文件放进 assets/audio/sfx/click/(命名见下方)

# 3. pubspec.yaml 启用 - assets/audio/sfx/click/

# 4. 通过 'audio/sfx/click/sfx.ogg' 加载播放
```

## 文件格式与命名

```
assets/audio/sfx/{sfxId}/
└── sfx.ogg                 # 必须,推荐 .ogg(体积小,跨平台兼容好)
```

- 单一音效一个目录,目录名即语义
- 时长建议 < 2 秒;长于此应放 `audio/music/`
- 采样率 44100Hz,单声道(节省体积)

## 依赖说明

需要音频播放包(本仓库默认未添加),候选:
- [`audioplayers`](https://pub.dev/packages/audioplayers) — 通用 Flutter 音频
- [`flame_audio`](https://pub.dev/packages/flame_audio) — Flame 集成

首个用到时通过 `make add PKG=...` 加入,并起一个 ADR。

## 不做

- **不**放真音频 / **不**进 bundle
- **不**用 .mp3(授权问题 + iOS Web 兼容差,统一 .ogg)
