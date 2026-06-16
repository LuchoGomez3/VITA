/// Rutas de la app.
class AppRoutes {
  const AppRoutes._();

  /// Ruta de la pantalla de inicio.
  static const home = '/';

  /// Ruta de la pantalla de registro de animal paso 1.
  static const animalRegisterStep1 = '/registrar-animal/paso-1';

  /// Ruta de la pantalla de registro de animal paso 2.
  static const animalRegisterStep2 = '/registrar-animal/paso-2';

  /// Ruta de la pantalla de registro de animal paso 3.
  static const animalRegisterStep3 = '/registrar-animal/paso-3';

  /// Ruta de la pantalla de detalle de animal.
  static const animalDetail = '/animals/:animalId';

  /// Obtiene la ruta de detalle de animal por su id.
  static String animalDetailById(String animalId) {
    return '/animals/$animalId';
  }
}
