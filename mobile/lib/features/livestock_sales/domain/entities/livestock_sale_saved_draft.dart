import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';

part 'livestock_sale_saved_draft.freezed.dart';

/// Etapa del flujo que debe recuperarse junto con una venta incompleta.
enum LivestockSaleDraftStep {
  /// Selección de los animales incluidos en la venta.
  animals,

  /// Datos comerciales y condición de cobro.
  operation,

  /// Resumen previo a la confirmación definitiva.
  review,
}

/// Copia local cifrada de una venta que todavia no fue confirmada.
@freezed
sealed class LivestockSaleSavedDraft with _$LivestockSaleSavedDraft {
  /// Crea el contenido suficiente para reconstruir el formulario y volver a
  /// validar las caravanas contra el inventario local.
  const factory LivestockSaleSavedDraft({
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
    required List<String> selectedRfidTagNumbers,
    required LivestockSaleDraftStep currentStep,
    required DateTime updatedAt,
  }) = _LivestockSaleSavedDraft;
}
