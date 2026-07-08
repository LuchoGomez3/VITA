import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/user_role.dart';

/// Sesion autenticada que la app cachea en el dispositivo.
///
/// Es la pieza que habilita el offline-first de autenticacion: guarda el
/// [accessToken] (corto), el [refreshToken] (largo, para renovar sin contrasena)
/// y [expiresAt] para saber cuando renovar. Al persistirse en almacenamiento
/// seguro, la app puede abrir autenticada aunque no haya conexion.
class Session {
  const Session({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  /// Construye la sesion desde el `data` de `/api/auth/login` o `/refresh`.
  ///
  /// El backend devuelve `expires_in` en segundos; lo convertimos a un instante
  /// absoluto para no depender del momento exacto de lectura.
  factory Session.fromBackendJson(Map<String, dynamic> json, {DateTime? now}) {
    final expiresIn = (json['expires_in'] as num?)?.toInt() ?? 3600;
    final base = now ?? DateTime.now();
    return Session(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresAt: base.add(Duration(seconds: expiresIn)),
      user: _userFromJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  /// Reconstruye la sesion desde el JSON guardado en almacenamiento seguro.
  factory Session.fromStorageJson(Map<String, dynamic> json) {
    return Session(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      user: _userFromStorageJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// JWT corto que viaja en `Authorization: Bearer` en cada request.
  final String accessToken;

  /// Token largo para pedir un access nuevo sin volver a ingresar credenciales.
  final String refreshToken;

  /// Momento en que expira [accessToken].
  final DateTime expiresAt;

  /// Perfil del usuario autenticado.
  final AppUser user;

  /// Indica si el access token ya venció (con un margen para renovar antes).
  ///
  /// El margen evita usar un token que expira "justo" mientras viaja la request.
  bool get isExpired {
    return DateTime.now().isAfter(
      expiresAt.subtract(const Duration(seconds: 30)),
    );
  }

  /// Serializa la sesion para guardarla en almacenamiento seguro.
  Map<String, dynamic> toStorageJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'user': {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'nombre': user.nombre,
        'apellido': user.apellido,
        'cuilCuit': user.cuilCuit,
        'role': user.role.name,
        'createdAt': user.createdAt.toIso8601String(),
      },
    };
  }

  /// Mapea el `usuario` del backend a [AppUser].
  ///
  /// El backend de sesion solo expone id/nombre/apellido/email; el resto se
  /// completa con valores por defecto hasta que exista un endpoint de perfil
  /// completo (rol y CUIT reales).
  static AppUser _userFromJson(Map<String, dynamic> json) {
    final email = json['email'] as String? ?? '';
    return AppUser(
      id: json['id'] as String,
      username: email,
      email: email,
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      cuilCuit: json['cuit'] as String? ?? '',
      role: UserRole.unknown,
      createdAt: DateTime.now(),
    );
  }

  static AppUser _userFromStorageJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      cuilCuit: json['cuilCuit'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.unknown,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
