import 'package:cute_pixel/features/pet/pet_controller.dart';
import 'package:cute_pixel/features/pet/pet_game.dart';
import 'package:cute_pixel/features/pet/pet_models.dart';
import 'package:cute_pixel/l10n/app_localizations.dart';
import 'package:cute_pixel/shared/route_args/pet_route_args.dart';
import 'package:cute_pixel/shared/widgets/state_view_builder.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {
  late final PetController _controller;
  late final PetGame _game;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PetController>();
    final args = Get.arguments;
    if (args is PetRouteArgs && args.selectedPetId != null) {
      _controller.select(args.selectedPetId!);
    }
    _game = PetGame(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.petTitle)),
      body: StateViewBuilder<List<Pet>>(
        state: _controller.state,
        onData: (pets) => Stack(
          children: [
            Positioned.fill(child: GameWidget(game: _game)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ControlPanel(pets: pets, controller: _controller),
            ),
          ],
        ),
        onRetry: _controller.load,
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.pets, required this.controller});

  final List<Pet> pets;
  final PetController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final selectedId = controller.selectedId.value;
              return Wrap(
                spacing: 8,
                children: [
                  for (final pet in pets)
                    ChoiceChip(
                      label: Text(pet.name),
                      selected: pet.id == selectedId,
                      onSelected: (_) => controller.select(pet.id),
                    ),
                ],
              );
            }),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final action in PetAction.values)
                  ActionChip(
                    label: Text(_actionLabel(l10n, action)),
                    onPressed: () {
                      final id = controller.selectedId.value;
                      if (id != null) controller.setAction(id, action);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (final dir in PetDirection.values)
                  ActionChip(
                    label: Text(dir.name),
                    onPressed: () {
                      final id = controller.selectedId.value;
                      if (id != null) controller.setFacing(id, dir);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _actionLabel(AppLocalizations l10n, PetAction action) =>
      switch (action) {
        PetAction.idle => l10n.petActionIdle,
        PetAction.eat => l10n.petActionEat,
        PetAction.drink => l10n.petActionDrink,
        PetAction.walk => l10n.petActionWalk,
        PetAction.run => l10n.petActionRun,
        PetAction.sleep => l10n.petActionSleep,
      };
}
