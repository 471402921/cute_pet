import 'dart:async';

import 'package:cute_pixel/core/error/failures.dart';
import 'package:cute_pixel/features/_template/_template_api.dart';
import 'package:cute_pixel/features/_template/_template_models.dart';
import 'package:cute_pixel/shared/widgets/view_state.dart';
import 'package:get/get.dart';

class TemplateController extends GetxController {
  TemplateController(this._api);

  final TemplateApi _api;

  final state = Rx<ViewState<List<TemplateItem>>>(const ViewState.loading());

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const ViewState.loading();
    try {
      final items = await _api.fetchItems();
      state.value = items.isEmpty
          ? const ViewState.empty()
          : ViewState.data(items);
    } on Failure catch (f) {
      state.value = ViewState.error(f);
    }
  }
}
