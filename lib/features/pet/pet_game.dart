import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class PetGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    add(
      CircleComponent(
        radius: 48,
        position: size / 2,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.orange,
      ),
    );
  }
}
