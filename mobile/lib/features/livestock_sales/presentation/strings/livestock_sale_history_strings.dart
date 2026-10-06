import 'package:frontend_mayoral/core/constants/financial_movement_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';

/// Textos compartidos del listado de ventas y su confirmación de cobro.
abstract final class LivestockSaleHistoryStrings {
  /// Título del historial financiero.
  static const String title = FinancialMovementStrings.title;

  /// Etiqueta de la sección de ventas.
  static const String sales = FinancialMovementStrings.sales;

  /// Etiqueta de la sección de egresos.
  static const String expenses = FinancialMovementStrings.expenses;

  /// Mensaje cuando todavía no se registraron operaciones.
  static const empty = 'Todavía no hay ventas registradas.';

  /// Error de lectura de SQLite.
  static const loadError = 'No se pudieron cargar las ventas.';

  /// Error de persistencia o conflicto de un cobro.
  static const paymentError = 'No se pudo registrar el cobro. Volvé a cargar las ventas e intentá de nuevo.';

  /// Acción para volver a consultar el historial.
  static const retry = 'Reintentar';

  /// Estado de una venta cobrada por completo.
  static const collected = 'Cobrada';

  /// Estado de una venta sin dinero recibido.
  static const pending = 'Pendiente de cobro';

  /// Estado de una venta con saldo por cobrar.
  static const String partial = LivestockSaleStrings.partialPayment;

  /// Acción disponible en las ventas sin cobro inicial.
  static const collect = 'Marcar como cobrada';

  /// Importe pactado de la operación.
  static const total = 'Total';

  /// Dinero efectivamente recibido.
  static const paid = 'Cobrado';

  /// Diferencia entre precio pactado e importe recibido.
  static const String balance = LivestockSaleStrings.pendingBalance;

  /// Instrumento utilizado para recibir el dinero.
  static const paymentMethod = 'Medio de pago';

  /// Acción que cierra la confirmación sin guardar.
  static const cancel = 'Cancelar';

  /// Acción que persiste el cobro completo.
  static const confirm = 'Confirmar cobro';

  /// Confirmación de escritura local exitosa.
  static const paymentSaved = 'Venta marcada como cobrada.';

  /// Nombre del medio de pago en efectivo.
  static const String cash = LivestockSaleStrings.cash;

  /// Nombre del medio de pago bancario.
  static const String bankTransfer = LivestockSaleStrings.bankTransfer;

  /// Nombre del medio de pago mediante cheque.
  static const String check = LivestockSaleStrings.check;

  /// Nombre del medio de pago con tarjeta.
  static const String card = LivestockSaleStrings.card;

  /// Identifica al comprador en la cabecera de cada tarjeta.
  static const buyer = 'Comprador';

  /// Cantidad de operaciones que contribuyen al total mostrado.
  static String recordCount(int count) => FinancialMovementStrings.recordCount(count);

  /// Cantidad de animales incluidos en la operación.
  static String animals(int count) => '$count animales';

  /// Explica el importe exacto que se va a marcar como recibido.
  static String confirmAmount(String amount) => '¿Confirmás que recibiste el total de $amount?';
}
