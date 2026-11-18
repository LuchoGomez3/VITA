import 'package:freezed_annotation/freezed_annotation.dart';

part 'livestock_sale_amounts.freezed.dart';

/// Importes compartidos por la previsualizacion y el comando de confirmacion.
@freezed
sealed class LivestockSaleAmounts with _$LivestockSaleAmounts {
  /// Conserva null cuando una entrada todavia no permite calcular el importe.
  const factory LivestockSaleAmounts({
    int? totalCents,
    int? initialPaymentCents,
    int? pendingCents,
  }) = _LivestockSaleAmounts;
}
