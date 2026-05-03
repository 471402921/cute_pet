import 'package:get/get.dart';

/// 全局长生命周期服务的家。
///
/// 常见住户与注册策略:
///   - `GameClock` (planned)         → `Get.put<GameClock>(GameClock(), permanent: true)`
///                                     冷启动就要在,跨页面常驻
///   - `SaveStore<T>` (scaffolded)   → `Get.lazyPut<SaveStore<T>>(() => SaveStoreImplPrefs<T>(...))`
///                                     首次 `Get.find` 才构造,见 [core/storage/save_store/README.md]
///   - `AuthService` / `Env` / `log` (planned) → 先起对应 ADR + core TechPack 再实装注册
///
/// 注册方式速查:
///   - `Get.put<X>(X(), permanent: true)` — 必须冷启动就在的服务
///   - `Get.lazyPut<X>(() => X())`        — 首次 `Get.find` 时构造,大多数服务用这个
///   - `Get.putAsync<X>(() async => ...)` — 构造需要 `await`(如 `SharedPreferences.getInstance`)
///
/// 为什么集中在这里:避免每个 feature 自己拉基础设施(违反铁律 #3 单向依赖)。
/// 任何新 core 服务接入流程见 ADR-009 双轨流水线。
class AppBinding extends Bindings {
  @override
  void dependencies() {}
}
