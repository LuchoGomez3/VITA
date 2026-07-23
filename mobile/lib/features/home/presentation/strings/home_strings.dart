/// Textos centralizados del tablero de Inicio.
abstract final class HomeStrings {
  /// Titulo del app bar.
  static const appTitle = 'Resumen productivo';

  /// Saludo utilizado durante la mañana.
  static const goodMorning = 'Buenos días';

  /// Saludo utilizado durante la tarde.
  static const goodAfternoon = 'Buenas tardes';

  /// Saludo utilizado durante la noche.
  static const goodEvening = 'Buenas noches';

  /// Nombre de respaldo mientras la sesion termina de restaurarse.
  static const defaultUserName = 'Productor';

  /// Titulo principal del tablero.
  static const title = 'Estado de la hacienda';

  /// Descripcion de la fuente de los indicadores.
  static const subtitle = 'Indicadores calculados con la información disponible sin conexión.';

  /// Tooltip para actualizar los valores.
  static const refreshTooltip = 'Actualizar indicadores';

  /// Etiqueta del stock vigente.
  static const activeStock = 'Stock activo';

  /// Etiqueta del peso vivo acumulado.
  static const knownLiveWeight = 'Peso conocido';

  /// Etiqueta de incorporaciones mensuales.
  static const monthlyAdditions = 'Altas del mes';

  /// Etiqueta de bajas mensuales.
  static const monthlyRemovals = 'Bajas del mes';

  /// Referencia temporal de altas y bajas.
  static const currentMonth = 'Mes actual';

  /// Unidad textual para cantidades de animales.
  static const animalsUnit = 'animales';

  /// Texto para indicar cobertura de pesos.
  static const withWeight = 'con peso';

  /// Titulo de ganancia de peso.
  static const averageDailyGain = 'Ganancia diaria promedio';

  /// Texto de cobertura del calculo de GPD.
  static const animalsWithHistory = 'animales con historial suficiente';

  /// Titulo de pesos agrupados por lote.
  static const weightByLot = 'Peso promedio y variabilidad por lote';

  /// Titulo de inventario por categoria.
  static const categoryDistribution = 'Distribución por categoría';

  /// Mensaje para listas sin animales.
  static const noAnimals = 'Todavía no hay animales disponibles.';

  /// Valor visible cuando falta información suficiente.
  static const noData = 'Sin datos';

  /// Acción para reintentar una carga fallida.
  static const retry = 'Reintentar';
}
