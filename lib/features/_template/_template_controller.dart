// ⚠️ TEMPLATE — NOT a real feature.
//
// Lives in lib/features/ (not .claude/skills/) so `make analyze` + `make test`
// continuously verify it as architecture/conventions evolve. Don't import from
// here, don't add business logic, don't route users to /_template.
//
// To create a new module from this template, use the /cute-pixel-module-gen
// skill (cp -r lib/features/_template + sed). See SKILL.md for the full flow.

import 'dart:async';

import 'package:cute_pixel/core/error/failures.dart';
import 'package:cute_pixel/features/_template/_template_api.dart';
import 'package:cute_pixel/features/_template/_template_models.dart';
import 'package:cute_pixel/shared/state/view_state.dart';
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
