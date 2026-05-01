import 'package:cute_pet/features/pet/pet_models.dart';

class PetApi {
  Future<List<Pet>> fetchPets() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      Pet(
        id: 'pet-1',
        name: 'Mochi',
        species: PetSpecies.shibainu,
        x: 100,
        y: 220,
      ),
      Pet(id: 'pet-2', name: 'Yuki', species: PetSpecies.corgi, x: 240, y: 220),
    ];
  }
}
