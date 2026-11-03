import 'dart:typed_data';

import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/profile_appearance.dart';

/// Guarda la apariencia de Perfil en el celular y la sincroniza con la cuenta.
abstract interface class ProfileAppearanceRepository {
  /// Lo guardado en el celular para [userId], sin usar la red.
  Future<Result<ProfileAppearance>> load(String userId);

  /// Sube lo pendiente y trae lo que cambió en la cuenta (por ejemplo, desde
  /// otro celular). Sin conexión devuelve lo local y lo reintenta otra vez.
  Future<Result<ProfileAppearance>> sync(String userId);

  /// Cambia el color de la cabecera; `null` vuelve al verde original.
  Future<Result<ProfileAppearance>> changeHeaderColor(String userId, int? color);

  /// Reemplaza la foto por [jpeg].
  Future<Result<ProfileAppearance>> changeAvatar(String userId, Uint8List jpeg);

  /// Quita la foto y vuelve a las iniciales.
  Future<Result<ProfileAppearance>> removeAvatar(String userId);
}
