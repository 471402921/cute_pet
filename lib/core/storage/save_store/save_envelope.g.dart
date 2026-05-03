// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SaveEnvelope<T> _$SaveEnvelopeFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _SaveEnvelope<T>(
  version: (json['version'] as num).toInt(),
  savedAt: DateTime.parse(json['savedAt'] as String),
  payload: fromJsonT(json['payload']),
);

Map<String, dynamic> _$SaveEnvelopeToJson<T>(
  _SaveEnvelope<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'version': instance.version,
  'savedAt': instance.savedAt.toIso8601String(),
  'payload': toJsonT(instance.payload),
};
