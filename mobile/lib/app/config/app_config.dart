import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';

@freezed
/// Configuración de compilación y entorno de la aplicación.
abstract class AppConfig with _$AppConfig {
  /// Crea una configuración inmutable.
  const factory AppConfig({
    required String appName,
    required String environment,
    required String backendBaseUrl,
    @Default(true) bool enableLogs,
    // Las altas y ediciones de lotes se envían por defecto mediante Brick.
    // El define permite desactivar la integración en builds de pruebas locales.
    @Default(bool.fromEnvironment('VITA_ENABLE_LOT_REMOTE_SYNC', defaultValue: true)) bool enableLotRemoteSync,
  }) = _AppConfig;

  /// Configuración activa de esta build.
  static const current = AppConfig(
    appName: 'VITA',
    environment: 'dev',
    backendBaseUrl: String.fromEnvironment(
      'VITA_BACKEND_BASE_URL',
      // TODO(team): Antes del release, exigir un VITA_BACKEND_BASE_URL HTTPS
      // explícito y evitar que una build productiva use este valor de emulador.
      defaultValue: 'http://10.0.2.2:8000',
    ),
  );

  /// Activa la experiencia temporal de la rama de presentación.
  static const demoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: true);

  /// Borra SQLite demo antes de volver a sembrar los fixtures sintéticos.
  static const resetDemoData = bool.fromEnvironment('DEMO_RESET');
}
