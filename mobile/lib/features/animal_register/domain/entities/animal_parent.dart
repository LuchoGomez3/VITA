import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

part 'animal_parent.freezed.dart';

/// Animal local que puede vincularse como progenitor durante el registro.
@freezed
sealed class AnimalParent with _$AnimalParent {
  /// Conserva la identidad real y los datos necesarios para buscar y mostrar.
  const factory AnimalParent({
    required String id,
    required String visualTag,
    required String rfid,
    required String breed,
    required AnimalSex sex,
  }) = _AnimalParent;
}
