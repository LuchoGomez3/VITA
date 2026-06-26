import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';

/// Immutable application configuration.
@freezed
abstract class AppConfig with _$AppConfig {
  /// Creates the immutable application configuration.
  const factory AppConfig({
    /// Application display name.
    required String appName,

    /// Active deployment environment.
    required String environment,
    required String backendBaseUrl,
    @Default(true) bool enableLogs,
  }) = _AppConfig;

  /// Configuration resolved from compile-time environment values.
  static const current = AppConfig(
    appName: 'Trazabilidad Ganadera',
    environment: 'dev',
    backendBaseUrl: String.fromEnvironment(
      'VITA_BACKEND_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000',
    ),
  );
}
