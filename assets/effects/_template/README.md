# `assets/effects/_template/` — 特效动画目录脚手架(骨架,非真特效)

> ⚠️ cute_pixel **特效**资源模板(粒子帧动画、过渡效果、技能光效等)。**不是**真特效,**不要**在 pubspec.yaml 启用。

## 起新特效的步骤

```bash
# 1. 拷贝模板
cp -r assets/effects/_template assets/effects/sparkle

# 2. 改 manifest.json 的 frameCount / stepTime / loop 字段

# 3. 出 PNG sprite sheet 放进 assets/effects/sparkle/

# 4. pubspec.yaml 启用 - assets/effects/sparkle/

# 5. 通过 'effects/sparkle/effect.png' 加载,按 manifest 解析帧
```

## 目录与 PNG 命名规则

```
assets/effects/{effectId}/
├── manifest.json           # 必须,动画元数据
└── effect.png              # 必须,sprite sheet(横向铺 frameCount 帧)
```

`manifest.json` 字段:

```json
{
  "effectId": "_template",
  "tileSize": { "w": 32, "h": 32 },
  "frameCount": 8,
  "stepTime": 0.06,
  "loop": false
}
```

- `loop: false` → 一次性播放完销毁(典型如击中特效)
- `loop: true` → 循环播放(典型如 buff 光环)
- 多张 PNG 的复合特效(底/中/顶层叠加),拆成多个 effectId

## 不做

- **不**放真 PNG / **不**进 bundle
- **不**把角色动画当特效(角色动画走 `assets/sprites/`)
