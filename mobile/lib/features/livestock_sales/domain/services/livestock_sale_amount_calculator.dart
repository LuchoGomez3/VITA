/// Calcula importes de venta por kilo usando aritmetica decimal exacta.
abstract final class LivestockSaleAmountCalculator {
  /// Maximo representable por `numeric(14, 2)` expresado en centavos.
  static const maximumTotalCents = 99999999999999;

  /// Convierte gramos por micro-pesos/kg al monto final en centavos.
  ///
  /// El precio unitario nunca se redondea. El resultado comercial se trunca a
  /// centavos para aplicar la misma regla que el backend.
  static int totalCents({
    required int totalWeightGrams,
    required int pricePerKgMicros,
  }) {
    if (totalWeightGrams <= 0 || pricePerKgMicros <= 0) {
      throw ArgumentError('Weight and price must be positive.');
    }
    final product = BigInt.from(totalWeightGrams) * BigInt.from(pricePerKgMicros);
    final centsDivisor = BigInt.from(10000000);
    final truncatedCents = product ~/ centsDivisor;
    if (truncatedCents > BigInt.from(maximumTotalCents)) {
      throw const FormatException('Calculated total exceeds backend precision.');
    }
    return truncatedCents.toInt();
  }
}
