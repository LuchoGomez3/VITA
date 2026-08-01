import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';

@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    required String appName,
    required String environment,
    required String backendBaseUrl,
    @Default(true) bool enableLogs,
  }) = _AppConfig;

  static const current = AppConfig(
    appName: 'VITA',
    environment: 'dev',
    backendBaseUrl: String.fromEnvironment(
      'VITA_BACKEND_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000',
    ),
  );
}
