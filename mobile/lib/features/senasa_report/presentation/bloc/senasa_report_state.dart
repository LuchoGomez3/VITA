abstract class SenasaReportState {}

class SenasaReportInitial extends SenasaReportState {}

class SenasaReportLoading extends SenasaReportState {}

// Estado para el Escenario 2: Datos incompletos
class SenasaReportValidationError extends SenasaReportState {
  final List<String> invalidAnimals; // Ej: ['Caravana: 123', 'Caravana: 456']
  final String message;
  SenasaReportValidationError(this.invalidAnimals, this.message);
}

// Estado para el Escenario 1 y 3: Generación exitosa
class SenasaReportSuccess extends SenasaReportState {
  final String filePath;
  final String format; // 'PDF' o 'CSV'
  SenasaReportSuccess(this.filePath, this.format);
}

class SenasaReportError extends SenasaReportState {
  final String message;
  SenasaReportError(this.message);
}