import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';

/// Coordinates the report generation request shown by the loading page.
class SenasaReportGenerationCubit extends Cubit<ResultState<GeneratedSenasaReport>> {
  /// Creates the cubit with the use case that calls the backend.
  SenasaReportGenerationCubit({
    required GenerateSenasaReportUseCase generateReport,
  }) : _generateReport = generateReport,
       super(const ResultState.initial());

  final GenerateSenasaReportUseCase _generateReport;

  /// Starts the backend report generation request.
  Future<void> generate(SenasaReportRequest request) async {
    emit(const ResultState.loading());
    try {
      final report = await _generateReport(request);
      emit(ResultState.data(report));
    } on SenasaReportException catch (error) {
      emit(
        ResultState.error(
          DomainException(message: error.message, code: error.code),
        ),
      );
    } on Object {
      emit(
        const ResultState.error(
          DomainException(message: 'No se pudo generar el reporte SENASA.'),
        ),
      );
    }
  }
}
