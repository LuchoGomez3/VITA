import 'package:frontend_mayoral/features/senasa_report/data/datasources/senasa_establishment_local_data_source.dart';
import 'package:frontend_mayoral/features/senasa_report/data/datasources/senasa_report_remote_data_source.dart';
import 'package:frontend_mayoral/features/senasa_report/data/mappers/senasa_report_mapper.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';

/// Coordina las fuentes de datos SENASA y devuelve exclusivamente dominio.
class SenasaReportRepositoryImpl implements SenasaReportRepository {
  /// Crea el repositorio con sus fuentes local y remota.
  const SenasaReportRepositoryImpl({
    required SenasaEstablishmentLocalDataSource establishmentLocalDataSource,
    required SenasaReportRemoteDataSource remoteDataSource,
  }) : _establishmentLocalDataSource = establishmentLocalDataSource,
       _remoteDataSource = remoteDataSource;

  final SenasaEstablishmentLocalDataSource _establishmentLocalDataSource;
  final SenasaReportRemoteDataSource _remoteDataSource;

  @override
  Future<List<SenasaExportHistoryItem>> getGeneratedReports(
    String establishmentId,
  ) async {
    final items = await _remoteDataSource.getGeneratedReports(establishmentId);
    return items.map((item) => item.toDomain()).toList(growable: false);
  }

  @override
  Future<List<SenasaEstablishment>> getEstablishments() async {
    final establishments = await _establishmentLocalDataSource.getEstablishments();
    return establishments.map((item) => item.toDomain()).toList(growable: false);
  }

  @override
  Future<GeneratedSenasaReport> generateReport(
    SenasaReportRequest request,
  ) async {
    final file = await _remoteDataSource.generateReport(request.toDto());
    return file.toDomain(animalCount: request.animalCount);
  }

  @override
  Future<SenasaValidationResult> validateRecords(
    SenasaReportValidationRequest request,
  ) async {
    final result = await _remoteDataSource.validateRecords(request.toDto());
    return result.toDomain();
  }

  @override
  Future<GeneratedSenasaReport> downloadGeneratedReport(String exportId) async {
    final file = await _remoteDataSource.downloadGeneratedReport(exportId);
    return file.toDomain(animalCount: 0);
  }
}
