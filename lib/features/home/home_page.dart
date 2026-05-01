import 'package:cute_pet/app/app_routes.dart';
import 'package:cute_pet/features/pet/pet_route_args.dart';
import 'package:cute_pet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.homeGreeting,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Get.toNamed<void>(
                AppRoutes.pet,
                arguments: const PetRouteArgs(),
              ),
              child: Text(l10n.homeMeetThePet),
            ),
          ],
        ),
      ),
    );
  }
}
