/// Convierte decimales exactos entre texto e enteros escalados sin `double`.
class ScaledDecimalFormatter {
  const ScaledDecimalFormatter._();

  /// Convierte [value] a texto con exactamente [scale] decimales.
  static String format(int value, int scale) {
    if (scale < 0) throw ArgumentError.value(scale, 'scale');
    final factor = BigInt.from(10).pow(scale);
    final absolute = BigInt.from(value).abs();
    final whole = absolute ~/ factor;
    if (scale == 0) return '${value < 0 ? '-' : ''}$whole';
    final fraction = (absolute % factor).toString().padLeft(scale, '0');
    return '${value < 0 ? '-' : ''}$whole.$fraction';
  }

  /// Parsea un decimal con hasta [scale] posiciones sin truncar ni redondear.
  static int parse(String value, int scale) {
    final parsed = tryParse(value, scale);
    if (parsed == null) {
      throw const FormatException('Invalid decimal precision or range.');
    }
    return parsed;
  }

  /// Intenta parsear un decimal sin lanzar excepciones por entradas parciales.
  static int? tryParse(String value, int scale) {
    if (scale < 0) throw ArgumentError.value(scale, 'scale');
    final normalized = value.trim().replaceAll(',', '.');
    final pattern = RegExp(scale == 0 ? r'^-?\d+$' : '^[-]?\\d+(?:\\.\\d{1,$scale})?\$');
    if (!pattern.hasMatch(normalized)) {
      return null;
    }

    final negative = normalized.startsWith('-');
    final unsigned = negative ? normalized.substring(1) : normalized;
    final parts = unsigned.split('.');
    final fraction = parts.length == 1 ? '' : parts[1];
    final digits = '${parts.first}${fraction.padRight(scale, '0')}';
    final parsed = BigInt.parse(digits);
    final signed = negative ? -parsed : parsed;
    if (signed < BigInt.from(_minInt64) || signed > BigInt.from(_maxInt64)) {
      return null;
    }
    return signed.toInt();
  }

  static const _maxInt64 = 9223372036854775807;
  static const _minInt64 = -9223372036854775808;
}
