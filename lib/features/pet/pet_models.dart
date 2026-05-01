import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_models.freezed.dart';
part 'pet_models.g.dart';

enum PetSpecies { shibainu, corgi }

enum PetAction { idle, eat, drink, walk, run, sleep }

enum PetDirection { north, east, south, west }

@freezed
abstract class Pet with _$Pet {
  const factory Pet({
    required String id,
    required String name,
    required PetSpecies species,
    required double x,
    required double y,
    @Default(PetAction.idle) PetAction action,
    @Default(PetDirection.south) PetDirection facing,
  }) = _Pet;

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
}
