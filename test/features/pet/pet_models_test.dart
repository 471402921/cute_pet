import 'package:cute_pixel/features/pet/pet_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pet', () {
    test('defaults action to idle and facing to south', () {
      const pet = Pet(
        id: 'p1',
        name: 'Mochi',
        species: PetSpecies.shibainu,
        x: 100,
        y: 200,
      );
      expect(pet.action, PetAction.idle);
      expect(pet.facing, PetDirection.south);
    });

    test('value equality across instances with same fields', () {
      const a = Pet(
        id: 'p1',
        name: 'Mochi',
        species: PetSpecies.shibainu,
        x: 1,
        y: 2,
      );
      const b = Pet(
        id: 'p1',
        name: 'Mochi',
        species: PetSpecies.shibainu,
        x: 1,
        y: 2,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith only changes specified fields', () {
      const original = Pet(
        id: 'p1',
        name: 'Mochi',
        species: PetSpecies.shibainu,
        x: 0,
        y: 0,
      );
      final updated = original.copyWith(action: PetAction.eat);
      expect(updated.action, PetAction.eat);
      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.facing, original.facing);
    });

    test('toJson then fromJson is round-trip stable', () {
      const original = Pet(
        id: 'p1',
        name: 'Mochi',
        species: PetSpecies.shibainu,
        x: 12.5,
        y: 34.5,
        action: PetAction.eat,
        facing: PetDirection.east,
      );
      final json = original.toJson();
      final restored = Pet.fromJson(json);
      expect(restored, equals(original));
    });

    test('JSON encodes enums as string names', () {
      const pet = Pet(
        id: 'p1',
        name: 'Mochi',
        species: PetSpecies.corgi,
        x: 0,
        y: 0,
        action: PetAction.sleep,
        facing: PetDirection.north,
      );
      final json = pet.toJson();
      expect(json['species'], 'corgi');
      expect(json['action'], 'sleep');
      expect(json['facing'], 'north');
    });
  });
}
