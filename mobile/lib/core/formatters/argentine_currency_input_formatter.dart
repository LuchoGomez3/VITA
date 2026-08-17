import 'package:flutter/services.dart';

/// Formatea importes argentinos con puntos de miles y coma decimal.
///
/// El formateador trabaja exclusivamente con texto: no convierte el monto a
/// `double`, por lo que la capa de dominio puede seguir operando con centavos
/// enteros sin introducir errores de precisión.
class ArgentineCurrencyInputFormatter extends TextInputFormatter {
  /// Crea el formateador monetario para campos de importe.
  const ArgentineCurrencyInputFormatter();

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
