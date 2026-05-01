import 'package:cute_pet/features/pet/pet_api.dart';
import 'package:cute_pet/features/pet/pet_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetApi (mock)', () {
    late PetApi api;

    setUp(() {
      api = PetApi();
    });

    test('returns at least one pet', () async {
      final pets = await api.fetchPets();
      expect(pets, isNotEmpty);
    });

    test('returned pets have unique ids', () async {
      final pets = await api.fetchPets();
      final ids = pets.map((p) => p.id).toSet();
      expect(ids.length, pets.length);
    });

    test('all pets default to idle action', () async {
      final pets = await api.fetchPets();
      for (final pet in pets) {
        expect(pet.action, PetAction.idle);
      }
    });
  });
}
