import 'dart:async';
import 'dart:convert';

import 'package:cute_pixel/core/storage/save_store/save_envelope.dart';
import 'package:cute_pixel/core/storage/save_store/save_migrator.dart';
import 'package:cute_pixel/core/storage/save_store/save_store.dart';

// TODO(deps): shared_preferences is `planned`; run
//   `make add PKG=shared_preferences`
// before enabling this implementation. Until then this file is a
// design-only skeleton and will not compile if uncommented.
//
// import 'package:shared_preferences/shared_preferences.dart';

/// `shared_preferences`-backed [SaveStore] implementation.
///
/// Stores one [SaveEnvelope] per [storageKey] as a JSON string. On [load]:
///   1. Read the raw JSON.
///   2. Inspect `version`. If older than [currentVersion], walk
///      [migrators] in `fromVersion` order, applying each `migrate(...)`
///      to the raw payload map until it matches `currentVersion`.
///   3. Decode the upgraded map via [fromJsonT] into the typed payload.
///
/// See `README.md` (this directory) for the full lifecycle and DI pattern.
class SaveStoreImplPrefs<T> implements SaveStore<T> {
  SaveStoreImplPrefs({
    required this.storageKey,
    required this.currentVersion,
    required this.fromJsonT,
    required this.toJsonT,
    this.migrators = const [],
  });

  final String storageKey;
  final int currentVersion;
  final T Function(Object? json) fromJsonT;
  final Object? Function(T value) toJsonT;
  final List<SaveMigrator<T>> migrators;

  @override
  Future<T?> load() async {
    // TODO(deps): replace with real shared_preferences read.
    //   final prefs = await SharedPreferences.getInstance();
    //   final raw = prefs.getString(storageKey);
    const String? raw = null;
    if (raw == null) return null;

    final envelope = SaveEnvelope<T>.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
      fromJsonT,
    );

    if (envelope.version == currentVersion) return envelope.payload;

    // Re-decode payload as raw map and walk the migrator chain.
    final rawDecoded = jsonDecode(raw) as Map<String, dynamic>;
    var payloadMap = rawDecoded['payload'] as Map<String, dynamic>;
    var version = envelope.version;

    while (version < currentVersion) {
      final step = migrators.firstWhere(
        (m) => m.fromVersion == version,
        orElse: () => throw StateError(
          'No migrator from v$version (target v$currentVersion) for '
          '"$storageKey"',
        ),
      );
      payloadMap = step.migrate(payloadMap);
      version = step.toVersion;
    }

    return fromJsonT(payloadMap);
  }

  @override
  Future<void> save(T data) async {
    final envelope = SaveEnvelope<T>(
      version: currentVersion,
      savedAt: DateTime.now(),
      payload: data,
    );
    final raw = jsonEncode(envelope.toJson(toJsonT));

    // TODO(deps): replace with real shared_preferences write.
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.setString(storageKey, raw);
    // Skeleton no-op so callers compile against the abstract type.
    // ignore: unused_local_variable
    final _ = raw;
  }

  @override
  Future<void> clear() async {
    // TODO(deps): replace with real shared_preferences remove.
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.remove(storageKey);
  }
}
