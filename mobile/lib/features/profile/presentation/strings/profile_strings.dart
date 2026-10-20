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

  /// Superficie en hectáreas, con separadores de Argentina ("1.250,5 ha").
  static String hectares(double value) {
    final rounded = (value * 10).round() / 10;
    final whole = rounded.truncate();
    final decimal = ((rounded - whole) * 10).round();
    final digits = whole.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return decimal == 0 ? '$buffer $hectaresUnit' : '$buffer,$decimal $hectaresUnit';
  }

  /// Acción para sumarse a un establecimiento de otro productor.
  static const joinEstablishmentLabel = 'Sumarme a otro establecimiento';

  /// Etiqueta de la fila con la versión instalada.
  static const versionLabel = 'Versión';

  /// Versión y número de compilación de la app instalada.
  static String versionValue(String version, String buildNumber) => 'v$version · build $buildNumber';

  /// Título de la sección con los datos de la ficha del establecimiento.
  static const establishmentDataSection = 'Datos del establecimiento';

  /// Sección del equipo en la ficha del establecimiento.
  static const teamSection = 'Equipo';

  /// Fila que abre el equipo del establecimiento.
  static const teamRowLabel = 'Usuarios del establecimiento';

  /// Subtítulo de la fila para quien gestiona el equipo.
  static const teamRowManageSubtitle = 'Ver, invitar y quitar personas';

  /// Subtítulo de la fila para el resto del equipo.
  static const teamRowViewSubtitle = 'Ver quiénes trabajan en el campo';

  /// Etiqueta de la superficie que declaró el productor en el alta.
  static const declaredAreaLabel = 'Superficie declarada';

  /// Etiqueta de la superficie calculada con el contorno dibujado.
  static const mappedAreaLabel = 'Superficie delimitada';

  /// Etiqueta de las coordenadas del punto de referencia.
  static const coordinatesLabel = 'Coordenadas';

  /// Chip sobre el mapa cuando el campo tiene contorno.
  static const boundaryDrawn = 'Campo delimitado';

  /// Chip sobre el mapa y valor de la superficie cuando no hay contorno.
  static const boundaryMissing = 'Sin delimitar';

  /// Reemplazo del mapa cuando el establecimiento no tiene ubicación.
  static const noLocation = 'Sin ubicación cargada';

  /// Ayuda debajo del mapa cuando falta la ubicación.
  static const noLocationHint = 'Aparece cuando se carga la ubicación del campo en el alta.';

  /// Latitud y longitud con 5 decimales (alrededor de un metro).
  static String coordinates(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  /// Ayuda del lápiz de la cabecera.
  static const editAppearanceTooltip = 'Editar foto y color';

  /// Pestaña de la foto en la hoja de edición.
  static const photoTab = 'Foto';

  /// Pestaña del color en la hoja de edición.
  static const colorTab = 'Color de fondo';

  /// Acción para sacar una foto con la cámara.
  static const takePhoto = 'Sacar una foto';

  /// Acción para elegir una foto de la galería.
  static const pickFromGallery = 'Elegir de la galería';

  /// Acción para volver a las iniciales.
  static const removePhoto = 'Quitar foto';

  /// Explica dónde se usa la foto.
  static const photoHint = 'Tu foto se ve en el perfil de este celular y de cualquier otro donde entres con tu cuenta.';

  /// Título de los colores sugeridos.
  static const savedColors = 'Colores guardados';

  /// Nombre del verde de VITA en la paleta.
  static const originalColor = 'Original';

  /// Título del selector libre.
  static const customColor = 'Elegí un color';

  /// Título de los campos de rojo, verde y azul.
  static const rgbLabel = 'O escribilo en RGB (0 a 255)';

  /// Etiquetas de los campos RGB.
  static const redLabel = 'R';

  /// Etiqueta del campo de verde.
  static const greenLabel = 'G';

  /// Etiqueta del campo de azul.
  static const blueLabel = 'B';

  /// Botón que aplica el color elegido.
  static const applyColor = 'Aplicar color';

  /// Aviso cuando el cambio llegó a la cuenta.
  static const appearanceSaved = 'Listo, se guardó el cambio.';

  /// Aviso cuando el cambio quedó en el celular.
  static const appearanceSavedOffline = 'Guardado en el celular. Se sube a tu cuenta cuando vuelva la señal.';

  /// Error al abrir la cámara o la galería.
  static const photoPickerError = 'No se pudo abrir la cámara o la galería. Revisá los permisos de la app.';

  /// Acción para elegir un avatar ilustrado.
  static const chooseAvatar = 'Elegir un avatar';

  /// Título del selector de avatares.
  static const avatarPickerTitle = 'Elegí tu avatar';

  /// Acción para ver otra tanda de avatares.
  static const moreAvatars = 'Ver otros';

  /// Crédito que exige la licencia CC BY 4.0 del estilo Toon Head.
  static const avatarAttribution = 'Avatares "Toon Head" de Johan Melin (CC BY 4.0), generados con DiceBear.';

  /// Descripción accesible de cada avatar de la grilla.
  static String avatarOption(int index) => 'Avatar ${index + 1}';
}
