import 'package:cute_pixel/app/app_binding.dart';
import 'package:cute_pixel/app/app_pages.dart';
import 'package:cute_pixel/app/app_routes.dart';
import 'package:cute_pixel/app/app_theme.dart';
import 'package:cute_pixel/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const CutePixelApp());
}

class CutePixelApp extends StatelessWidget {
  const CutePixelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en'),
    );
  }
}
