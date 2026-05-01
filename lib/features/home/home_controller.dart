import 'package:get/get.dart';

class HomeController extends GetxController {
  final greeting = 'Hello, cute pet!'.obs;

  void cheer() {
    greeting.value = greeting.value.endsWith('!!!')
        ? 'Hello, cute pet!'
        : '${greeting.value}!';
  }
}
