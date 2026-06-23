class SenasaStrings {
  // --- Menú ---
  static const String menuPageTitle = 'Reporte de SENASA';
  static const String menuPageSubtitle = 'Documentación Reciente';
  static const String menuPageDescription = 'Historial de archivos oficiales exportados para SENASA.';

  // --- Títulos Generales ---
  static const String pageTitle = 'Exportar a SENASA';
  static const String step1Title = 'Selección de registros';
  static const String step2Title = 'Validación de registros';
  static const String step3Title = 'Formato de salida';

  // --- Historial ---

  // --- Botones ---
  static const String btnContinue = 'Continuar y Validar';
  static const String btnNext = 'Siguiente';
  static const String btnGenerate = 'Generar Archivo';
  static const String establishmentsLoadError = 'No se pudieron cargar los establecimientos.';
  static const String retry = 'Reintentar';
  static const String reportReady = 'Reporte generado correctamente.';

  // --- Paso 1: Filtros ---
  static const String step1SectionEvent = 'Datos del Evento';
  static const String step1SectionEventDesc =
      'Establezca el tipo de evento y el rango temporal para generar la documentación.';
  static const String step1SectionEst = 'Datos del Establecimiento';

  // --- Paso 2: Validación ---
  static const String step2Description = "Validacion de datos";
  static const String step2SuccessBanner =
      'La validación definitiva se realizará en el servidor al generar el archivo.';
  static const String step2SummaryTitle = 'Datos recopilados';
  static const String step2EventLabel = 'Evento:';
  static const String step2PeriodLabel = 'Período:';

  // --- Paso 3: Formatos ---
  static const String step3FormatTitle = 'Formato de exportación requerido';
  static const String step3pdf = 'PDF';
  static const String formatPdfDesc = 'Ideal para impresión y soporte físico con firma';
  static const String step3csv = 'CSV';
  static const String formatCsvDesc = 'Estructura delimitada optimizada para existencias';
  static const String formName = 'Ingrese su nombre y apellido.';
  static const String formDNI = 'Ingrese su DNI.';
  static const String responsableName = 'Nombre del Responsable';
  static const String responsableDNI = 'DNI';
  static const String responsibleNameRequired = 'Ingrese el nombre del responsable.';
  static const String responsibleDniRequired = 'Ingrese el DNI.';

  // --- Generacion del reporte ---
  static const String generationTitle = 'Generando reporte...';
  static const String generationDescription =
      'Compilando 142 movimientos con CUIG,\n'
      'RENSPA y firma digital del responsable.';
  static const String validatingData = 'Validando integridad de datos';
  static const String sortingEvents = 'Ordenando por fecha y tipo de evento';
  static const String compilingPdf = 'Compilando PDF con firma digital';
  static const String preparingDownload = 'Preparando archivo para descarga';
  static const String inProgress = 'en curso';

  // --- Widgets ---

  // Selector fechas
  static const String dateSelectorTitle = 'Rango de fechas';
  static const String dateSelectorToday = 'Hoy';
  static const String dateSelectorLast7Days = 'Últimos 7 días';
  static const String dateSelectorLast30Days = 'Últimos 30 días';
  static const String dateSelectorCurrentMonth = 'Mes actual';

  // Selector tipo de evento
  static const String eventSelectorTitle = 'Tipo de evento';
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

  // Selector establecimiento
  static const String establishmentSelectorLabel = 'Seleccione el Establecimiento';
  static const String establishmentSectionTitle = 'Datos del Establecimiento';
  static const String establishmentRequired = 'Seleccione un establecimiento.';
}
