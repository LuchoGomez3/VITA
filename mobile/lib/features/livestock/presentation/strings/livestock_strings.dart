/// Textos centralizados de la pantalla de hacienda.
abstract final class LivestockStrings {
  /// Título de la pantalla.
  static const title = 'Hacienda';

  /// Acción principal para identificar un animal.
  static const readTagTitle = 'Leer caravana';

  /// Explica los caminos disponibles después de identificar la caravana.
  static const readTagDescription = 'Leé la caravana con el bastón para consultar un animal o registrar uno nuevo.';

  /// Titulo del acceso al registro de ventas.
  static const saleRegisterTitle = 'Registrar venta';

  /// Descripcion del registro comercial de animales.
  static const saleRegisterDescription = 'Seleccioná animales y registrá los datos de la operación.';

  /// Boton para iniciar una venta.
  static const saleRegisterButton = 'Registrar venta';

  /// Titulo del selector cuando hay mas de un establecimiento habilitado.
  static const saleEstablishmentSelectionTitle = 'Seleccioná el establecimiento';

  /// Mensaje mostrado cuando no se puede consultar el catalogo local.
  static const saleAccessError = 'No se pudo verificar el acceso al registro de ventas.';

  /// Accion para volver a consultar el catalogo local.
  static const retry = 'Reintentar';

  /// Título del acceso al mapa.
  static const fieldTitle = 'Campo y potreros';

  /// Descripción breve del acceso territorial.
  static const fieldDescription = 'Explorá tus potreros y consultá su carga animal.';

  /// Título del futuro módulo sanitario.
  static const healthEventsTitle = 'Eventos sanitarios';

  /// Anticipa el alcance del módulo sin presentarlo como disponible.
  static const healthEventsDescription = 'Vacunaciones, tratamientos y controles de tu hacienda.';

  /// Estado visible de los accesos pendientes de implementación.
  static const comingSoon = 'Próximamente';

  /// Solicitud de contexto cuando hay más de un establecimiento.
  static const selectEstablishment = '¿Dónde vas a leer caravanas?';

  /// Orientación cuando todavía no hay establecimientos disponibles.
  static const noEstablishments = 'Registrá un establecimiento para leer caravanas.';

  /// Error recuperable al obtener el catálogo local.
  static const establishmentsError = 'No se pudieron cargar los establecimientos. Intentá nuevamente.';
}
