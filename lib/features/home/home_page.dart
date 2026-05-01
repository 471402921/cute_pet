import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_routes.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cute Pet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
                  controller.greeting.value,
                  style: Theme.of(context).textTheme.headlineMedium,
                )),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: controller.cheer,
              child: const Text('Cheer'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Get.toNamed(AppRoutes.pet),
              child: const Text('Meet the pet'),
            ),
          ],
        ),
      ),
    );
  }
}
