import 'package:get/get.dart';

import '../features/home/home_binding.dart';
import '../features/home/home_page.dart';
import '../features/pet/pet_page.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.pet,
      page: () => const PetPage(),
    ),
  ];
}
