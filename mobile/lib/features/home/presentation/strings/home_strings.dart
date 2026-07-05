/// Textos centralizados de la pantalla de inicio.
class HomeStrings {
  const HomeStrings._();

  /// Titulo de la app en home.
  static const appTitle = 'Trazabilidad ganadera';

  /// Tooltip del boton para cerrar sesion.
  static const signOutTooltip = 'Cerrar sesion';

  /// Titulo principal del mock de home.
  static const title = 'Base inicial del front';

  /// Texto introductorio del mock de home.
  static const subtitle =
      'La app queda lista para crecer por modulos, con navegacion y una '
      'feature real como referencia.';

  /// Titulo de la accion para validar la sesion.
  static const authCheckTitle = 'Autenticacion';

  /// Descripcion de la accion para validar la sesion.
  static const authCheckDescription = 'Verifica la sesion restaurada en este dispositivo.';

  /// Boton para verificar autenticacion.
  static const authCheckButton = 'Verificar sesion';

  /// Boton durante la verificacion.
  static const authCheckingButton = 'Verificando...';

  /// Prefijo de exito al verificar autenticacion.
  static const authCheckSuccessPrefix = 'Sesion activa:';

  /// Mensaje fallback de verificacion.
  static const authCheckUnknownError = 'No se pudo verificar la sesion.';

  /// Titulo del modulo de registro.
  static const animalRegisterTitle = 'Registrar animal';

  /// Descripcion del modulo de registro.
  static const animalRegisterDescription = 'Primer modulo con capas presentation, domain y data.';

  /// Boton para abrir registro.
  static const animalRegisterButton = 'Abrir modulo';

  /// Titulo del detalle de animal.
  static const animalDetailTitle = 'Detalle de animal';

  /// Descripcion del detalle de animal.
  static const animalDetailDescription = 'Ejemplo de navegacion a una feature separada usando un id en la ruta.';

  /// Boton para abrir el detalle de animal demo.
  static const animalDetailButton = 'Ver animal A-001';
}
