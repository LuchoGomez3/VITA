/// Textos centralizados de la pantalla de perfil.
abstract final class ProfileStrings {
  /// Titulo de la pantalla.
  static const title = 'Perfil y ajustes';

  /// Etiqueta del identificador de inicio de sesion.
  static const usernameLabel = 'Usuario';

  /// Título de la información personal.
  static const userDataSection = 'Datos del usuario';

  /// Etiqueta del ID interno.
  static const userIdLabel = 'ID de usuario';

  /// Etiqueta del correo electrónico.
  static const emailLabel = 'Correo electrónico';

  /// Etiqueta del nombre del usuario.
  static const firstNameLabel = 'Nombre';

  /// Etiqueta del apellido del usuario.
  static const lastNameLabel = 'Apellido';

  /// Etiqueta del CUIT personal.
  static const cuitLabel = 'CUIT';

  /// Etiqueta del rol de acceso.
  static const roleLabel = 'Rol';

  /// Título del listado de establecimientos.
  static const establishmentsSection = 'Establecimientos';

  /// Mensaje cuando la sesión no tiene establecimientos guardados.
  static const noEstablishments =
      'No hay establecimientos disponibles para esta cuenta.';

  /// Etiqueta del número RENSPA.
  static const renspaLabel = 'RENSPA';

  /// Etiqueta de la superficie.
  static const areaLabel = 'Superficie';

  /// Etiqueta de la provincia.
  static const provinceLabel = 'Provincia';

  /// Etiqueta del departamento.
  static const departmentLabel = 'Departamento';

  /// Etiqueta de la localidad.
  static const localityLabel = 'Localidad';

  /// Unidad de superficie.
  static const hectaresUnit = 'ha';

  /// Acción para reintentar la carga del catálogo.
  static const retry = 'Reintentar';

  /// Accion para cerrar la sesion.
  static const signOutButton = 'Cerrar sesión';

  /// Texto mostrado mientras se elimina la sesion local.
  static const signingOutButton = 'Cerrando sesión...';

  /// Valor usado brevemente mientras la sesion termina de restaurarse.
  static const emptyCredential = '—';

  /// Devuelve el nombre visible de un rol persistido.
  static String roleName(String role) {
    return switch (role) {
      'admin' => 'Administrador',
      'encargado' => 'Encargado',
      'operario' => 'Operario',
      _ => 'Sin rol asignado',
    };
  }
}
