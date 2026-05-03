import 'dart:async';

import 'package:get/get.dart';

/// One tick of the global game clock.
class Tick {
  const Tick(this.now, this.sinceLastTick);

  final DateTime now;
  final Duration sinceLastTick;
}

/// Central time source for all time-driven game logic.
///
/// Subscribe to [tick1s], [tick1m] or [tick10m] depending on cadence —
/// avoid waking per-second consumers for hour-scale logic.
///
/// On resume / cold start, call [catchUp] with the last persisted timestamp
/// to learn how much real time elapsed; let the consumer decide how many
/// ticks of business state to apply.
///
/// MVP: pure Dart, no extra dependencies. See TODOs for future work.
class GameClock extends GetxService {
  GameClock({DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final DateTime Function() _now;

  late final Stream<Tick> tick1s = _periodic(const Duration(seconds: 1));
  late final Stream<Tick> tick1m = _periodic(const Duration(minutes: 1));
  late final Stream<Tick> tick10m = _periodic(const Duration(minutes: 10));

  Stream<Tick> _periodic(Duration period) {
    DateTime? last;
    return Stream<Tick>.periodic(period, (_) {
      final now = _now();
      final delta = last == null ? period : now.difference(last!);
      last = now;
      return Tick(now, delta);
    }).asBroadcastStream();
  }

  /// Elapsed time since [lastSavedAt]. Returns [Duration.zero] when the
  /// stamp is in the future (clock skew / wrong-timezone restore).
  Duration catchUp(DateTime lastSavedAt) {
    final delta = _now().difference(lastSavedAt);
    return delta.isNegative ? Duration.zero : delta;
  }

  // TODO(future): pause/resume + speed multiplier (for tests & debug).
  // TODO(future): subscribe to AppLifecycleState — auto-emit a catch-up
  //   tick when app returns from background.
  // TODO(future): expose a Stream<Tick> at arbitrary period so consumers
  //   with unusual cadence don't have to multiplex manually.
}
