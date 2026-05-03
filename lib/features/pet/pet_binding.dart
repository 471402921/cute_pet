import 'package:cute_pixel/features/pet/pet_api.dart';
import 'package:cute_pixel/features/pet/pet_controller.dart';
import 'package:get/get.dart';

class PetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(PetApi.new);
    Get.lazyPut(() => PetController(Get.find()));
  }
}
