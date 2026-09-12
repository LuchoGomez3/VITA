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
    // TODO(field-sync): habilitar estos flags en builds desplegadas solamente
    // después de validar ambos contratos REST y sus pruebas de integración.
    @Default(bool.fromEnvironment('VITA_ENABLE_LOT_REMOTE_SYNC')) bool enableLotRemoteSync,
    @Default(bool.fromEnvironment('VITA_ENABLE_LOT_MOVEMENT_REMOTE_SYNC')) bool enableLotMovementRemoteSync,
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
}
