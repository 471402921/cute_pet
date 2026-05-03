// GENERATED CODE - DO NOT MODIFY BY HAND

part of '_template_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateItem _$TemplateItemFromJson(Map<String, dynamic> json) =>
    _TemplateItem(
      id: json['id'] as String,
      name: json['name'] as String,
      status:
          $enumDecodeNullable(_$TemplateStatusEnumMap, json['status']) ??
          TemplateStatus.active,
    );

Map<String, dynamic> _$TemplateItemToJson(_TemplateItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': _$TemplateStatusEnumMap[instance.status]!,
    };

const _$TemplateStatusEnumMap = {
  TemplateStatus.active: 'active',
  TemplateStatus.inactive: 'inactive',
};
