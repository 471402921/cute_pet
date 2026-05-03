// ⚠️ TEMPLATE — NOT a real feature.
//
// Lives in lib/features/ (not .claude/skills/) so `make analyze` + `make test`
// continuously verify it as architecture/conventions evolve. Don't import from
// here, don't add business logic, don't route users to /_template.
//
// To create a new module from this template, use the /cute-pixel-module-gen
// skill (cp -r lib/features/_template + sed). See SKILL.md for the full flow.

import 'package:freezed_annotation/freezed_annotation.dart';

part '_template_models.freezed.dart';
part '_template_models.g.dart';

enum TemplateStatus { active, inactive }

@freezed
abstract class TemplateItem with _$TemplateItem {
  const factory TemplateItem({
    required String id,
    required String name,
    @Default(TemplateStatus.active) TemplateStatus status,
  }) = _TemplateItem;

  factory TemplateItem.fromJson(Map<String, dynamic> json) =>
      _$TemplateItemFromJson(json);
}
