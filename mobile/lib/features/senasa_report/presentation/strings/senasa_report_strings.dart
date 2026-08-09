/// Centralized UI strings for the SENASA report feature.
class SenasaStrings {
  /// Menu page title.
  static const String menuPageTitle = 'Declaración de dispositivos electrónicos';

  /// Recent documents section title.
  static const String menuPageSubtitle = 'Documentación Reciente';

  /// Recent documents section description.
  static const String menuPageDescription = 'Historial remoto de archivos preparados para importar en SIGSA.';

  /// Acción que inicia un nuevo reporte.
  static const String generateNewFile = 'Generar nuevo archivo';

  /// Mensaje mostrado cuando todavía no se generaron reportes.
  static const String emptyGeneratedReports = 'Todavía no hay archivos para este establecimiento.';

  /// Resume la cantidad de animales incluida en una exportación del historial.
  static String historyAnimalCount(int count) {
    return count == 1 ? '1 animal' : '$count animales';
  }

  /// Error mostrado cuando no se puede leer el historial local.
  static const String generatedReportsLoadError =
      'No se pudo consultar el historial. Verificá tu conexión sin perder los datos cargados.';

  /// Report wizard title.
  static const String pageTitle = 'Declaración de dispositivos electrónicos';

  /// First step title.
  static const String step1Title = 'Selección de registros';

  /// Second step title.
  static const String step2Title = 'Validación de registros';

  /// Third step title.
  /// Continue button label.
  static const String btnContinue = 'Continuar y Validar';

  /// Next button label.
  /// Generate button label.
  static const String btnGenerate = 'Generar Archivo';

  /// Error shown when establishments cannot be loaded.
  static const String establishmentsLoadError = 'No se pudieron cargar los establecimientos.';

  /// Retry button label.
  static const String retry = 'Reintentar';

  /// Success message shown when the report is ready.
  /// Event data section title.
  static const String step1SectionEvent = 'Datos de la declaración';

  /// Event data section description.
  static const String step1SectionEventDesc =
      'Seleccioná el establecimiento y el período de registro o caravaneo de los animales.';

  /// Aclara el alcance del archivo antes de iniciar cualquier operación remota.
  static const String sigsaExplanation =
      'VITA prepara un TXT compatible con la importación de SIGSA. Generarlo no significa que SENASA lo haya recibido o aceptado: el trámite oficial debe completarse en SIGSA.';

  /// Establishment data section title.
  static const String step1SectionEst = 'Datos del Establecimiento';

  /// Validation step description.
  static const String step2Description = 'Validacion de datos';

  /// Validation success banner text.
  static const String step2SuccessBanner =
      'Todos los registros tienen los campos necesarios para generar el documento.';

  /// Mensaje mostrado mientras el servidor controla cada registro.
  static const String recordsValidationLoading = 'Verificando los campos obligatorios de los registros...';

  /// Error genérico de la validación previa.
  static const String recordsValidationError = 'No se pudieron validar los registros seleccionados.';

  /// Etiqueta de la cantidad incluida en el resumen del paso dos.
  static const String step2AnimalsLabel = 'Animales a exportar:';

  /// Resume la cantidad de animales incluida en el archivo generado.
  static String includedAnimals(int count) {
    return count == 1 ? '1 animal incluido' : '$count animales incluidos';
  }

  /// Construye el encabezado de los animales que necesitan correcciones.
  static String incompleteAnimals(int count) {
    return count == 1 ? 'Animal con datos incompletos: 1' : 'Animales con datos incompletos: $count';
  }

  /// Etiqueta de la caravana mostrada en un error de validación.
  static const String tagLabel = 'Caravana';

  /// Texto usado cuando el registro no posee una caravana utilizable.
  static const String animalWithoutTag = 'Sin caravana';

  /// Etiqueta de los datos que deben completarse.
  static const String missingFieldsLabel = 'Falta completar';

