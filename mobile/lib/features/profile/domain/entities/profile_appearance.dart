import 'package:meta/meta.dart';

/// Apariencia personal de Perfil: el color de la cabecera y la foto.
///
/// Vive primero en el celular: un cambio se ve al instante aunque no haya
/// señal y se sube a la cuenta cuando vuelve la conexión.
@immutable
class ProfileAppearance {
  /// Crea la apariencia.
  const ProfileAppearance({
    this.headerColor,
    this.avatarPath,
    this.avatarVersion = 0,
    this.hasPendingChanges = false,
  });

  /// Color de la cabecera como `0xFFRRGGBB`; `null` es el verde original.
  final int? headerColor;

  /// Archivo local con la foto del usuario; `null` muestra las iniciales.
  final String? avatarPath;

  /// Cambia con cada foto nueva para que la imagen en caché se renueve
  /// aunque el archivo conserve el mismo nombre.
  final int avatarVersion;

  /// Si hay un cambio guardado en el celular que todavía no llegó a la cuenta.
  final bool hasPendingChanges;

  @override
  bool operator ==(Object other) =>
      other is ProfileAppearance &&
      other.headerColor == headerColor &&
      other.avatarPath == avatarPath &&
      other.avatarVersion == avatarVersion &&
      other.hasPendingChanges == hasPendingChanges;

  @override
  int get hashCode => Object.hash(headerColor, avatarPath, avatarVersion, hasPendingChanges);
}
