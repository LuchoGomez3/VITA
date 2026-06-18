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

  // --- Paso 1: Filtros ---
  static const String step1SectionEvent = 'Datos del Evento';
  static const String step1SectionEventDesc =
      'Establezca el tipo de evento y el rango temporal para generar la documentación.';
  static const String step1SectionEst = 'Datos del Establecimiento';

  // --- Paso 2: Validación ---
  static const String step2SuccessBanner =
      'El 100% de los registros seleccionados cumplen con los requisitos obligatorios de SENASA.';
  static const String step2SummaryTitle = 'Datos recopilados';
  static const String step2EventLabel = 'Evento:';
  static const String step2PeriodLabel = 'Período:';
  static const String step2AnimalsLabel = 'Animales involucrados:';
  static const String step2CategoriesLabel = 'Categorías:';

  // --- Paso 3: Formatos ---
  static const String step3FormatTitle = 'Formato de exportación requerido';
  static const String formatPdfDesc = 'Ideal para impresión y soporte físico con firma';
  static const String formatCsvDesc = 'Estructura delimitada optimizada para existencias';
  static const String formatTxtDesc = 'Texto plano obligatorio para importación masiva SIGSA';

  // --- Widgets ---

  // Selector fechas
  static const String dateSelectorTitle = 'Rango de fechas';
  static const String dateSelectorToday = 'Hoy';
  static const String dateSelectorLast7Days = 'Últimos 7 días';
  static const String dateSelectorLast30Days = 'Últimos 30 días';
  static const String dateSelectorCurrentMonth = 'Mes actual';

  // Selector tipo de evento
  static const String eventSelectorTitle = 'Tipo de evento';
  static final List<String> eventTypes = ['Nacimientos', 'Mortandad', 'Ingreso', 'Egreso', 'Cambio de categoría'];

  // Selector establecimiento
  static const String establishmentSelectorLabel = 'Seleccione el Establecimiento';
  static const String establishmentSectionTitle = 'Datos del Establecimiento';
  static final List<String> establishmentOptions = [
    'Estancia La Paz (RENSPA: 04.012.3.00142/00)',
    'El Carrizal (RENSPA: 08.111.2.00516/01)',
    'Estancia Los Pinos (RENSPA: 01.002.5.00089/00)',
  ];
}
