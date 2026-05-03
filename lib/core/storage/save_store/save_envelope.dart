import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_envelope.freezed.dart';
part 'save_envelope.g.dart';

/// Wraps any persisted game-save [T] with metadata needed for safe migration.
///
/// `version` is the schema version of `payload` and is the field migrators
/// dispatch on (see [SaveMigrator]). Bump it whenever the freezed payload
/// schema changes; see ADR-008 for the policy.
@Freezed(genericArgumentFactories: true)
abstract class SaveEnvelope<T> with _$SaveEnvelope<T> {
  const factory SaveEnvelope({
    required int version,
    required DateTime savedAt,
    required T payload,
  }) = _SaveEnvelope<T>;

  factory SaveEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$SaveEnvelopeFromJson<T>(json, fromJsonT);
}
