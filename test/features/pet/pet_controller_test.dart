import 'package:cute_pixel/core/error/failures.dart';
import 'package:cute_pixel/features/pet/pet_api.dart';
import 'package:cute_pixel/features/pet/pet_controller.dart';
import 'package:cute_pixel/features/pet/pet_models.dart';
import 'package:cute_pixel/shared/widgets/view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPetApi extends Mock implements PetApi {}

void main() {
  group('PetController', () {
    late _MockPetApi api;
    late PetController controller;

    setUp(() {
      api = _MockPetApi();
      controller = PetController(api);
    });

    tearDown(() {
      controller.dispose();
    });

    test('load() emits Data and selects first pet on success', () async {
      const pets = [
        Pet(id: 'p1', name: 'Mochi', species: PetSpecies.shibainu, x: 0, y: 0),
        Pet(id: 'p2', name: 'Yuki', species: PetSpecies.corgi, x: 50, y: 0),
      ];
      when(() => api.fetchPets()).thenAnswer((_) async => pets);

      await controller.load();

      final state = controller.state.value;
      expect(state, isA<Data<List<Pet>>>());
      expect((state as Data<List<Pet>>).data, pets);
      expect(controller.selectedId.value, 'p1');
    });

    test('load() emits Empty on empty list', () async {
      when(() => api.fetchPets()).thenAnswer((_) async => const <Pet>[]);

      await controller.load();

      expect(controller.state.value, isA<Empty<List<Pet>>>());
      expect(controller.selectedId.value, isNull);
    });

    test('load() emits ErrorState when api throws Failure', () async {
      const failure = NetworkFailure('boom');
      when(() => api.fetchPets()).thenThrow(failure);

      await controller.load();

      final state = controller.state.value;
      expect(state, isA<ErrorState<List<Pet>>>());
      expect((state as ErrorState<List<Pet>>).failure, failure);
    });

    test('setAction updates only the matching pet', () async {
      const pets = [
        Pet(id: 'p1', name: 'Mochi', species: PetSpecies.shibainu, x: 0, y: 0),
        Pet(id: 'p2', name: 'Yuki', species: PetSpecies.corgi, x: 50, y: 0),
      ];
      when(() => api.fetchPets()).thenAnswer((_) async => pets);
      await controller.load();

      controller.setAction('p1', PetAction.eat);

      final state = controller.state.value as Data<List<Pet>>;
      expect(state.data[0].action, PetAction.eat);
      expect(state.data[1].action, PetAction.idle);
    });

    test('setFacing updates only the matching pet', () async {
      const pets = [
        Pet(id: 'p1', name: 'Mochi', species: PetSpecies.shibainu, x: 0, y: 0),
      ];
      when(() => api.fetchPets()).thenAnswer((_) async => pets);
      await controller.load();

      controller.setFacing('p1', PetDirection.north);

      final state = controller.state.value as Data<List<Pet>>;
      expect(state.data.first.facing, PetDirection.north);
    });

    test('select changes selectedId', () {
      controller.select('p2');
      expect(controller.selectedId.value, 'p2');
    });
  });
}
