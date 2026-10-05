part of 'livestock_sale_bloc.dart';

/// Pasos del registro de venta.
enum LivestockSaleStep {
  /// Seleccion de la tropa vendida.
  animals,

  /// Comprador, precio y cobro.
  operation,

  /// Revision previa a la confirmacion.
  review,
}

/// Campo del segundo paso al que debe dirigirse una validacion.
enum LivestockSaleFormField {
  /// Nombre de persona o razon social.
  buyerName,

  /// Apellido de una persona.
  buyerLastName,

  /// Documento de Transito Electronico.
  dteNumber,

  /// Monto pactado para una venta al bulto.
  bulkTotalAmount,

  /// Peso total comercial de una venta por kilo.
  totalWeight,

  /// Precio unitario de una venta por kilo.
  pricePerKilogram,

  /// Importe recibido al registrar un cobro parcial.
  amountToCollect,
}

/// Campos editables que deben sobrevivir al avanzar y retroceder.
@freezed
sealed class LivestockSaleFormDraft with _$LivestockSaleFormDraft {
  /// Crea el borrador completo de presentation.
  const factory LivestockSaleFormDraft({
    required String establishmentId,
    required DateTime operationDate,
    required LivestockSaleBuyerType buyerType,
    required String buyerName,
    required bool isCompany,
    required String buyerLastName,
    required String dteNumber,
    required LivestockSaleType saleType,
    required String bulkTotalAmount,
    required String totalWeight,
    required String pricePerKg,
    required LivestockSalePaymentCondition paymentCondition,
    required LivestockSalePaymentMethod paymentMethod,
    required String amountToCollect,
    required DateTime paymentDate,
    required String observations,
    required String paymentObservations,
  }) = _LivestockSaleFormDraft;

  /// Crea los valores iniciales sin inventar datos del comprador o la venta.
  factory LivestockSaleFormDraft.initial({
    required String establishmentId,
    required DateTime today,
  }) => LivestockSaleFormDraft(
    establishmentId: establishmentId,
    operationDate: DateTime(today.year, today.month, today.day),
    buyerType: LivestockSaleBuyerType.slaughterhouse,
    buyerName: '',
    isCompany: false,
    buyerLastName: '',
    dteNumber: '',
    saleType: LivestockSaleType.bulk,
    bulkTotalAmount: '',
    totalWeight: '',
    pricePerKg: '',
    paymentCondition: LivestockSalePaymentCondition.total,
    paymentMethod: LivestockSalePaymentMethod.cash,
    amountToCollect: '',
    paymentDate: DateTime(today.year, today.month, today.day),
    observations: '',
    paymentObservations: '',
  );
}

/// Estado inmutable del flujo completo de venta.
@freezed
sealed class LivestockSaleState with _$LivestockSaleState {
  /// Crea el estado compartido por las tres pantallas.
  const factory LivestockSaleState({
    required LivestockSaleFormDraft form,
    @Default(LivestockSaleStep.animals) LivestockSaleStep currentStep,
    @Default(LivestockSaleSelection()) LivestockSaleSelection selection,
    @Default(ResultState<LivestockSaleSelection>.initial()) ResultState<LivestockSaleSelection> animalSelectionResult,
    @Default(ResultState<LivestockSale>.initial()) ResultState<LivestockSale> submitResult,
    DomainException? stepError,
  }) = _LivestockSaleState;
}
