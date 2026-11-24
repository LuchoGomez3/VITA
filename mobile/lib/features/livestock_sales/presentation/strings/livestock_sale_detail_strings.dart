import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';

/// Textos centralizados del detalle de una venta.
abstract final class LivestockSaleDetailStrings {
  /// Titulo del encabezado.
  static const String title = 'Detalle de venta';

  /// Encabezado de los datos comerciales.
  static const String operation = 'Operación';

  /// Encabezado de los importes y cobros.
  static const String amounts = 'Importes';

  /// Encabezado de la auditoria de la operacion.
  static const String traceability = 'Trazabilidad';

  /// Momento en el que la venta fue registrada en el dispositivo.
  static const String registeredAt = 'Registrada el';

  /// Usuario que confirmo la venta.
  static const String registeredBy = 'Registrada por';

  /// Valor alternativo para ventas anteriores sin autor local persistido.
  static const String unavailableRegisteredBy = 'No disponible';

  /// Encabezado del bloque de animales.
  static const String animals = 'Animales asociados';

  /// Fecha comercial de la venta.
  static const String operationDate = LivestockSaleStrings.operationDate;

  /// Clase de comprador.
  static const String buyerType = LivestockSaleStrings.buyerType;

  /// Nombre, apellido o razon social.
  static const String buyer = LivestockSaleHistoryStrings.buyer;

  /// Documento de Transito Electronico.
  static const String dte = LivestockSaleHistoryStrings.dte;

  /// Modalidad comercial.
  static const String saleType = LivestockSaleStrings.saleType;

  /// Total pactado de la operacion.
  static const String total = LivestockSaleHistoryStrings.total;

  /// Importe recibido al registrar la venta.
  static const String collected = LivestockSaleHistoryStrings.collectedAmount;

  /// Importe que todavia no fue cobrado.
  static const String pending = LivestockSaleHistoryStrings.pendingBalance;

  /// Situacion inicial de cobro.
  static const String paymentStatus = LivestockSaleHistoryStrings.paymentStatus;

  /// Peso comercial total.
  static const String totalWeight = 'Peso total';

  /// Precio unitario pactado.
  static const String pricePerKilogram = 'Precio por kilo';

  /// Identificador electronico individual del animal.
  static const String rfid = 'RFID';

  /// Valor alternativo cuando no existe una caravana visual local.
  static const String unavailableVisualTag = 'Sin visual';

  /// Valor alternativo cuando no existe una categoria local.
  static const String unavailableCategory = LivestockSaleStrings.unavailableCategory;

  /// Valor alternativo cuando no existe un lote local.
  static const String unavailableLot = LivestockSaleStrings.unavailableLot;

  /// Mensaje cuando fallo la lectura del inventario asociado.
  static const String animalsReadFailure = 'No se pudieron consultar los animales en este dispositivo.';

  /// Nota opcional de la operacion.
  static const String observations = LivestockSaleHistoryStrings.observations;

  /// Aclaracion legal sobre los importes.
  static const String informationalAmountsNotice = LivestockSaleHistoryStrings.informationalAmountsNotice;

  /// Mensaje cuando la venta no esta disponible localmente.
  static const String notFound = 'La venta no está disponible en este dispositivo.';

  /// Accion para volver a consultar SQLite.
  static const String retry = LivestockSaleHistoryStrings.retry;

  /// Comprador frigorifico.
  static const String slaughterhouse = LivestockSaleStrings.slaughterhouse;

  /// Comprador mediante remate.
  static const String auction = LivestockSaleStrings.auction;

  /// Comprador particular.
  static const String privateBuyer = LivestockSaleStrings.privateBuyer;

  /// Venta por monto cerrado.
  static const String bulkSale = LivestockSaleHistoryStrings.bulkSale;

  /// Venta determinada por peso.
  static const String perKilogramSale = LivestockSaleHistoryStrings.perKilogramSale;

  /// Cobro pendiente.
  static const String paymentPending = LivestockSaleHistoryStrings.paymentPending;

  /// Cobro parcial.
  static const String paymentPartial = LivestockSaleHistoryStrings.paymentPartial;

  /// Cobro completo.
  static const String paymentTotal = LivestockSaleHistoryStrings.paymentTotal;

  /// Presenta la cantidad de animales asociados.
  static String animalCount(int count) {
    return LivestockSaleHistoryStrings.animalCount(count);
  }

  /// Informa animales de la venta que no estan en el inventario local.
  static String unavailableAnimals(int count) {
    final noun = count == 1 ? 'animal no está' : 'animales no están';
    return '$count $noun disponible${count == 1 ? '' : 's'} localmente.';
  }
}
