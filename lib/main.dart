import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app_pages.dart';
import 'app/app_routes.dart';

void main() {
  runApp(const CutePetApp());
}

class CutePetApp extends StatelessWidget {
  const CutePetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cute Pet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