  /// Traduce los nombres técnicos del backend para presentarlos al usuario.
  static String validationFieldLabel(String field) => switch (field) {
    'nro_caravana_rfid' => 'caravana RFID válida',
    'raza' => 'raza con código SENASA',
    'fecha_nacimiento' => 'fecha de nacimiento',
    _ => field,
  };

  /// Validation summary title.
  static const String step2SummaryTitle = 'Datos recopilados';

  /// Period label in the summary.
  static const String step2PeriodLabel = 'Período:';

  /// Etiqueta del nombre opcional del archivo de salida.
  static const String fileName = 'Nombre del archivo (opcional)';

  /// Ejemplo para el nombre opcional del archivo de salida.
  static const String fileNameHint = 'Ejemplo: declaracion_agosto';

  /// Report generation page title.
  static const String generationTitle = 'Generando reporte...';

  /// Report generation page description.
  static const String generationDescription = 'Solicitando al backend el TXT compatible con SIGSA.';

  /// Title shown after a successful report generation.
  static const String successTitle = 'Archivo TXT generado';

  /// Description shown after a successful report generation.
  static const String successDescription =
      'Guardalo o compartilo y completá el trámite oficial importándolo en SIGSA. Esto no confirma recepción ni aceptación de SENASA.';

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

  /// Return action label for the SENASA menu.
  static const String backToCompliance = 'Volver a cumplimiento';

  /// Retry generation action label.
  static const String retryGeneration = 'Volver a intentar';

  /// File timestamp label for generated reports.
  static const String generatedNow = 'Generado ahora';

  /// Generic file label used when the filename has no extension.
  static const String reportFileLabel = 'ARCHIVO';

  /// Metadata visible del archivo generado.
  static String reportFileMetadata({
    required String fileSize,
    required String generatedDate,
  }) {
    return '$fileSize • $generatedDate';
  }

  /// Tamaño visible para archivos menores a 1 MB.
  static String fileSizeKilobytes(String value) => '$value KB';

  /// Tamaño visible para archivos de 1 MB o más.
  static String fileSizeMegabytes(String value) => '$value MB';

  /// Generation progress item for data validation.
  static const String validatingData = 'Validando integridad de datos';

  /// Generation progress item for event sorting.
  static const String sortingEvents = 'Filtrando por fecha de registro o caravaneo';

  /// Generation progress item for PDF compilation.
  static const String compilingPdf = 'Preparando el TXT compatible con SIGSA';

  /// Generation progress item for download preparation.
  static const String preparingDownload = 'Preparando archivo para descarga';

  /// In-progress status label.
  static const String inProgress = 'en curso';

  /// Date range selector title.
  static const String dateSelectorTitle = 'Rango de fechas';

  /// Start date field title.
  static const String dateSelectorFromTitle = 'Desde';

  /// End date field title.
  static const String dateSelectorToTitle = 'Hasta';

  /// Date field hint.
  static const String dateSelectorFieldHint = 'Fecha';

  /// Today shortcut label.
  static const String dateSelectorToday = 'Hoy';

  /// Last seven days shortcut label.
  static const String dateSelectorLast7Days = 'Últimos 7 días';

  /// Last thirty days shortcut label.
  static const String dateSelectorLast30Days = 'Últimos 30 días';

  /// Current month shortcut label.
  static const String dateSelectorCurrentMonth = 'Mes actual';

  // TODO(equipo): definir el flujo de reidentificación cuando exista un
  // contrato funcional aprobado. No pertenece a la declaración inicial.

  /// Establishment selector field label.
  static const String establishmentSelectorLabel = 'Seleccione el Establecimiento';

  /// Nombre visible de un establecimiento con su identificador RENSPA.
  static String establishmentWithRenspa(String name, String renspa) {
    return '$name (RENSPA: $renspa)';
  }

  /// Establishment section title.
  static const String establishmentSectionTitle = 'Establecimiento';

  /// Establishment required validation message.
  static const String establishmentRequired = 'Seleccione un establecimiento.';
}
