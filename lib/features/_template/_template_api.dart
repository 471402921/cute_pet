// ⚠️ TEMPLATE — NOT a real feature.
//
// Lives in lib/features/ (not .claude/skills/) so `make analyze` + `make test`
// continuously verify it as architecture/conventions evolve. Don't import from
// here, don't add business logic, don't route users to /_template.
//
// To create a new module from this template, use the /cute-pixel-module-gen
// skill (cp -r lib/features/_template + sed). See SKILL.md for the full flow.

import 'package:cute_pixel/features/_template/_template_models.dart';

class TemplateApi {
  Future<List<TemplateItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      TemplateItem(id: 'tpl-1', name: 'First Item'),
      TemplateItem(
        id: 'tpl-2',
        name: 'Second Item',
        status: TemplateStatus.inactive,
      ),
    ];
  }
}
