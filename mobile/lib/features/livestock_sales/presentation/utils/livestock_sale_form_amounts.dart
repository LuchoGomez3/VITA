import 'package:frontend_mayoral/core/formatters/scaled_decimal_formatter.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/services/livestock_sale_amount_calculator.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/bloc/livestock_sale_bloc.dart';

/// Calcula importes de previsualizacion desde los textos del formulario.
///
/// Devuelve `null` mientras la entrada esta incompleta. La validacion comercial
/// definitiva sigue perteneciendo al caso de uso de confirmacion.
abstract final class LivestockSaleFormAmounts {
  /// Obtiene el total en centavos para cualquiera de las dos modalidades.
  static int? totalCents(LivestockSaleFormDraft form) {
    if (form.saleType == LivestockSaleType.bulk) {
      final cents = ScaledDecimalFormatter.tryParse(
        form.bulkTotalAmount,
        2,
      );
      return cents != null && cents > 0 ? cents : null;
    }

    // Peso y precio se convierten a enteros escalados para que la vista use
    // exactamente el mismo truncado que dominio, sin pasar por double.
    final totalWeightGrams = ScaledDecimalFormatter.tryParse(
      form.totalWeight,
      3,
    );
    final pricePerKilogramMicros = ScaledDecimalFormatter.tryParse(
      form.pricePerKg,
      6,
    );
    if (totalWeightGrams == null ||
        totalWeightGrams <= 0 ||
        pricePerKilogramMicros == null ||
        pricePerKilogramMicros <= 0) {
      return null;
    }
    try {
      return LivestockSaleAmountCalculator.totalCents(
        totalWeightGrams: totalWeightGrams,
        pricePerKgMicros: pricePerKilogramMicros,
      );
    } on FormatException {
      return null;
    }
  }

  /// Calcula el saldo de un cobro parcial valido.
  static int? pendingCents({
    required int? totalCents,
    required String amountToCollect,
  }) {
    if (totalCents == null) return null;
    final collectedCents = ScaledDecimalFormatter.tryParse(
      amountToCollect,
      2,
    );
    if (collectedCents == null) return null;
    final pendingCents = totalCents - collectedCents;
    return pendingCents >= 0 ? pendingCents : null;
  }
}
