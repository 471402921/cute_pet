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
