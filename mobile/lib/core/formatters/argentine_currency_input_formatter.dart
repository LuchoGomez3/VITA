import 'package:flutter/services.dart';

/// Formatea importes argentinos con puntos de miles y coma decimal.
///
/// El formateador trabaja exclusivamente con texto: no convierte el monto a
/// `double`, por lo que la capa de dominio puede seguir operando con centavos
/// enteros sin introducir errores de precisión.
class ArgentineCurrencyInputFormatter extends TextInputFormatter {
  /// Crea el formateador monetario para campos de importe.
  const ArgentineCurrencyInputFormatter();

  /// Convierte un importe visual argentino a centavos enteros.
  ///
  /// Tolera espacios, simbolos monetarios y separadores de miles sin recurrir
  /// a `double`, para conservar exactamente los centavos ingresados.
  static int parseToCents(String input) {
    final cleaned = input.trim().replaceAll(RegExp(r'\s'), '');
    if (cleaned.isEmpty) {
      return 0;
    }
    final comma = cleaned.lastIndexOf(',');
    final whole = (comma < 0 ? cleaned : cleaned.substring(0, comma)).replaceAll(RegExp('[^0-9]'), '');
    final fraction = comma < 0 ? '' : cleaned.substring(comma + 1).replaceAll(RegExp('[^0-9]'), '');
    final cents = fraction.padRight(2, '0').substring(0, 2);
    return (int.tryParse(whole) ?? 0) * 100 + (int.tryParse(cents) ?? 0);
  }

  /// Formatea centavos enteros como moneda argentina para textos de lectura.
  static String formatCents(int cents) {
    final absolute = cents.abs();
    final whole = absolute ~/ 100;
    final grouped = whole.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    final sign = cents < 0 ? '- ' : '';
    return '$sign\$ $grouped,${(absolute % 100).toString().padLeft(2, '0')}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sanitized = newValue.text.replaceAll(RegExp('[^0-9,]'), '');
    if (sanitized.isEmpty) {
      return TextEditingValue.empty;
    }

    final separatorIndex = sanitized.indexOf(',');
    final hasDecimalSeparator = separatorIndex >= 0;
    final wholeInput = hasDecimalSeparator ? sanitized.substring(0, separatorIndex) : sanitized;
    final fraction = hasDecimalSeparator ? sanitized.substring(separatorIndex + 1).replaceAll(',', '') : '';
    final normalizedWhole = wholeInput.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final groupedWhole = _groupThousands(
      normalizedWhole.isEmpty ? '0' : normalizedWhole,
    );
    final decimal = fraction.substring(0, fraction.length.clamp(0, 2));
    final formatted = hasDecimalSeparator ? '$groupedWhole,$decimal' : groupedWhole;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _groupThousands(String digits) {
    final reversed = digits.split('').reversed.toList();
    final groups = <String>[];
    for (var index = 0; index < reversed.length; index += 3) {
      final end = (index + 3).clamp(0, reversed.length);
      groups.add(reversed.sublist(index, end).reversed.join());
    }
    return groups.reversed.join('.');
  }
}
