# 测试指引

按需读:Step 3 生成测试时打开。本文件给**每层测什么、为什么测、示意片段**——不给完整可粘贴模板。

## 总原则

测试是为了**发现回归**,不是为了**凑覆盖率**。每个用例要能回答:"这个测试挂了说明哪里坏了?" —— 答不出来的测试是冗余,不要写。

## models 层 — 5 个值得测的不变量

freezed 自动生成 `==` / `copyWith` / `fromJson` / `toJson`。手没写的代码也会出 bug,但只有这 5 类:

| 不变量 | 挂了说明什么 |
|---|---|
| **defaults 生效** | `@Default(...)` 没写或写错 |
| **值相等** | 字段顺序错、漏字段、`==` mixin 没拿对 |
| **copyWith 只改指定字段** | freezed 链路坏了 |
| **fromJson↔toJson 往返稳定** | JSON 字段名变了 / 类型不匹配 |
| **enum 编码为字符串名** | 后端契约对齐(int 编码会跟后端冲突) |

每加新字段,把它塞进往返用例,5 项基本就够。

**示意片段**(单条):

```dart
test('value equality across instances with same fields', () {
  const a = SomeItem(id: 'x', /* ... */);
  const b = SomeItem(id: 'x', /* ... */);
  expect(a, equals(b));
  expect(a.hashCode, equals(b.hashCode));
});
```

## api 层 — 测契约

**MVP mock 阶段**:验证 mock 提供的契约(返回非空、id 唯一、字段范围合理)。这些挂了说明 mock 数据被改坏。

**真 api 阶段**(接 Dio 后):
- 测请求构造(URL、headers、body)
- 测各 HTTP 状态码 → Failure 子类的映射(401→AuthFailure、422→ValidationFailure、超时→NetworkFailure 等)
- 用 mocktail mock 整个 `Dio`

**示意片段**(真 api 错误映射):

```dart
test('throws NetworkFailure on connection timeout', () async {
  when(() => dio.get(any())).thenThrow(
    DioException(type: DioExceptionType.connectionTimeout, requestOptions: ...),
  );
  expect(api.fetchItems(), throwsA(isA<NetworkFailure>()));
});
```

## controller 层 — 每个公开方法至少 1 用例

**必测**:
- `load()` 三态各 1:Data(成功)、Empty(返回空)、ErrorState(api 抛 Failure)
- 每个 `setXxx` / `updateXxx` 方法 1 用例,验证只改目标实体不影响其它

**通用模板要素**:
- mocktail 的 `Mock` + `when().thenAnswer()`,无 build_runner
- `tearDown` 调 `controller.dispose()` 释放 Worker
- 状态断言用 `isA<Data<List<X>>>()` 然后强转取 `.data`

**示意片段**:

```dart
class _MockApi extends Mock implements SomeApi {}

void main() {
  late _MockApi api;
  late SomeController controller;

  setUp(() {
    api = _MockApi();
    controller = SomeController(api);
  });
  tearDown(() => controller.dispose());

  test('load() emits Data on success', () async {
    when(() => api.fetchItems()).thenAnswer((_) async => [/* mock */]);
    await controller.load();
    expect(controller.state.value, isA<Data<List<SomeItem>>>());
  });
}
```

## page 层 — 仅关键路径

按 conventions §7,page 覆盖率目标 50%,但**不为凑数写无意义渲染快照**。

**判断标准**:
- page 调 `controller.<action>()` 触发副作用 → 写一个 widget 测,验证 tap 链路
- page 只读展示 → 跳过(controller 测已经覆盖了状态变化)
- 关键不可逆操作(删除 / 提交 / 付款 / 登录) → **必写**

**示意片段**(tap 链路):

```dart
testWidgets('tapping submit triggers controller.submit', (tester) async {
  final controller = _MockSomeController();
  Get.put<SomeController>(controller);
  await tester.pumpWidget(GetMaterialApp(home: const SomePage()));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('submit-button')));
  verify(() => controller.submit()).called(1);
  Get.reset();
});
```

**注意 l10n**:测试环境 `Get.deviceLocale` 通常 null,走英文 fallback。如果断言文案,用英文字符串(或加 `Key` 用 byKey 找,跟语言无关,推荐)。

## 写测试前自问

- 这个测试挂了,我能立刻知道哪里坏了吗?(不能 → 不写)
- 同一种 bug 已经被另一个测试覆盖了吗?(是 → 不重复)
- 这是测我写的代码,还是测 freezed/mocktail/Flutter 自身?(测框架自己 → 不写)
