/// Centralized UI strings for the SENASA report feature.
class SenasaStrings {
  /// Menu page title.
  static const String menuPageTitle = 'Reporte de SENASA';

  /// Recent documents section title.
  static const String menuPageSubtitle = 'Documentación Reciente';

  /// Recent documents section description.
  static const String menuPageDescription = 'Historial de archivos oficiales exportados para SENASA.';

  /// Report wizard title.
  static const String pageTitle = 'Exportar a SENASA';

  /// First step title.
  static const String step1Title = 'Selección de registros';

  /// Second step title.
  static const String step2Title = 'Validación de registros';

  /// Third step title.
  static const String step3Title = 'Formato de salida';

  /// Continue button label.
  static const String btnContinue = 'Continuar y Validar';

  /// Next button label.
  static const String btnNext = 'Siguiente';

  /// Generate button label.
  static const String btnGenerate = 'Generar Archivo';

  /// Error shown when establishments cannot be loaded.
  static const String establishmentsLoadError = 'No se pudieron cargar los establecimientos.';

  /// Retry button label.
  static const String retry = 'Reintentar';

  /// Success message shown when the report is ready.
  static const String reportReady = 'Reporte generado correctamente.';

  /// Event data section title.
  static const String step1SectionEvent = 'Datos del Evento';

  /// Event data section description.
  static const String step1SectionEventDesc =
      'Establezca el tipo de evento y el rango temporal para generar la documentación.';

  /// Establishment data section title.
  static const String step1SectionEst = 'Datos del Establecimiento';

  /// Validation step description.
  static const String step2Description = 'Validacion de datos';

  /// Validation success banner text.
  static const String step2SuccessBanner =
      'La validación definitiva se realizará en el servidor al generar el archivo.';

  /// Validation summary title.
  static const String step2SummaryTitle = 'Datos recopilados';

  /// Event label in the summary.
  static const String step2EventLabel = 'Evento:';

  /// Period label in the summary.
  static const String step2PeriodLabel = 'Período:';

  /// Export format selector title.
  static const String step3FormatTitle = 'Formato de exportación requerido';

  /// PDF format label.
  static const String step3pdf = 'PDF';

  /// PDF format description.
  static const String formatPdfDesc = 'Ideal para impresión y soporte físico con firma';

  /// CSV format label.
  static const String step3csv = 'CSV';

  /// CSV format description.
  static const String formatCsvDesc = 'Estructura delimitada optimizada para existencias';

  /// Responsible person name validation hint.
  static const String formName = 'Ingrese su nombre y apellido.';

  /// Responsible person DNI validation hint.
  static const String formDNI = 'Ingrese su DNI.';

  /// Responsible person name field label.
  static const String responsableName = 'Nombre del Responsable';

  /// Responsible person DNI field label.
  static const String responsableDNI = 'DNI';

  /// Responsible person name required message.
  static const String responsibleNameRequired = 'Ingrese el nombre del responsable.';

  /// Responsible person DNI required message.
  static const String responsibleDniRequired = 'Ingrese el DNI.';

  /// Report generation page title.
  static const String generationTitle = 'Generando reporte...';

  /// Report generation page description.
  static const String generationDescription =
      'Compilando 142 movimientos con CUIG,\n'
      'RENSPA y firma digital del responsable.';

  /// Title shown after a successful report generation.
  static const String successTitle = 'Reporte generado';

  /// Description shown after a successful report generation.
  static const String successDescription = 'Archivo listo para descargar o compartir.';

  /// Title shown when report generation fails.
  static const String errorTitle = 'No se pudo generar';

  /// Fallback description shown when report generation fails.
  static const String errorDescription = 'Revisá los datos y volvé a intentar.';

  /// Preview action label.
  static const String preview = 'Vista previa';

  /// Download action label.
  static const String download = 'Descargar';

  /// Share action label.
  static const String share = 'Compartir';

  /// Marks the generated report as sent.
  static const String markAsSent = 'Marcar como enviado a SENASA';

  /// Return action label for the SENASA menu.
  static const String backToCompliance = 'Volver a cumplimiento';

  /// Retry generation action label.
  static const String retryGeneration = 'Volver a intentar';

  /// File timestamp label for generated reports.
  static const String generatedNow = 'Generado ahora';

  /// Generic file label used when the filename has no extension.
  static const String reportFileLabel = 'ARCHIVO';

  /// Message shown when the report is marked as sent locally.
  static const String markedAsSentMessage = 'Reporte marcado como enviado a SENASA.';

  /// Message shown when preview is not available for a generated format.
  static const String previewUnavailable = 'La vista previa está disponible para archivos PDF.';

  /// Generation progress item for data validation.
  static const String validatingData = 'Validando integridad de datos';

  /// Generation progress item for event sorting.
  static const String sortingEvents = 'Ordenando por fecha y tipo de evento';

  /// Generation progress item for PDF compilation.
  static const String compilingPdf = 'Compilando PDF con firma digital';

  /// Generation progress item for download preparation.
  static const String preparingDownload = 'Preparando archivo para descarga';

  /// In-progress status label.
  static const String inProgress = 'en curso';

  /// Date range selector title.
  static const String dateSelectorTitle = 'Rango de fechas';

  /// Today shortcut label.
  static const String dateSelectorToday = 'Hoy';

  /// Last seven days shortcut label.
  static const String dateSelectorLast7Days = 'Últimos 7 días';

  /// Last thirty days shortcut label.
  static const String dateSelectorLast30Days = 'Últimos 30 días';

  /// Current month shortcut label.
  static const String dateSelectorCurrentMonth = 'Mes actual';

  /// Event type selector title.
  static const String eventSelectorTitle = 'Tipo de evento';

  /// Event type labels available in the UI.
  static const List<String> eventTypes = [
    'Vacunación',
    'Tratamiento',
    'Desparasitación',
    'Diagnóstico',
    'Análisis',
    'Ingreso',
    'Egreso',
    'Movimiento',
  ];

  /// API values mapped by event type label.
  static const Map<String, String> eventTypeApiValues = {
    'Vacunación': 'vacunacion',
    'Tratamiento': 'tratamiento',
    'Desparasitación': 'desparasitacion',
    'Diagnóstico': 'diagnostico',
    'Análisis': 'analisis',
    'Ingreso': 'ingreso',
    'Egreso': 'egreso',
    'Movimiento': 'movimiento',
  };

  /// Establishment selector field label.
  static const String establishmentSelectorLabel = 'Seleccione el Establecimiento';

  /// Establishment section title.
  static const String establishmentSectionTitle = 'Datos del Establecimiento';

  /// Establishment required validation message.
  static const String establishmentRequired = 'Seleccione un establecimiento.';
}
