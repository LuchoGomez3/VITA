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

  /// Ficha de un establecimiento de Perfil (recibe `EstablishmentDetails`
  /// en `extra`).
  static const profileEstablishment = '/perfil/establecimiento';

  /// Equipo de un establecimiento. Lleva el id en la ruta (y no en `extra`)
  /// para sobrevivir a que el sistema restaure la app.
  static const team = '/perfil/establecimiento/:establishmentId/equipo';

  /// Invitar a alguien al equipo de un establecimiento.
  static const teamInvite = '/perfil/establecimiento/:establishmentId/equipo/invitar';

  /// Invitación recién creada, con el código para compartir (recibe
  /// `({CreatedInvitation created, String establishmentName})` en `extra`).
  static const teamInvitationCreated = '/perfil/establecimiento/:establishmentId/equipo/invitacion';

  /// Sumarse a un establecimiento con el código de una invitación.
  static const joinEstablishment = '/perfil/sumarme';

  /// Equipo de [establishmentId].
  static String teamFor(String establishmentId) => '/perfil/establecimiento/$establishmentId/equipo';

  /// Invitación creada en [establishmentId].
  static String teamInvitationCreatedFor(String establishmentId) => '${teamFor(establishmentId)}/invitacion';

  /// Invitar al equipo de [establishmentId].
  static String teamInviteFor(String establishmentId) => '${teamFor(establishmentId)}/invitar';

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

  /// Ruta de identificacion de animales mediante caravana RFID.
  static const rfidScan = '/identificar-animal';

  /// Captura RFID para completar un formulario existente.
  static const rfidCapture = '/capturar-rfid';

  /// Ruta de la seccion de registros de gastos.
  static const expenseRecords = '/registros-de-gastos';

  /// Ruta temporal para registrar un egreso operativo.
  static const expenseRegister = '/registros-de-gastos/registrar-egreso';

  /// Ruta temporal para registrar un ingreso operativo.
  static const incomeRegister = '/registros-de-gastos/registrar-ingreso';

  /// Construye la ruta de egresos con el establecimiento activo explicito.
  static String expensesForEstablishment({
    required String path,
    required String establishmentId,
    required String establishmentName,
  }) =>
      '$path?establecimientoId=${Uri.encodeQueryComponent(establishmentId)}'
      '&establecimientoNombre=${Uri.encodeQueryComponent(establishmentName)}';

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

  /// Construye la ruta de alta con una caravana RFID ya leida.
  static String animalRegisterWithRfid({
    required String rfidTagNumber,
    required String establishmentId,
  }) {
    return '$animalRegisterStep1?rfid=${Uri.encodeQueryComponent(rfidTagNumber)}'
        '&establecimientoId=${Uri.encodeQueryComponent(establishmentId)}';
  }

  /// Obtiene la ruta de detalle de un lote por su id.
  static String fieldDetailById(String lotId) {
    return '/campo/$lotId';
  }
}
