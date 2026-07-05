import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';

/// Mapper del perfil de usuario recibido desde el backend.
class AppUserMapper {
  const AppUserMapper._();

  /// Convierte el JSON de `/api/auth/me` en entidad de dominio.
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _readString(json, 'id'),
      email: _readString(json, 'email'),
      firstName: _readString(json, 'nombre'),
      lastName: _readString(json, 'apellido'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String ? value : '';
  }
}
