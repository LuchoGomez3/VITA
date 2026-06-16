import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal.model.freezed.dart';

@freezed
abstract class BrickAnimalModel with _$BrickAnimalModel {
  const factory BrickAnimalModel({
    required int nroCaravana,
    required String sexo,
    required String raza,
    required double peso,
    required DateTime fechaNac,
    required String categoria,
    required String pelaje,
    int? idLote,
    int? caravanaPadre,
    int? caravanaMadre,
    String? observaciones,
    DateTime? syncedAt,
  }) = _BrickAnimalModel;
}

/*
  Cuando se instale Brick, este archivo es el que normalmente se convierte en
  el modelo anotado con sufijo `.model.dart` que Brick usa para generar adapters
  y schema.
*/
