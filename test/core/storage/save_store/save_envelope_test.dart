import 'package:cute_pixel/core/storage/save_store/save_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

class _DummyPayload {
  const _DummyPayload(this.satiety, this.name);
  final int satiety;
  final String name;

  Map<String, dynamic> toJson() => {'satiety': satiety, 'name': name};

  factory _DummyPayload.fromJson(Object? json) {
    final m = json! as Map<String, dynamic>;
    return _DummyPayload(m['satiety'] as int, m['name'] as String);
  }
}

void main() {
  group('SaveEnvelope', () {
    test('round-trips fromJson/toJson and preserves version/savedAt', () {
      final original = SaveEnvelope<_DummyPayload>(
        version: 3,
        savedAt: DateTime.utc(2026, 5, 3, 12),
        payload: const _DummyPayload(80, 'shibainu'),
      );

      final json = original.toJson((p) => p.toJson());
      final restored = SaveEnvelope<_DummyPayload>.fromJson(
        json,
        _DummyPayload.fromJson,
      );

      expect(restored.version, 3);
      expect(restored.savedAt, DateTime.utc(2026, 5, 3, 12));
      expect(restored.payload.satiety, 80);
      expect(restored.payload.name, 'shibainu');
    });
  });
}
