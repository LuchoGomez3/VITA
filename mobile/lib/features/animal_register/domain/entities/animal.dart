import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal.freezed.dart';

@freezed
abstract class Animal with _$Animal {
  const factory Animal({
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
  }) = _Animal;
}
