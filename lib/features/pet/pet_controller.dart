import 'dart:async';

import 'package:cute_pet/core/error/failures.dart';
import 'package:cute_pet/features/pet/pet_api.dart';
import 'package:cute_pet/features/pet/pet_models.dart';
import 'package:cute_pet/shared/widgets/view_state.dart';
import 'package:get/get.dart';

class PetController extends GetxController {
  PetController(this._api);

  final PetApi _api;

  final state = Rx<ViewState<List<Pet>>>(const ViewState.loading());
  final selectedId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const ViewState.loading();
    try {
      final pets = await _api.fetchPets();
      state.value = pets.isEmpty
          ? const ViewState.empty()
          : ViewState.data(pets);
      if (selectedId.value == null && pets.isNotEmpty) {
        selectedId.value = pets.first.id;
      }
    } on Failure catch (f) {
      state.value = ViewState.error(f);
    }
  }

  void select(String petId) {
    selectedId.value = petId;
  }

  void setAction(String petId, PetAction action) {
    _updatePet(petId, (p) => p.copyWith(action: action));
  }

  void setFacing(String petId, PetDirection direction) {
    _updatePet(petId, (p) => p.copyWith(facing: direction));
  }

  void _updatePet(String petId, Pet Function(Pet) update) {
    final current = state.value;
    if (current is! Data<List<Pet>>) return;
    final updated = [
      for (final p in current.data) p.id == petId ? update(p) : p,
    ];
    state.value = ViewState.data(updated);
  }
}
