/// Textos centralizados de la pantalla de hacienda.
abstract final class LivestockStrings {
  /// Título de la pantalla.
  static const title = 'Hacienda';

  /// Acción principal para identificar un animal.
  static const readTagTitle = 'Leer caravana';

  /// Explica los caminos disponibles después de identificar la caravana.
  static const readTagDescription =
      'Leé la caravana con el bastón o ingresala manualmente para consultar o registrar un animal.';

  /// Título del acceso al mapa.
  static const fieldTitle = 'Campo y potreros';

  /// Descripción breve del acceso territorial.
  static const fieldDescription = 'Explorá tus potreros y consultá su carga animal.';

  /// Solicitud de contexto cuando hay más de un establecimiento.
  static const selectEstablishment = '¿Dónde vas a leer caravanas?';

  /// Orientación cuando todavía no hay establecimientos disponibles.
  static const noEstablishments = 'Registrá un establecimiento para leer caravanas.';

  /// Error recuperable al obtener el catálogo local.
  static const establishmentsError = 'No se pudieron cargar los establecimientos. Intentá nuevamente.';
}
