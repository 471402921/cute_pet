// ⚠️ TEMPLATE — NOT a real feature.
//
// Lives in lib/features/ (not .claude/skills/) so `make analyze` + `make test`
// continuously verify it as architecture/conventions evolve. Don't import from
// here, don't add business logic, don't route users to /_template.
//
// To create a new module from this template, use the /cute-pixel-module-gen
// skill (cp -r lib/features/_template + sed). See SKILL.md for the full flow.

import 'package:cute_pixel/features/_template/_template_controller.dart';
import 'package:cute_pixel/features/_template/_template_models.dart';
import 'package:cute_pixel/l10n/app_localizations.dart';
import 'package:cute_pixel/shared/widgets/state_view_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TemplatePage extends GetView<TemplateController> {
  const TemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.templateTitle)),
      body: StateViewBuilder<List<TemplateItem>>(
        state: controller.state,
        onData: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text(item.status.name),
            );
          },
        ),
        onRetry: controller.load,
      ),
    );
  }
}
