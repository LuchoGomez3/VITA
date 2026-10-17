/// Textos centralizados de la pantalla de hacienda.
abstract final class LivestockStrings {
  /// Titulo de la pantalla.
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

  /// Descripcion del modulo de registro.
  static const animalRegisterDescription = 'Incorporá un nuevo animal a la hacienda.';

  /// Boton para abrir el registro.
  static const animalRegisterButton = 'Registrar animal';

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

  /// Titulo del acceso al mapa de potreros.
  static const fieldTitle = 'Campo y potreros';

  /// Descripcion del acceso al mapa de potreros.
  static const fieldDescription = 'Consultá el mapa de potreros y la carga animal de cada uno.';

  /// Boton para abrir el mapa de potreros.
  static const fieldButton = 'Ver campo';

  /// Titulo del acceso a sanidad.
  static const healthTitle = 'Sanidad';

  /// Descripcion del acceso a sanidad.
  static const healthDescription = 'Consultá campañas de vacunación, tratamientos y alertas sanitarias.';

  /// Boton para abrir sanidad.
  static const healthButton = 'Ver sanidad';
}
