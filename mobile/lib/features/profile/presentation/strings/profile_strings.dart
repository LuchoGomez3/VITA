/// Textos centralizados de la pantalla de perfil.
abstract final class ProfileStrings {
  /// Titulo de la pantalla.
  static const title = 'Perfil';

  /// Etiqueta del identificador de inicio de sesion.
  static const usernameLabel = 'Usuario';

  /// Título de la información personal.
  static const userDataSection = 'Información personal';

  /// Texto de apoyo de la cabecera del perfil.
  static const accountSubtitle = 'Tu cuenta en VITA';

  /// Explica la relación del usuario con el listado.
  static const establishmentsSubtitle = 'Los campos de los que formás parte';

  /// Etiqueta del correo electrónico.
  static const emailLabel = 'Correo electrónico';

  /// Etiqueta del CUIT personal.
  static const cuitLabel = 'CUIT';

  /// Título del listado de establecimientos.
  static const establishmentsSection = 'Establecimientos';

  /// Mensaje cuando la sesión no tiene establecimientos guardados.
  static const noEstablishments = 'No hay establecimientos disponibles para esta cuenta.';

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

  /// Título de la sección de dispositivos emparejados.
  static const pairedDevicesSection = 'Dispositivos emparejados';

  /// Etiqueta de la acción para vincular un dispositivo nuevo.
  static const addDeviceLabel = 'Vincular nuevo dispositivo';

  /// Título de la sección de preferencias.
  static const preferencesSection = 'Preferencias';

  /// Título de la sección "Sobre la app".
  static const aboutAppSection = 'Sobre la app';

  /// Mensaje mostrado por acciones sin funcionalidad real todavía.
  static const comingSoonMessage = 'Disponible próximamente';

  /// Acción para sumarse a un establecimiento de otro productor.
  static const joinEstablishmentLabel = 'Sumarme a otro establecimiento';

  /// Etiqueta de la fila con la versión instalada.
  static const versionLabel = 'Versión';

  /// Versión y número de compilación de la app instalada.
  static String versionValue(String version, String buildNumber) => 'v$version · build $buildNumber';
}
