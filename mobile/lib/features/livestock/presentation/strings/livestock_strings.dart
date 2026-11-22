/// Textos centralizados de la pantalla de hacienda.
abstract final class LivestockStrings {
  /// Título de la pantalla.
  static const title = 'Hacienda';

  /// Titulo de la lista de animales (diseño "Lista de animales").
  static const animalListTitle = 'Animales';

  /// Placeholder del buscador de la lista.
  static const searchHint = 'Buscar caravana, RFID o raza…';

  /// Chip que muestra todos los animales, con el total.
  static String allAnimalsChip(int count) => 'Todos · $count';

  /// Botón flotante para dar de alta un animal.
  static const newAnimalButton = 'Nuevo animal';

  /// Lista vacía: todavía no hay animales guardados en el celular.
  static const emptyTitle = 'Todavía no hay animales';

  /// Explicación de la lista vacía.
  static const emptyDescription =
      'Registrá el primero con "Nuevo animal". Si ya cargaste animales en otro '
      'dispositivo, aparecen acá después de sincronizar.';

  /// Sin resultados para la búsqueda o el filtro.
  static const noResults = 'Ningún animal coincide con la búsqueda.';

  /// Animal sin potrero asignado.
  static const noLot = 'Sin potrero';

  /// Animal sin pesajes registrados.
  static const noWeight = 'Sin pesaje';

  /// Opción del selector para ver los animales de todos los establecimientos.
  static const allEstablishments = 'Todos';

  /// Titulo del modulo de registro.
  static const animalRegisterTitle = 'Registrar animal';

  /// Acción principal para identificar un animal.
  static const readTagTitle = 'Leer caravana';

  /// Explica los caminos disponibles después de identificar la caravana.
  static const readTagDescription =
      'Leé la caravana con el bastón o ingresala manualmente para consultar o registrar un animal.';

  /// Boton para abrir el registro.
  static const animalRegisterButton = 'Registrar animal';

  /// Titulo del acceso al registro de ventas.
  static const saleRegisterTitle = 'Registrar venta';

  /// Descripcion del registro comercial de animales.
  static const saleRegisterDescription = 'Seleccioná animales y registrá los datos de la operación.';

  /// Titulo del selector cuando hay mas de un establecimiento habilitado.
  static const saleEstablishmentSelectionTitle = 'Seleccioná el establecimiento';

  /// Mensaje mostrado cuando no se puede consultar el catalogo local.
  static const saleAccessError = 'No se pudo verificar el acceso al registro de ventas.';

  /// Accion para volver a consultar el catalogo local.
  static const retry = 'Reintentar';

  /// Titulo del acceso al detalle de ejemplo.
  static const animalDetailTitle = 'Consultar animal';

  /// Descripcion del acceso al detalle de ejemplo.
  static const animalDetailDescription = 'Visualizá la información y trazabilidad de un animal.';

  /// Boton para abrir el detalle de animal demo.
  static const animalDetailButton = 'Ver animal 012';

  /// Titulo del acceso al pesaje en manga.
  static const weighingTitle = 'Pesaje en manga';

  /// Descripcion del acceso al pesaje en manga.
  static const weighingDescription = 'Capturá el peso de cada animal al pasar por la manga.';

  /// Boton para abrir el pesaje en manga.
  static const weighingButton = 'Pesar animal';

  /// Título del acceso al mapa de potreros.
  static const fieldTitle = 'Campo y potreros';

  /// Descripción breve del acceso territorial.
  static const fieldDescription = 'Explorá tus potreros y consultá su carga animal.';

  /// Boton para abrir el mapa de potreros.
  static const fieldButton = 'Ver campo';

  /// Titulo del acceso a sanidad.
  static const healthTitle = 'Sanidad';

  /// Descripcion del acceso a sanidad.
  static const healthDescription = 'Consultá campañas de vacunación, tratamientos y alertas sanitarias.';

  /// Boton para abrir sanidad.
  static const healthButton = 'Ver sanidad';

  /// Solicitud de contexto cuando hay más de un establecimiento.
  static const selectEstablishment = '¿Dónde vas a leer caravanas?';

  /// Orientación cuando todavía no hay establecimientos disponibles.
  static const noEstablishments = 'Registrá un establecimiento para leer caravanas.';

  /// Error recuperable al obtener el catálogo local.
  static const establishmentsError = 'No se pudieron cargar los establecimientos. Intentá nuevamente.';

  /// Estado del botón mientras se consulta el catálogo local.
  static const loadingEstablishments = 'Cargando...';
}
