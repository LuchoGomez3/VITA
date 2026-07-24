/// Textos centralizados del tablero de Inicio.
abstract final class HomeStrings {
  /// Titulo del app bar.
  static const appTitle = 'Resumen productivo';

  /// Opción que agrega los datos de todos los establecimientos.
  static const allEstablishments = 'Todos los establecimientos';

  /// Texto mostrado antes del establecimiento elegido.
  static const establishmentPrefix = 'Resumen productivo de';

  /// Indicación mostrada al abrir el selector.
  static const establishmentSelectionPrompt =
      'Seleccioná un establecimiento';

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

  /// Titulo del resumen economico operativo.
  static const operatingBalance = 'Balance operativo';

  /// Etiqueta del valor estimado del stock.
  static const estimatedStock = 'Stock estimado';

  /// Etiqueta de los gastos operativos.
  static const operatingExpenses = 'Gastos';

  /// Etiqueta del saldo disponible.
  static const availableBalance = 'Balance';

  /// Valor simulado del stock mientras no existe la integracion real.
  static const mockStockValue = r'$ 8.450.000';

  /// Valor simulado de gastos mientras no existe la integracion real.
  static const mockExpensesValue = r'$ 1.230.000';

  /// Valor simulado del balance mientras no existe la integracion real.
  static const mockBalanceValue = r'$ 7.220.000';

  /// Accion para iniciar el registro de un egreso.
  static const registerExpense = 'Registrar egreso';

  /// Accion para iniciar el registro de un ingreso.
  static const registerIncome = 'Registrar ingreso';

  /// Accion para consultar ingresos y egresos.
  static const movements = 'Movimientos';

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
