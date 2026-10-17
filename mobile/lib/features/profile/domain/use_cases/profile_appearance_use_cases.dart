import 'dart:typed_data';

import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/profile_appearance.dart';
import 'package:frontend_mayoral/features/profile/domain/repositories/profile_appearance_repository.dart';

/// Lee la apariencia guardada en el celular.
class LoadProfileAppearanceUseCase {
  /// Crea el caso de uso.
  const LoadProfileAppearanceUseCase(this._repository);

  final ProfileAppearanceRepository _repository;

  /// Ejecuta la lectura para [userId].
  Future<Result<ProfileAppearance>> call(String userId) => _repository.load(userId);
}

/// Sube lo pendiente y trae los cambios de la cuenta.
class SyncProfileAppearanceUseCase {
  /// Crea el caso de uso.
  const SyncProfileAppearanceUseCase(this._repository);

  final ProfileAppearanceRepository _repository;

  /// Ejecuta la sincronización para [userId].
  Future<Result<ProfileAppearance>> call(String userId) => _repository.sync(userId);
}

/// Cambia el color de la cabecera.
class ChangeHeaderColorUseCase {
  /// Crea el caso de uso.
  const ChangeHeaderColorUseCase(this._repository);

  final ProfileAppearanceRepository _repository;

  /// Aplica [color] (`0xFFRRGGBB`, o `null` para el verde original). Fuerza la
  /// opacidad total: la cabecera no admite transparencia.
  Future<Result<ProfileAppearance>> call(String userId, int? color) =>
      _repository.changeHeaderColor(userId, color == null ? null : 0xFF000000 | (color & 0xFFFFFF));
}

/// Reemplaza la foto del usuario.
class ChangeAvatarUseCase {
  /// Crea el caso de uso.
  const ChangeAvatarUseCase(this._repository);

  final ProfileAppearanceRepository _repository;

  /// Guarda [jpeg] como la foto nueva.
  Future<Result<ProfileAppearance>> call(String userId, Uint8List jpeg) => _repository.changeAvatar(userId, jpeg);
}

/// Quita la foto del usuario.
class RemoveAvatarUseCase {
  /// Crea el caso de uso.
  const RemoveAvatarUseCase(this._repository);

  final ProfileAppearanceRepository _repository;

  /// Vuelve a las iniciales.
  Future<Result<ProfileAppearance>> call(String userId) => _repository.removeAvatar(userId);
}
