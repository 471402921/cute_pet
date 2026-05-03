---
name: cute-pixel-test-gen
description: >
  cute_pixel 系列(像素风 Flutter+GetX+Flame 架构)的模块测试生成 Skill,适用于基于 cute_pixel 底座的项目。
  当用户想给某个已有模块按 conventions §7 四层金字塔补/生成测试时使用此 Skill。
  触发场景包括:用户说 /cute-pixel-test-gen、/cute-pet-test-gen(legacy)、"给 health 写测试"、"补一下 features/pet 的测试"、
  "测试覆盖率低,生成测试"、"add tests for X"、"为这个模块加测试用例"等。
  本 Skill 只生成测试文件,不修改业务代码。
---

# cute-pixel-test-gen

按 conventions §7 的四层金字塔(domain ≥ 90% / api ≥ 80% / controller ≥ 70% / page ≥ 50%),为指定模块生成或补充测试,跑 `make test` 验证。

## 必读文档

每次执行**重新读**:

1. [doc/conventions.md](../../../doc/conventions.md) §7 — 三层金字塔 + 覆盖率指标 + mocktail 模板
2. [references/test-templates.md](references/test-templates.md) — 各层测什么、为什么、示意片段

## 工作流程

### Step 1 — 扫模块文件

读 `lib/features/{module}/`,识别要测什么:

| lib 文件 | 对应测试 | 必测? |
|---|---|---|
| `{module}_models.dart` | `test/features/{module}/{module}_models_test.dart` | ✓ |
| `{module}_api.dart` | `test/features/{module}/{module}_api_test.dart` | ✓ |
| `{module}_controller.dart` | `test/features/{module}/{module}_controller_test.dart` | ✓ |
| `{module}_page.dart` | `test/features/{module}/{module}_page_test.dart` | 关键路径才测 |

`_binding.dart` / `_route_args.dart` 通常不单独测(过简)。

### Step 2 — 读已有测试

如果对应测试已存在,**先读出来**,识别已覆盖的方法/场景。本次只补缺失的,不重写已有用例。否则会清掉用户的人工调整。

### Step 3 — 生成测试

按 [references/test-templates.md](references/test-templates.md) 的三种模板(models / api / controller)生成或补充。每层测什么:

- **models**:defaults / 值相等 / copyWith / fromJson↔toJson 往返 / enum 字符串编码
- **api**:mock 阶段测契约(返回非空、id 不重复、字段合理);真 api 时测请求构造 + 各 Failure 子类映射
- **controller**:用 mocktail mock api,每个公开方法至少 1 用例(load 三态:Data / Empty / ErrorState;每个 setXxx / updateXxx 方法各一个)
- **page**:**仅当**有用户可触发的不可逆操作(删除 / 提交)才测,测 tap → controller 调用

### Step 4 — Page 测试的判断

按 conventions §7,page 覆盖率目标 ≥ 50%,但**不为凑数写无意义的渲染快照**。判断标准:

- page 调用 `controller.<action>()` 触发副作用 → 写一个 widget 测,验证 tap 链路
- page 只读展示 → 跳过(controller 测已经验证了状态)
- 关键路径(登录 / 付款 / 删除等不可逆) → **必写**

### Step 5 — 验证

```bash
make analyze        # 测试代码也要过 lint
make test           # 全过
make test-coverage  # 看实际覆盖率
```

读 `coverage/lcov.info`,各层实际覆盖率 vs 目标对比。

### Step 6 — 报告

告诉用户:
- 创建/补充了哪些测试文件
- 用例数(新增 / 总数)
- `make test` 结果
- 各层实际覆盖率 vs 目标
- 未达标的层:**列出未覆盖的方法/分支**,**建议**用户补什么(不自动凑数测试)

### Step 7 — 不达标怎么办

如果某层覆盖率没到目标,**不要**自动再生成第二轮无意义测试(覆盖凑数 = 测试腐烂)。把缺口报给用户:
- 是哪个方法的哪个分支没覆盖
- 是不是该方法本来就不需要那么高覆盖(如纯 getter)
- 用户决定要不要补,补什么场景

## 不做

- 不改业务代码("为了好测试改一下 controller" → 不做,把问题报给用户)
- 不生成 binding / route_args 单独测试(过简)
- 不测自动生成的 `*.freezed.dart` / `*.g.dart`(freezed 自身有测)
- 不写集成测试 / E2E(超出 conventions §7,不在本 Skill)
- 不改 `analysis_options.yaml` 让测试代码能过(测试代码走同一套规范)
- 不"顺便"调用 review 或 module-gen
