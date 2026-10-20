import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';

part 'livestock_establishment.freezed.dart';

/// Establecimiento disponible para operaciones de hacienda.
@freezed
sealed class LivestockEstablishment with _$LivestockEstablishment {
  /// Crea un establecimiento con el rol offline de la sesión actual.
  const factory LivestockEstablishment({
    required String id,
    required String name,
    required UserRole role,
  }) = _LivestockEstablishment;

  const LivestockEstablishment._();

  /// Indica si el rol es reconocido y puede iniciar la identificación.
  bool get canIdentifyAnimals => role != UserRole.unknown;
}
