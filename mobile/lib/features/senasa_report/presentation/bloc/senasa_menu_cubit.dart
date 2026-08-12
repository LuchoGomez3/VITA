import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/download_generated_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_generated_senasa_reports_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

part 'senasa_menu_cubit.freezed.dart';

/// Estado del historial remoto, su establecimiento y las descargas solicitadas.
@freezed
sealed class SenasaMenuState with _$SenasaMenuState {
  /// Crea el estado inicial de las operaciones independientes del menú.
  const factory SenasaMenuState({
    @Default(ResultState<List<SenasaEstablishment>>.initial()) ResultState<List<SenasaEstablishment>> establishments,
    @Default(ResultState<List<SenasaExportHistoryItem>>.initial()) ResultState<List<SenasaExportHistoryItem>> history,
    @Default(ResultState<GeneratedSenasaReport>.initial()) ResultState<GeneratedSenasaReport> download,
    String? selectedEstablishmentId,
  }) = _SenasaMenuState;
}

/// Coordina el historial remoto y la recuperación exacta de cada archivo.
class SenasaMenuCubit extends Cubit<SenasaMenuState> {
  /// Crea el cubit con los casos de uso requeridos por la pantalla.
  SenasaMenuCubit({
    required GetSenasaEstablishmentsUseCase getEstablishments,
    required GetGeneratedSenasaReportsUseCase getGeneratedReports,
    required DownloadGeneratedSenasaReportUseCase downloadGeneratedReport,
  }) : _getEstablishments = getEstablishments,
       _getGeneratedReports = getGeneratedReports,
       _downloadGeneratedReport = downloadGeneratedReport,
       super(const SenasaMenuState());

  final GetSenasaEstablishmentsUseCase _getEstablishments;
  final GetGeneratedSenasaReportsUseCase _getGeneratedReports;
  final DownloadGeneratedSenasaReportUseCase _downloadGeneratedReport;

  /// Carga establecimientos y selecciona el primero para consultar su historial.
  Future<void> loadEstablishments() async {
    emit(state.copyWith(establishments: const ResultState.loading()));
    try {
      final establishments = await _getEstablishments();
      final selectedId = establishments.firstOrNull?.id;
      emit(
        state.copyWith(
          establishments: ResultState.data(establishments),
          selectedEstablishmentId: selectedId,
        ),
      );
      if (selectedId != null) {
        await selectEstablishment(selectedId);
      }
    } on SenasaReportException catch (error) {
      emit(
        state.copyWith(
          establishments: ResultState.error(
            DomainException(message: error.message, code: error.code),
          ),
        ),
      );
    }
  }

  /// Cambia el establecimiento y reemplaza el historial por el remoto asociado.
  Future<void> selectEstablishment(String establishmentId) async {
    emit(
      state.copyWith(
        selectedEstablishmentId: establishmentId,
        history: const ResultState.loading(),
      ),
    );
    try {
      final history = await _getGeneratedReports(establishmentId);
      emit(state.copyWith(history: ResultState.data(history)));
    } on SenasaReportException catch (error) {
      emit(
        state.copyWith(
          history: ResultState.error(
            DomainException(message: error.message, code: error.code),
          ),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          history: const ResultState.error(
            DomainException(message: SenasaStrings.generatedReportsLoadError),
          ),
        ),
      );
    }
  }

  /// Descarga el archivo histórico sin recalcular su contenido.
  Future<void> download(String exportId) async {
    emit(state.copyWith(download: const ResultState.loading()));
    try {
      emit(
        state.copyWith(
          download: ResultState.data(await _downloadGeneratedReport(exportId)),
        ),
      );
    } on SenasaReportException catch (error) {
      emit(
        state.copyWith(
          download: ResultState.error(
            DomainException(message: error.message, code: error.code),
          ),
        ),
      );
    }
  }
}
