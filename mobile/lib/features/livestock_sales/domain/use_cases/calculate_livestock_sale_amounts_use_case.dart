import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_amounts.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/services/livestock_sale_amount_calculator.dart';

/// Resuelve total, cobro inicial y saldo sin depender de textos o widgets.
class CalculateLivestockSaleAmountsUseCase {
  /// Crea un calculador puro para entradas parciales del formulario.
  const CalculateLivestockSaleAmountsUseCase();

  /// Calcula importes exactos; la confirmacion valida los limites comerciales.
  LivestockSaleAmounts call({
    required LivestockSaleType saleType,
    required LivestockSalePaymentCondition paymentCondition,
    int? bulkTotalCents,
    int? totalWeightGrams,
    int? pricePerKgMicros,
    int? partialPaymentCents,
  }) {
    int? total;
    if (saleType == LivestockSaleType.bulk) {
      total = bulkTotalCents;
    } else if (totalWeightGrams != null && totalWeightGrams > 0 && pricePerKgMicros != null && pricePerKgMicros > 0) {
      try {
        total = LivestockSaleAmountCalculator.totalCents(
          totalWeightGrams: totalWeightGrams,
          pricePerKgMicros: pricePerKgMicros,
        );
      } on FormatException {
        total = null;
      }
    }
    if (total != null && total <= 0) total = null;
    final payment = switch (paymentCondition) {
      LivestockSalePaymentCondition.total => total,
      LivestockSalePaymentCondition.partial => partialPaymentCents,
      LivestockSalePaymentCondition.pending => null,
    };
    final canCalculateBalance =
        total != null && (paymentCondition == LivestockSalePaymentCondition.pending || payment != null);
    final balance = canCalculateBalance ? total - (payment ?? 0) : null;
    return LivestockSaleAmounts(
      totalCents: total,
      initialPaymentCents: payment,
      pendingCents: balance != null && balance >= 0 ? balance : null,
    );
  }
}
