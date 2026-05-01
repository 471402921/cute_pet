import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app_binding.dart';
import 'app/app_pages.dart';
import 'app/app_routes.dart';
import 'app/app_theme.dart';

void main() {
  runApp(const CutePetApp());
}

class CutePetApp extends StatelessWidget {
  const CutePetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cute Pet',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
