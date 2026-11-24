import 'package:flutter/services.dart';

/// Restringe la entrada a un decimal positivo con precision configurable.
///
/// Acepta coma o punto mientras el usuario escribe. La conversion exacta a
/// enteros escalados sigue perteneciendo a `ScaledDecimalFormatter`.
class ScaledDecimalInputFormatter extends TextInputFormatter {
  /// Crea un formateador que admite hasta [scale] posiciones decimales.
  ScaledDecimalInputFormatter({
    required this.scale,
    this.groupThousands = false,
  }) : assert(scale >= 0, 'La escala no puede ser negativa.'),
       _pattern = RegExp(
         scale == 0 ? r'^\d*$' : '^\\d*(?:[,.]\\d{0,$scale})?\$',
       );

  /// Cantidad maxima de posiciones decimales admitidas.
  final int scale;

  /// Muestra puntos de miles y utiliza coma como separador decimal.
  final bool groupThousands;

  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (groupThousands) {
      return _formatGrouped(oldValue, newValue);
    }
    return _pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }

  /// Convierte el texto visual agrupado al decimal canonico usado por dominio.
  static String normalizeGrouped(String value) => value.replaceAll('.', '').replaceAll(',', '.');

  /// Prepara un decimal canonico para mostrarlo dentro de un campo agrupado.
  static String formatGroupedCanonical(
    String value, {
    required int scale,
  }) {
    if (value.isEmpty) return value;
    final formatter = ScaledDecimalInputFormatter(
      scale: scale,
      groupThousands: true,
    );
    return formatter
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          ),
        )
        .text;
  }

  TextEditingValue _formatGrouped(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final input = newValue.text;
    if (input.isEmpty) return TextEditingValue.empty;
    if (RegExp('[^0-9,.]').hasMatch(input) || ','.allMatches(input).length > 1) {
      return oldValue;
    }

    final commaIndex = input.lastIndexOf(',');
    final addedDecimalPoint = commaIndex < 0 && '.'.allMatches(input).length > '.'.allMatches(oldValue.text).length;
    final decimalIndex = commaIndex >= 0
        ? commaIndex
        : addedDecimalPoint
        ? input.lastIndexOf('.')
        : -1;
    final wholeInput = decimalIndex < 0 ? input : input.substring(0, decimalIndex);
    final fractionInput = decimalIndex < 0 ? '' : input.substring(decimalIndex + 1);
    if (fractionInput.contains(RegExp('[^0-9]')) || fractionInput.length > scale) {
      return oldValue;
    }

    final wholeDigits = wholeInput.replaceAll(RegExp('[^0-9]'), '');
    final normalizedWhole = wholeDigits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final groupedWhole = _groupThousands(
      normalizedWhole.isEmpty ? '0' : normalizedWhole,
    );
    final formatted = decimalIndex < 0 ? groupedWhole : '$groupedWhole,$fractionInput';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _groupThousands(String digits) => digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
}
