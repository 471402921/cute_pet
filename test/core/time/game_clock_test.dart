import 'package:cute_pixel/core/time/game_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameClock.catchUp', () {
    test('returns elapsed Duration when lastSavedAt is in the past', () {
      final fixedNow = DateTime(2026, 5, 3, 12);
      final clock = GameClock(clock: () => fixedNow);

      final elapsed = clock.catchUp(
        fixedNow.subtract(const Duration(minutes: 35)),
      );

      expect(elapsed, const Duration(minutes: 35));
    });

    test('returns Duration.zero when lastSavedAt is in the future', () {
      final fixedNow = DateTime(2026, 5, 3, 12);
      final clock = GameClock(clock: () => fixedNow);

      final elapsed = clock.catchUp(fixedNow.add(const Duration(hours: 1)));

      expect(elapsed, Duration.zero);
    });

    test('returns Duration.zero when lastSavedAt equals now (no skew)', () {
      final fixedNow = DateTime(2026, 5, 3, 12);
      final clock = GameClock(clock: () => fixedNow);

      expect(clock.catchUp(fixedNow), Duration.zero);
    });
  });

  group('GameClock streams', () {
    test('exposes broadcast streams that consumers can subscribe to', () {
      final clock = GameClock();

      expect(clock.tick1s.isBroadcast, isTrue);
      expect(clock.tick1m.isBroadcast, isTrue);
      expect(clock.tick10m.isBroadcast, isTrue);
    });
  });
}
