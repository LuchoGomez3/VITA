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
}
