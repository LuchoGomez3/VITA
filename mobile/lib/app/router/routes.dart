/// Rutas de la app.
class AppRoutes {
  const AppRoutes._();

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
}
