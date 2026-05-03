import 'dart:convert';

import 'package:cute_pixel/core/storage/save_store/save_migrator.dart';
import 'package:cute_pixel/core/storage/save_store/save_store_impl_prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestPayload {
  const _TestPayload({required this.satiety, this.mood = 'neutral'});

  final int satiety;
  final String mood;

  Map<String, dynamic> toJson() => {'satiety': satiety, 'mood': mood};

  factory _TestPayload.fromJson(Object? json) {
    final m = json! as Map<String, dynamic>;
    return _TestPayload(
      satiety: m['satiety'] as int,
      mood: (m['mood'] as String?) ?? 'neutral',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _TestPayload && other.satiety == satiety && other.mood == mood;

  @override
  int get hashCode => Object.hash(satiety, mood);
}

class _V1ToV2 extends SaveMigrator<_TestPayload> {
  const _V1ToV2();
  @override
  int get fromVersion => 1;
  @override
  int get toVersion => 2;
  @override
  Map<String, dynamic> migrate(Map<String, dynamic> rawJson) => {
    ...rawJson,
    'mood': 'happy',
  };
}

class _V2ToV3 extends SaveMigrator<_TestPayload> {
  const _V2ToV3();
  @override
  int get fromVersion => 2;
  @override
  int get toVersion => 3;
  @override
  Map<String, dynamic> migrate(Map<String, dynamic> rawJson) => rawJson;
}

const _storageKey = 'test_save_store';

String _envelopeJson({
  required int version,
  required Map<String, dynamic> payload,
  String savedAt = '2026-05-03T12:00:00.000Z',
}) =>
    jsonEncode({'version': version, 'savedAt': savedAt, 'payload': payload});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SaveStoreImplPrefs', () {
    test('load returns null when key absent', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SaveStoreImplPrefs<_TestPayload>(
        storageKey: _storageKey,
        currentVersion: 1,
        fromJsonT: _TestPayload.fromJson,
        toJsonT: (p) => p.toJson(),
      );

      expect(await store.load(), isNull);
    });

    test('save then load round-trips payload', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SaveStoreImplPrefs<_TestPayload>(
        storageKey: _storageKey,
        currentVersion: 1,
        fromJsonT: _TestPayload.fromJson,
        toJsonT: (p) => p.toJson(),
      );

      const written = _TestPayload(satiety: 80, mood: 'happy');
      await store.save(written);

      expect(await store.load(), written);
    });

    test('load walks migrator chain from v1 to current', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: _envelopeJson(
          version: 1,
          payload: {'satiety': 50},
        ),
      });
      final store = SaveStoreImplPrefs<_TestPayload>(
        storageKey: _storageKey,
        currentVersion: 2,
        fromJsonT: _TestPayload.fromJson,
        toJsonT: (p) => p.toJson(),
        migrators: const [_V1ToV2()],
      );

      final loaded = await store.load();

      expect(loaded, isNotNull);
      expect(loaded!.satiety, 50);
      expect(loaded.mood, 'happy');
    });

    test('load throws StateError when migrator missing in chain', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: _envelopeJson(
          version: 1,
          payload: {'satiety': 50},
        ),
      });
      final store = SaveStoreImplPrefs<_TestPayload>(
        storageKey: _storageKey,
        currentVersion: 3,
        fromJsonT: _TestPayload.fromJson,
        toJsonT: (p) => p.toJson(),
        migrators: const [_V2ToV3()],
      );

      await expectLater(
        store.load(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('v1'), contains(_storageKey)),
          ),
        ),
      );
    });
  });
}
