import 'package:cute_pet/features/pet/pet_models.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PetComponent extends PositionComponent {
  PetComponent({required Pet pet})
    : _pet = pet,
      super(
        position: Vector2(pet.x, pet.y),
        size: Vector2(96, 96),
        anchor: Anchor.center,
      );

  Pet _pet;
  late final RectangleComponent _body;
  late final TextComponent _label;

  @override
  Future<void> onLoad() async {
    _body = RectangleComponent(
      size: size,
      paint: Paint()..color = _colorFor(_pet.action),
    );
    _label = TextComponent(
      text: _labelFor(_pet),
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_body);
    add(_label);
  }

  void applyPet(Pet pet) {
    _pet = pet;
    position = Vector2(pet.x, pet.y);
    _body.paint.color = _colorFor(pet.action);
    _label.text = _labelFor(pet);
  }

  static String _labelFor(Pet pet) =>
      '${pet.name}\n${pet.action.name}/${pet.facing.name}';

  static Color _colorFor(PetAction action) => switch (action) {
    PetAction.idle => Colors.orange,
    PetAction.eat => Colors.green,
    PetAction.drink => Colors.blueAccent,
    PetAction.walk => Colors.amber,
    PetAction.run => Colors.deepOrange,
    PetAction.sleep => Colors.deepPurple,
  };
}
