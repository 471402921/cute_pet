// ⚠️ TEMPLATE — NOT a real feature.
//
// Lives in lib/features/ (not .claude/skills/) so `make analyze` + `make test`
// continuously verify it as architecture/conventions evolve. Don't import from
// here, don't add business logic, don't route users to /_template.
//
// To create a new module from this template, use the /cute-pixel-module-gen
// skill (cp -r lib/features/_template + sed). See SKILL.md for the full flow.

import 'package:cute_pixel/features/_template/_template_api.dart';
import 'package:cute_pixel/features/_template/_template_controller.dart';
import 'package:get/get.dart';

class TemplateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(TemplateApi.new);
    Get.lazyPut(() => TemplateController(Get.find()));
  }
}
