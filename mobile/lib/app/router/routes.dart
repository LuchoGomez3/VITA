/// Rutas de la app.
class AppRoutes {
  const AppRoutes._();

  /// Ruta de la pantalla de bienvenida de inicio de sesion.
  static const welcome = '/welcome';

  /// Ruta de bienvenida al registro de cuenta.
  static const signUp = '/sign-up';

  /// Ruta del formulario de creacion de cuenta.
  static const signUpForm = '/sign-up/form';

  /// Ruta de confirmacion del registro de cuenta.
  static const signUpSuccess = '/sign-up/success';

  /// Ruta de la pantalla de inicio.
  static const home = '/';

  /// Ruta raiz de la pestaña de hacienda.
  static const livestock = '/hacienda';

  /// Ruta raiz de la pestaña de tramites SENASA.
  static const procedures = '/tramites';

  /// Ruta raiz de la pestaña de perfil y ajustes.
  static const profile = '/perfil';

  /// Ruta liviana que espera la restauracion de sesion al arrancar.
  static const authCheck = '/auth-check';

  /// Ruta de la pantalla de login.
  static const login = '/login';

  /// Ruta de la pantalla de registro de animal paso 1.
  static const animalRegisterStep1 = '/registrar-animal/paso-1';

  /// Ruta de la pantalla de registro de animal paso 2.
  static const animalRegisterStep2 = '/registrar-animal/paso-2';

  /// Ruta de la pantalla de registro de animal paso 3.
  static const animalRegisterStep3 = '/registrar-animal/paso-3';

  /// Ruta de la pantalla de registro de animal paso 4.
  static const animalRegisterStep4 = '/registrar-animal/paso-4';

  /// Ruta de la pantalla de exito de registro de animal.
  static const animalRegisterSuccess = '/registrar-animal/exito';

  /// Ruta de la pantalla de detalle de animal.
  static const animalDetail = '/animals/:animalId';

  /// Cámara lateral y revisión de capturas para pesaje por visión.
  static const visionWeighing = '/pesar-por-vision';

  /// Flujo compartido de asignación y traslado de animales entre lotes.
  static const lotMovement = '/movimientos-lotes';

  /// Acceso desde una ficha o lote sin importar pantallas de otra feature.
  static String lotMovementFor({required String establishmentId, String? animalId, String? sourceLotId}) => Uri(
    path: lotMovement,
    queryParameters: {
      'establecimientoId': establishmentId,
      if (animalId != null) 'animalId': animalId,
      if (sourceLotId != null) 'loteOrigenId': sourceLotId,
    },
  ).toString();

  /// Ruta de identificacion de animales mediante caravana RFID.
  static const rfidScan = '/identificar-animal';

  /// Valor de ruta que solicita devolver el RFID a una venta en curso.
  static const rfidSaleSelectionMode = 'seleccion_venta';

  /// Captura RFID para completar un formulario existente.
  static const rfidCapture = '/capturar-rfid';

  /// Ruta de la seccion de registros de gastos.
  static const expenseRecords = '/registros-de-gastos';

  /// Ruta temporal para registrar un egreso operativo.
  static const expenseRegister = '/registros-de-gastos/registrar-egreso';

  /// Ruta temporal para registrar un ingreso operativo.
  static const incomeRegister = '/registros-de-gastos/registrar-ingreso';

  /// Ruta raiz del registro de una venta de hacienda.
  static const livestockSaleRegister = '/registrar-venta';

  /// Construye la ruta de egresos con el establecimiento activo explicito.
  static String expensesForEstablishment({
    required String path,
    required String establishmentId,
    required String establishmentName,
  }) =>
      '$path?establecimientoId=${Uri.encodeQueryComponent(establishmentId)}'
      '&establecimientoNombre=${Uri.encodeQueryComponent(establishmentName)}';

  /// Construye la ruta de venta con el establecimiento activo explicito.
  static String livestockSaleForEstablishment(String establishmentId) {
    return '$livestockSaleRegister?establecimientoId='
        '${Uri.encodeQueryComponent(establishmentId)}';
  }

  /// Ruta del menu principal de reportes SENASA.
  static const String senasaMenu = procedures;

  /// Route for the SENASA report filters.
  static const senasaReport = '/senasa-report';

  /// Ruta de generacion del reporte SENASA.
  static const senasaReportGeneration = '/senasa-report/generando';

  /// Ruta de exito del reporte SENASA.
  static const senasaReportSuccess = '/senasa-report/exito';

  /// Ruta de error del reporte SENASA.
  static const senasaReportError = '/senasa-report/error';

  /// Ruta del mapa de potreros.
  static const field = '/campo';

  /// Alias legado que redirige al visor local de lotes.
  static const fieldList = '/campo/lista';

  /// Ruta del editor local para delimitar un nuevo lote.
  static const lotRegister = '/campo/nuevo-lote';

  /// Ruta del detalle de un lote.
  static const fieldDetail = '/campo/:loteId';

  /// Obtiene la ruta de detalle de animal por su id.
  static String animalDetailById(String animalId) {
    return '/animals/$animalId';
  }

  /// Ruta de la pantalla de estado vacio de establecimiento.
  static const establishmentRegisterEmpty = '/registrar-establecimiento';

  /// Ruta de la pantalla de registro de establecimiento paso 1.
  static const establishmentRegisterStep1 = '/registrar-establecimiento/paso-1';

  /// Ruta de la pantalla de registro de establecimiento paso 2.
  static const establishmentRegisterStep2 = '/registrar-establecimiento/paso-2';

  /// Ruta de la pantalla de registro de establecimiento paso 3.
  static const establishmentRegisterStep3 = '/registrar-establecimiento/paso-3';

  /// Ruta de la pantalla de registro de establecimiento paso 4.
  static const establishmentRegisterStep4 = '/registrar-establecimiento/paso-4';

  /// Ruta de la pantalla de revision de establecimiento.
  static const establishmentRegisterReview = '/registrar-establecimiento/revisar';

  /// Ruta de la pantalla de exito de registro de establecimiento.
  static const establishmentRegisterSuccess = '/registrar-establecimiento/exito';

  /// Construye la ruta de identificacion para un establecimiento activo.
  static String rfidScanForEstablishment(String establishmentId) {
    return '$rfidScan?establecimientoId=${Uri.encodeQueryComponent(establishmentId)}';
  }

  /// Abre el lector RFID para seleccionar un animal de una venta en curso.
  static String rfidScanForLivestockSale(String establishmentId) {
    return '${rfidScanForEstablishment(establishmentId)}'
        '&modo=$rfidSaleSelectionMode';
  }

  /// Abre el lector en modo selección y devuelve el ID del animal encontrado.
  static String rfidScanForVisionWeighing(String establishmentId) {
    return '${rfidScanForEstablishment(establishmentId)}&seleccionarParaPesajeIA=true';
  }

  /// Construye la ruta de alta con una caravana RFID ya leida.
  static String animalRegisterWithRfid({
    required String rfidTagNumber,
    required String establishmentId,
  }) {
    return '$animalRegisterStep1?rfid=${Uri.encodeQueryComponent(rfidTagNumber)}'
        '&establecimientoId=${Uri.encodeQueryComponent(establishmentId)}';
  }

  /// Obtiene la ruta de detalle de un lote por su id.
  static String fieldDetailById(String lotId, {bool showSatelliteMap = false}) {
    return '/campo/$lotId${showSatelliteMap ? '?mapaSatelital=true' : ''}';
  }
}
