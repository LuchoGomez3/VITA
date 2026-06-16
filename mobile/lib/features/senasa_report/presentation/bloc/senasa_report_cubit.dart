import 'package:flutter_bloc/flutter_bloc.dart';
import 'senasa_report_state.dart';

class SenasaReportCubit extends Cubit<SenasaReportState> {
  SenasaReportCubit() : super(SenasaReportInitial());

  Future<void> generateReport({
    required DateTime startDate,
    required DateTime endDate,
    required String movementType,
    required String format, // 'PDF' o 'CSV'
  }) async {
    emit(SenasaReportLoading());

    try {
      // 1. Simulación de búsqueda en base de datos local (SQLite/Supabase cache)
      await Future.delayed(const Duration(seconds: 1));
      
      // Validaciones básicas (reemplaza con validaciones reales sobre los animales)
      final List<String> validationErrors = [];

      if (startDate.isAfter(endDate)) {
        validationErrors.add('Rango de fechas inválido: la fecha de inicio es posterior a la de fin.');
      }

      if (movementType.trim().isEmpty) {
        validationErrors.add('Tipo de movimiento no especificado.');
      }

      // Si hay errores, emitimos el estado de validación y bloqueamos la generación
      if (validationErrors.isNotEmpty) {
        emit(SenasaReportValidationError(
          validationErrors,
          'Inconsistencia de datos: Hay ${validationErrors.length} error(es) de validación.',
        ));
        return; // Bloqueamos la exportación (Pre-flight check)
      }

      // 2. Lógica de generación de archivo (Escenarios 1, 3 y 4)
      String generatedFilePath = '';
      
      if (format == 'PDF') {
        // Lógica de armado de PDF (Sello de auditoría, membrete, tabla)
        // generatedFilePath = await PdfService.generateMovementPdf(...);
        generatedFilePath = '/ruta/temporal/remito_senasa.pdf';
      } else if (format == 'CSV') {
        // Lógica de exportación SIGSA (solo EID de 15 dígitos, delimitado por comas)
        // generatedFilePath = await CsvService.generateSigsaCsv(...);
        generatedFilePath = '/ruta/temporal/sigsa_export.csv';
      }

      emit(SenasaReportSuccess(generatedFilePath, format));

    } catch (e) {
      emit(SenasaReportError('Ocurrió un error al generar el documento.'));
    }
  }
}