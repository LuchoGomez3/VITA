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

    /// Root URL for backend API endpoints.
    required String apiBaseUrl,

    /// Bearer token supplied by the current authenticated session.
    required String apiAccessToken,

    /// Whether application logs are enabled.
    @Default(true) bool enableLogs,
  }) = _AppConfig;

  /// Configuration resolved from compile-time environment values.
  static const current = AppConfig(
    appName: 'Trazabilidad Ganadera',
    environment: 'dev',
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000/api',
    ),
    apiAccessToken: String.fromEnvironment('API_ACCESS_TOKEN'),
  );
}
