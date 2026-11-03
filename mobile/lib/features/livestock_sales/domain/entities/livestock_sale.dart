import 'package:freezed_annotation/freezed_annotation.dart';

part 'livestock_sale.freezed.dart';

/// Canal comercial del comprador.
enum LivestockSaleBuyerType {
  /// Industria frigorifica.
  slaughterhouse('frigorifico'),

  /// Venta realizada mediante remate.
  auction('remate'),

  /// Comprador particular.
  privateBuyer('particular');

  const LivestockSaleBuyerType(this.value);

  /// Valor estable del contrato backend.
  final String value;
}

/// Modalidad usada para determinar el precio de la tropa.
enum LivestockSaleType {
  /// Monto cerrado para todos los animales.
  bulk('al_bulto'),

  /// Peso comercial multiplicado por un precio por kilo.
  perKilogram('por_kilo');

  const LivestockSaleType(this.value);

  /// Valor estable del contrato backend.
  final String value;
}

/// Situacion de cobro elegida al confirmar la venta.
enum LivestockSalePaymentCondition {
  /// Se cobra todo el monto al confirmar.
  total('total'),

  /// Se cobra una parte y queda saldo pendiente.
  partial('parcial'),

  /// No se recibe dinero al confirmar.
  pending('pendiente');

  const LivestockSalePaymentCondition(this.value);

  /// Valor estable del contrato backend.
  final String value;
}

/// Instrumento con el que se recibe un cobro.
enum LivestockSalePaymentMethod {
  /// Dinero en efectivo.
  cash('efectivo'),

  /// Transferencia bancaria.
  bankTransfer('transferencia'),

  /// Cheque.
  check('cheque'),

  /// Tarjeta de debito o credito.
  card('tarjeta');

  const LivestockSalePaymentMethod(this.value);

  /// Valor estable del contrato backend.
  final String value;
}

/// Estado local de sincronizacion expuesto al dominio.
enum LivestockSaleSyncStatus {
  /// Guardada localmente y pendiente de envio o reintento.
  pending,

  /// Confirmada por backend.
  synchronized,

  /// Requiere correccion o conciliacion.
  rejected,
}

/// Cobro que nace junto con una venta total o parcial.
@freezed
sealed class LivestockSaleInitialPayment with _$LivestockSaleInitialPayment {
  /// Crea un cobro con identidad offline propia.
  const factory LivestockSaleInitialPayment({
    required String id,
    required DateTime date,
    required int amountCents,
    required LivestockSalePaymentMethod method,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? observations,
  }) = _LivestockSaleInitialPayment;
}

/// Datos de cobro todavia no persistidos, provenientes del formulario.
@freezed
sealed class LivestockSaleInitialPaymentDraft with _$LivestockSaleInitialPaymentDraft {
  /// Crea el cobro inicial solicitado por el usuario.
  const factory LivestockSaleInitialPaymentDraft({
    required DateTime date,
    required int amountCents,
    required LivestockSalePaymentMethod method,
    String? observations,
  }) = _LivestockSaleInitialPaymentDraft;
}

/// Datos editables de una venta antes de asignarle identidad y auditoria.
@freezed
sealed class LivestockSaleDraft with _$LivestockSaleDraft {
  /// Crea el borrador que completan formulario y resumen.
  const factory LivestockSaleDraft({
    required String establishmentId,
    required DateTime operationDate,
    required LivestockSaleBuyerType buyerType,
    required String buyerName,
    required bool isCompany,
    required String dteNumber,
    required LivestockSaleType saleType,
    required int totalAmountCents,
    required List<String> animalIds,
    required LivestockSalePaymentCondition paymentCondition,
    String? buyerLastName,
    int? totalWeightGrams,
    int? pricePerKgMicros,
    String? observations,
    LivestockSaleInitialPaymentDraft? initialPayment,
  }) = _LivestockSaleDraft;
}

/// Venta completa lista para persistirse primero en SQLite.
@freezed
sealed class LivestockSale with _$LivestockSale {
  /// Crea una operacion comercial identificable e idempotente.
  const factory LivestockSale({
    required String id,
    required String establishmentId,
    required DateTime operationDate,
    required LivestockSaleBuyerType buyerType,
    required String buyerName,
    required bool isCompany,
    required String dteNumber,
    required LivestockSaleType saleType,
    required int totalAmountCents,
    required List<String> animalIds,
    required LivestockSalePaymentCondition paymentCondition,
    required DateTime createdAt,
    required DateTime updatedAt,
    required LivestockSaleSyncStatus syncStatus,
    String? buyerLastName,
    int? totalWeightGrams,
    int? pricePerKgMicros,
    String? observations,
    LivestockSaleInitialPayment? initialPayment,
    String? syncErrorCode,
  }) = _LivestockSale;
}
