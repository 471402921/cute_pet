import 'package:cute_pet/app/app_routes.dart';
import 'package:cute_pet/features/home/home_page.dart';
import 'package:cute_pet/features/pet/pet_binding.dart';
import 'package:cute_pet/features/pet/pet_page.dart';
import 'package:get/get.dart';

abstract class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(
      name: AppRoutes.pet,
      page: () => const PetPage(),
      binding: PetBinding(),
    ),
  ];
}
