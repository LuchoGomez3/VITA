import 'package:frontend_mayoral/core/constants/financial_movement_strings.dart';

/// Textos centralizados del historial de ventas.
abstract final class LivestockSaleHistoryStrings {
  /// Titulo compartido del historial financiero.
  static const String title = FinancialMovementStrings.title;

  /// Mensaje cuando el establecimiento no tiene ventas locales.
  static const empty = 'Todavía no hay ventas registradas en este dispositivo.';

  /// Mensaje ante una falla al leer SQLite.
  static const loadError = 'No se pudieron cargar las ventas guardadas.';

  /// Accion para volver a leer el historial.
  static const retry = 'Reintentar';

  /// Titulo de los controles combinables.
  static const filters = 'Filtros';

  /// Accion que restaura el historial completo.
  static const clearFilters = 'Limpiar filtros';

  /// Mensaje cuando ningun registro coincide con los filtros.
  static const filteredEmpty = 'No hay ventas que coincidan con los filtros aplicados.';

  /// Titulo del intervalo temporal.
  static const dateRange = 'Fecha de operación';

  /// Limite inicial de un rango personalizado.
  static const dateFrom = 'Desde';

  /// Limite final de un rango personalizado.
  static const dateTo = 'Hasta';

  /// Ayuda breve de los selectores de fecha.
  static const dateHint = 'dd/mm/aaaa';

  /// Atajo al mes calendario en curso.
  static const currentMonth = 'Mes actual';

  /// Atajo a los ultimos tres meses calendario.
  static const lastQuarter = 'Últimos 3 meses';

  /// Atajo que quita los limites temporales.
  static const allHistory = 'Todo';

  /// Titulo del selector de modalidad comercial.
  static const saleType = 'Tipo de venta';

  /// Campo para buscar nombre o razon social.
  static const buyerSearch = 'Comprador';

  /// Ayuda del buscador de comprador.
  static const buyerSearchHint = 'Nombre, apellido o razón social';

  /// Titulo del selector de situacion de cobro.
  static const paymentStatus = 'Estado de cobro';

  /// Opcion que no restringe por situacion de cobro.
  static const allPaymentStatuses = 'Todos los estados';

  /// Etiqueta accesible de cada tarjeta interactiva.
  static const openDetail = 'Abrir detalle de la venta';

  /// Etiqueta del importe comercial total.
  static const total = 'Total vendido';

  /// Aclara el alcance local mientras no exista consulta remota de ventas.
  static const localOnlyNotice = 'Se muestran las ventas disponibles en este dispositivo.';

  /// Aclara que la aplicacion no mueve ni valida fondos reales.
  static const informationalAmountsNotice = 'Los importes son informativos. VITA no procesa ni verifica dinero real.';

  /// Etiqueta del comprador.
  static const buyer = 'Comprador';

  /// Etiqueta del documento de transito electronico.
  static const dte = 'DTE';

  /// Dinero recibido al registrar la operacion.
  static const collectedAmount = 'Cobrado';

  /// Dinero que todavia no fue recibido.
  static const pendingBalance = 'Saldo pendiente';

  /// Observaciones comerciales de la venta.
  static const observations = 'Observaciones';

  /// Venta sin cobro inicial.
  static const paymentPending = 'Pendiente de cobro';

  /// Venta con cobro inicial parcial.
  static const paymentPartial = 'Cobro parcial';

  /// Venta cobrada completamente al registrarse.
  static const paymentTotal = 'Cobrada';

  /// Venta local pendiente de sincronizacion.
  static const syncPending = 'Sincronización pendiente';

  /// Venta confirmada por backend.
  static const synchronized = 'Sincronizada';

  /// Venta rechazada por backend.
  static const syncRejected = 'Sincronización rechazada';

  /// Modalidad de venta por monto cerrado.
  static const bulkSale = 'Al bulto';

  /// Modalidad de venta calculada por peso.
  static const perKilogramSale = 'Por kilo';

  /// Presenta la cantidad de ventas respetando singular y plural.
  static String recordCount(int count) {
    return count == 1 ? '1 venta registrada' : '$count ventas registradas';
  }

  /// Presenta la cantidad de animales respetando singular y plural.
  static String animalCount(int count) {
    return count == 1 ? '1 animal' : '$count animales';
  }
}
