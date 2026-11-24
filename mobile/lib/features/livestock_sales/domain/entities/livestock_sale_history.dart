import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';

/// Atajos de fecha disponibles en el historial de ventas.
enum LivestockSaleHistoryPeriod {
  /// Ventas realizadas desde el primer dia del mes actual.
  currentMonth,

  /// Ventas realizadas durante los ultimos tres meses calendario.
  lastQuarter,

  /// Intervalo elegido manualmente por el usuario.
  custom,

  /// Historial completo disponible en el dispositivo.
  allHistory,
}

/// Filtros combinables que se aplican sobre el historial local.
class LivestockSaleHistoryFilters {
  /// Crea una seleccion de filtros inmutable.
  const LivestockSaleHistoryFilters({
    required this.period,
    this.from,
    this.to,
    this.type,
    this.buyer = '',
    this.paymentCondition,
  });

  /// Filtros iniciales: todo el historial local.
  const LivestockSaleHistoryFilters.initial()
    : period = LivestockSaleHistoryPeriod.allHistory,
      from = null,
      to = null,
      type = null,
      buyer = '',
      paymentCondition = null;

  /// Atajo o modalidad con la que se definio el rango.
  final LivestockSaleHistoryPeriod period;

  /// Primer dia incluido en el resultado.
  final DateTime? from;

  /// Ultimo dia incluido en el resultado.
  final DateTime? to;

  /// Modalidad comercial seleccionada.
  final LivestockSaleType? type;

  /// Texto parcial buscado en nombre, apellido o razon social.
  final String buyer;

  /// Situacion de cobro seleccionada.
  final LivestockSalePaymentCondition? paymentCondition;

  /// Indica si el resultado visible difiere del historial completo.
  bool get hasActiveFilters =>
      period != LivestockSaleHistoryPeriod.allHistory ||
      type != null ||
      buyer.trim().isNotEmpty ||
      paymentCondition != null;

  /// Evalua todos los criterios de forma acumulativa.
  bool matches(LivestockSale sale) {
    final operationDay = _day(sale.operationDate);
    final normalizedBuyer = buyer.trim().toLowerCase();
    final fullBuyerName = '${sale.buyerName} ${sale.buyerLastName ?? ''}'.trim().toLowerCase();

    return (from == null || !operationDay.isBefore(_day(from!))) &&
        (to == null || !operationDay.isAfter(_day(to!))) &&
        (type == null || sale.saleType == type) &&
        (normalizedBuyer.isEmpty || fullBuyerName.contains(normalizedBuyer)) &&
        (paymentCondition == null || sale.paymentCondition == paymentCondition);
  }

  /// Cambia solamente el rango temporal ya resuelto.
  LivestockSaleHistoryFilters withRange({
    required LivestockSaleHistoryPeriod period,
    required DateTime? from,
    required DateTime? to,
  }) {
    return LivestockSaleHistoryFilters(
      period: period,
      from: from,
      to: to,
      type: type,
      buyer: buyer,
      paymentCondition: paymentCondition,
    );
  }

  /// Cambia solamente la modalidad de venta.
  LivestockSaleHistoryFilters withType(LivestockSaleType? value) {
    return LivestockSaleHistoryFilters(
      period: period,
      from: from,
      to: to,
      type: value,
      buyer: buyer,
      paymentCondition: paymentCondition,
    );
  }

  /// Cambia solamente el comprador buscado.
  LivestockSaleHistoryFilters withBuyer(String value) {
    return LivestockSaleHistoryFilters(
      period: period,
      from: from,
      to: to,
      type: type,
      buyer: value,
      paymentCondition: paymentCondition,
    );
  }

  /// Cambia solamente el estado de cobro.
  LivestockSaleHistoryFilters withPaymentCondition(
    LivestockSalePaymentCondition? value,
  ) {
    return LivestockSaleHistoryFilters(
      period: period,
      from: from,
      to: to,
      type: type,
      buyer: buyer,
      paymentCondition: value,
    );
  }

  static DateTime _day(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
