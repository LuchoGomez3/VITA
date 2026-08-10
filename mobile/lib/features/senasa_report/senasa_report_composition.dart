import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/senasa_report/data/datasources/senasa_establishment_local_data_source.dart';
import 'package:frontend_mayoral/features/senasa_report/data/datasources/senasa_report_remote_data_source.dart';
import 'package:frontend_mayoral/features/senasa_report/data/repositories/senasa_report_repository_impl.dart';
import 'package:frontend_mayoral/features/senasa_report/data/services/senasa_report_api_service.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/download_generated_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_generated_senasa_reports_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/validate_senasa_records_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_menu_cubit.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_cubit.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_generation_cubit.dart';

/// Construye el Cubit del menú con un único grafo de dependencias.
SenasaMenuCubit createSenasaMenuCubit() {
  final repository = _createSenasaReportRepository();
  return SenasaMenuCubit(
    getEstablishments: GetSenasaEstablishmentsUseCase(repository),
    getGeneratedReports: GetGeneratedSenasaReportsUseCase(repository),
    downloadGeneratedReport: DownloadGeneratedSenasaReportUseCase(repository),
  );
}

/// Construye el Cubit del formulario y encapsula todo su wiring interno.
SenasaReportCubit createSenasaReportCubit() {
  final repository = _createSenasaReportRepository();
  return SenasaReportCubit(
    getEstablishments: GetSenasaEstablishmentsUseCase(repository),
    generateReport: GenerateSenasaReportUseCase(repository),
    validateRecords: ValidateSenasaRecordsUseCase(repository),
  );
}

/// Construye el Cubit responsable de ejecutar la generación final.
SenasaReportGenerationCubit createSenasaReportGenerationCubit() {
  final repository = _createSenasaReportRepository();
  return SenasaReportGenerationCubit(
    generateReport: GenerateSenasaReportUseCase(repository),
  );
}

SenasaReportRepository _createSenasaReportRepository() {
  final service = SenasaReportApiService(
    baseUrl: AppConfig.current.backendBaseUrl,
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  );
  return SenasaReportRepositoryImpl(
    establishmentLocalDataSource: const SenasaEstablishmentLocalDataSource(
      secureStorage: FlutterSecureStorageService(),
    ),
    remoteDataSource: SenasaReportRemoteDataSource(service: service),
  );
}
