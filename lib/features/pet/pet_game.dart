import 'package:cute_pixel/features/pet/components/pet_component.dart';
import 'package:cute_pixel/features/pet/pet_controller.dart';
import 'package:cute_pixel/features/pet/pet_models.dart';
import 'package:cute_pixel/shared/widgets/view_state.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';

class PetGame extends FlameGame {
  PetGame(this._controller);

  final PetController _controller;
  final Map<String, PetComponent> _components = {};
  Worker? _worker;

  @override
  Future<void> onLoad() async {
    _worker = ever<ViewState<List<Pet>>>(_controller.state, _onStateChanged);
    _onStateChanged(_controller.state.value);
  }

  @override
  void onRemove() {
    _worker?.dispose();
    super.onRemove();
  }

  void _onStateChanged(ViewState<List<Pet>> state) {
    if (state is! Data<List<Pet>>) return;
    final pets = state.data;
    final petsById = {for (final p in pets) p.id: p};

    final toRemove = _components.keys
        .where((id) => !petsById.containsKey(id))
        .toList();
    for (final id in toRemove) {
      _components.remove(id)?.removeFromParent();
    }

    for (final pet in pets) {
      final existing = _components[pet.id];
      if (existing == null) {
        final component = PetComponent(pet: pet);
        _components[pet.id] = component;
        add(component);
      } else {
        existing.applyPet(pet);
      }
    }
  }
}
