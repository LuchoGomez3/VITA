/// Convierte importes entre centavos enteros y decimales del contrato backend.
class DecimalAmountFormatter {
  const DecimalAmountFormatter._();

  /// Convierte centavos enteros a un decimal canonico de dos posiciones.
  static String centsToDecimal(int cents) {
    final absolute = cents.abs();
    final sign = cents < 0 ? '-' : '';
    return '$sign${absolute ~/ 100}.${(absolute % 100).toString().padLeft(2, '0')}';
  }

  /// Convierte un decimal backend a centavos sin usar punto flotante.
  static int decimalToCents(String amount) {
    final normalized = amount.trim().replaceAll(',', '.');
    final parts = normalized.split('.');
    final whole = int.parse(parts.first);
    final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0').substring(0, 2);
    return whole * 100 + (whole < 0 ? -int.parse(fraction) : int.parse(fraction));
  }
}
