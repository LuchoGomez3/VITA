import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';

part 'senasa_report_cubit.freezed.dart';

/// State for SENASA establishment loading and report generation.
@freezed
sealed class SenasaReportState with _$SenasaReportState {
  /// Creates the feature state.
  const factory SenasaReportState({
    @Default(ResultState<List<SenasaEstablishment>>.initial()) ResultState<List<SenasaEstablishment>> establishments,
    @Default(ResultState<GeneratedSenasaReport>.initial()) ResultState<GeneratedSenasaReport> generation,
  }) = _SenasaReportState;
}

/// Coordinates the asynchronous SENASA report flows.
class SenasaReportCubit extends Cubit<SenasaReportState> {
  /// Creates the cubit.
  SenasaReportCubit({
    required GetSenasaEstablishmentsUseCase getEstablishments,
    required GenerateSenasaReportUseCase generateReport,
  }) : _getEstablishments = getEstablishments,
       _generateReport = generateReport,
       super(const SenasaReportState());

  final GetSenasaEstablishmentsUseCase _getEstablishments;
  final GenerateSenasaReportUseCase _generateReport;

  /// Loads establishments from the backend.
  Future<void> loadEstablishments() async {
    emit(state.copyWith(establishments: const ResultState.loading()));
    try {
      final establishments = await _getEstablishments();
      if (isClosed) {
        return;
      }
      emit(state.copyWith(establishments: ResultState.data(establishments)));
    } on SenasaReportException catch (error) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          establishments: ResultState.error(
            DomainException(message: error.message, code: error.code),
          ),
        ),
      );
    } on Object {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          establishments: const ResultState.error(
            DomainException(message: 'No se pudieron cargar los establecimientos.'),
          ),
        ),
      );
    }
  }

  /// Requests a generated report from the backend.
  Future<void> generate(SenasaReportRequest request) async {
    emit(state.copyWith(generation: const ResultState.loading()));
    try {
      final report = await _generateReport(request);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(generation: ResultState.data(report)));
    } on SenasaReportException catch (error) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          generation: ResultState.error(
            DomainException(message: error.message, code: error.code),
          ),
        ),
      );
    } on Object {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          generation: const ResultState.error(
            DomainException(message: 'No se pudo generar el reporte SENASA.'),
          ),
        ),
      );
    }
  }
}
