/// Mensajes funcionales compartidos entre transporte y presentacion.
abstract final class OperatingExpenseFailureMessages {
  /// El servidor rechazo los privilegios financieros.
  static const accessDenied =
      'Acceso denegado. No posee los privilegios necesarios para visualizar información financiera';

  /// La consulta no pudo alcanzar el backend.
  static const offline = 'Sin conexión. Se mantienen visibles los datos guardados en el dispositivo.';

  /// La sesion ya no permite requests autenticadas.
  static const sessionExpired = 'Tu sesión venció. Volvé a iniciar sesión.';

  /// Falla remota no categorizada.
  static const remote = 'El servidor no pudo completar la solicitud.';
}
