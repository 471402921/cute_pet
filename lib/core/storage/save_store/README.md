# SaveStore — versioned game-save persistence

`SaveStore<T>` is a thin contract around persisting **one game save** with
a schema version travelling next to the payload. When the on-disk schema is
older than the code expects, a chain of `SaveMigrator<T>` upgrades the raw
JSON before it is decoded into the freezed `T`. See `ADR-008` for why.

## Files

| File | Role |
|---|---|
| `save_store.dart` | Abstract `SaveStore<T>` (`load` / `save` / `clear`). |
| `save_envelope.dart` | `@freezed SaveEnvelope<T>{version, savedAt, payload}`. |
| `save_migrator.dart` | Abstract `SaveMigrator<T>` (`fromVersion`/`toVersion`/`migrate(rawJson)`). |
| `save_store_impl_prefs.dart` | `shared_preferences` impl. **Status: planned** until `make add PKG=shared_preferences`. |

## Usage

```dart
// 1. Define a freezed payload (versioned by your code).
@freezed abstract class PetSave with _$PetSave { ... }

// 2. Define migrators when the schema changes.
class PetSaveV1ToV2 extends SaveMigrator<PetSave> {
  @override int get fromVersion => 1;
  @override int get toVersion => 2;
  @override Map<String, dynamic> migrate(Map<String, dynamic> raw) => {
        ...raw,
        'mood': raw['mood'] ?? 'neutral',  // new field default
      };
}

// 3. Register in DI (e.g. app_binding.dart).
Get.lazyPut<SaveStore<PetSave>>(() => SaveStoreImplPrefs<PetSave>(
      storageKey: 'pet_save',
      currentVersion: 2,
      fromJsonT: (j) => PetSave.fromJson(j! as Map<String, dynamic>),
      toJsonT: (p) => p.toJson(),
      migrators: const [PetSaveV1ToV2()],
    ));

// 4. Use from a controller.
final store = Get.find<SaveStore<PetSave>>();
final save = await store.load();    // null on first launch, else PetSave
await store.save(save!.copyWith(satiety: 80));
```

At `load()`, if the on-disk envelope's `version` is older than
`currentVersion`, the store walks `migrators` in `fromVersion` order
(v1->v2->v3->...) until the raw payload map matches `currentVersion`,
then decodes it via `fromJsonT`. Migrators take **raw maps**, not typed
payloads — old fields may not exist on the new freezed class.

## What `SaveStore` does NOT do

- **Cloud sync / multi-device** — out of scope; can wrap a different impl later.
- **Encryption** — game saves are not sensitive. Auth tokens use
  `flutter_secure_storage` (see conventions §3); game saves use this store.
- **Binary format** — JSON is fine; readability beats marginal size wins.

## Why `shared_preferences` (not `flutter_secure_storage`)

Game saves are not sensitive (no PII, no credentials), so the encryption
overhead of secure storage buys nothing. `shared_preferences` is faster on
hot-path saves (every minute or so for tick-driven state) and is the
established Flutter default. Auth tokens are different and stay on
`flutter_secure_storage` per conventions §3.

## Future work (TODOs in code)

- Real `shared_preferences` read/write — currently stubbed; needs
  `make add PKG=shared_preferences`.
- In-memory fake impl for tests (today the test exercises envelope
  round-trip only, not the full store).
- Async write debouncing / coalescing (multiple saves in one tick).
