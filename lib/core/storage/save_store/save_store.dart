import 'package:cute_pixel/core/storage/save_store/save_envelope.dart';

/// Persistent store for a typed game-save payload [T].
///
/// [T] is supplied by the caller as a freezed class with `fromJson`/`toJson`.
/// Implementations wrap reads/writes in a [SaveEnvelope] so the schema
/// version travels with the payload (see ADR-008).
///
/// Concrete impls live alongside this file, e.g. [SaveStoreImplPrefs] for
/// `shared_preferences`. Callers depend on this abstract type only.
abstract class SaveStore<T> {
  /// Returns the persisted payload, or `null` if nothing was saved yet.
  /// On version mismatch, runs the registered migrator chain
  /// (oldVersion -> ... -> currentVersion) before decoding to [T].
  Future<T?> load();

  /// Persists [data], stamped with the current schema version and `now`.
  Future<void> save(T data);

  /// Removes the saved payload (used on logout / "reset save" actions).
  Future<void> clear();
}
