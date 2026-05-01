// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pet _$PetFromJson(Map<String, dynamic> json) => _Pet(
  id: json['id'] as String,
  name: json['name'] as String,
  species: $enumDecode(_$PetSpeciesEnumMap, json['species']),
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  action:
      $enumDecodeNullable(_$PetActionEnumMap, json['action']) ?? PetAction.idle,
  facing:
      $enumDecodeNullable(_$PetDirectionEnumMap, json['facing']) ??
      PetDirection.south,
);

Map<String, dynamic> _$PetToJson(_Pet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'species': _$PetSpeciesEnumMap[instance.species]!,
  'x': instance.x,
  'y': instance.y,
  'action': _$PetActionEnumMap[instance.action]!,
  'facing': _$PetDirectionEnumMap[instance.facing]!,
};

const _$PetSpeciesEnumMap = {
  PetSpecies.shibainu: 'shibainu',
  PetSpecies.corgi: 'corgi',
};

const _$PetActionEnumMap = {
  PetAction.idle: 'idle',
  PetAction.eat: 'eat',
  PetAction.drink: 'drink',
  PetAction.walk: 'walk',
  PetAction.run: 'run',
  PetAction.sleep: 'sleep',
};

const _$PetDirectionEnumMap = {
  PetDirection.north: 'north',
  PetDirection.east: 'east',
  PetDirection.south: 'south',
  PetDirection.west: 'west',
};
