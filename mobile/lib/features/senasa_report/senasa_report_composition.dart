import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/features/senasa_report/data/repositories/senasa_report_repository_impl.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';

/// Construye el caso de uso que obtiene los establecimientos disponibles.
GetSenasaEstablishmentsUseCase createGetSenasaEstablishmentsUseCase() {
  return GetSenasaEstablishmentsUseCase(_createSenasaReportRepository());
}

/// Construye el caso de uso que genera un archivo SENASA.
GenerateSenasaReportUseCase createGenerateSenasaReportUseCase() {
  return GenerateSenasaReportUseCase(_createSenasaReportRepository());
}

SenasaReportRepository _createSenasaReportRepository() {
  return SenasaReportRepositoryImpl(
    baseUrl: AppConfig.current.backendBaseUrl,
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  );
}
