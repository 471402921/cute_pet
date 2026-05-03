/// Migrates a single step of a save schema (vN -> vN+1) for payload [T].
///
/// Migrators operate on **raw JSON maps**, not typed payloads: fields that
/// existed in the old schema may be absent from the new freezed class
/// (or vice versa), so a typed round-trip would lose data or fail.
///
/// Register a chain of migrators (v1->v2, v2->v3, ...) in DI. The store
/// composes them at load time when it sees `envelope.version < current`.
///
/// See ADR-008 for the versioning policy and the `[SaveStore]` README
/// for the registration pattern.
abstract class SaveMigrator<T> {
  const SaveMigrator();

  int get fromVersion;
  int get toVersion;

  /// Returns the JSON map upgraded from [fromVersion] to [toVersion].
  /// Input is the raw `payload` map as it was persisted; output must be
  /// shaped for the v[toVersion] schema.
  Map<String, dynamic> migrate(Map<String, dynamic> rawJson);
}
