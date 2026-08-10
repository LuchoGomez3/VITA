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

  /// Ruta de identificacion de animales mediante caravana RFID.
  static const rfidScan = '/identificar-animal';

  /// Ruta de la seccion de registros de gastos.
  static const expenseRecords = '/registros-de-gastos';

  /// Ruta temporal para registrar un egreso operativo.
  static const expenseRegister = '/registros-de-gastos/registrar-egreso';

  /// Ruta temporal para registrar un ingreso operativo.
  static const incomeRegister = '/registros-de-gastos/registrar-ingreso';

  /// Obtiene la ruta de detalle de animal por su id.
  static String animalDetailById(String animalId) {
    return '/animals/$animalId';
  }

  /// Construye la ruta de identificacion para un establecimiento activo.
  static String rfidScanForEstablishment(String establishmentId) {
    return '$rfidScan?establecimientoId=${Uri.encodeQueryComponent(establishmentId)}';
  }

  /// Construye la ruta de alta con una caravana RFID ya leida.
  static String animalRegisterWithRfid(String rfidTagNumber) {
    return '$animalRegisterStep1?rfid=${Uri.encodeQueryComponent(rfidTagNumber)}';
  }
}
