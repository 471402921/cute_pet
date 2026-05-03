import 'package:cute_pixel/app/app_routes.dart';
import 'package:cute_pixel/features/_template/_template_binding.dart';
import 'package:cute_pixel/features/_template/_template_page.dart';
import 'package:cute_pixel/features/home/home_page.dart';
import 'package:cute_pixel/features/pet/pet_binding.dart';
import 'package:cute_pixel/features/pet/pet_page.dart';
import 'package:get/get.dart';

abstract class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(
      name: AppRoutes.pet,
      page: () => const PetPage(),
      binding: PetBinding(),
    ),
    GetPage(
      name: AppRoutes.template,
      page: () => const TemplatePage(),
      binding: TemplateBinding(),
    ),
  ];
}
