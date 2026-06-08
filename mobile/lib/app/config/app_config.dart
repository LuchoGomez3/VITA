import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';

@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    required String appName,
    required String environment,
    @Default(true) bool enableLogs,
  }) = _AppConfig;

  static const current = AppConfig(
    appName: 'Trazabilidad Ganadera',
    environment: 'dev',
  );
}
