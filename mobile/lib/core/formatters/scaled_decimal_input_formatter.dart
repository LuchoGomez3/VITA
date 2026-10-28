import 'package:flutter/services.dart';

/// Restringe la entrada a un decimal positivo con precision configurable.
///
/// Acepta coma o punto mientras el usuario escribe. La conversion exacta a
/// enteros escalados sigue perteneciendo a `ScaledDecimalFormatter`.
class ScaledDecimalInputFormatter extends TextInputFormatter {
  /// Crea un formateador que admite hasta [scale] posiciones decimales.
  ScaledDecimalInputFormatter({required this.scale})
    : assert(scale >= 0, 'La escala no puede ser negativa.'),
      _pattern = RegExp(
        scale == 0 ? r'^\d*$' : '^\\d*(?:[,.]\\d{0,$scale})?\$',
      );

  /// Cantidad maxima de posiciones decimales admitidas.
  final int scale;

  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
