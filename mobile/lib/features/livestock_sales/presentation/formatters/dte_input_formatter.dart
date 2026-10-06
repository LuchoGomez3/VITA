import 'package:flutter/services.dart';

/// Conserva solamente los caracteres admitidos por la estructura de un DTe.
class DteInputFormatter extends TextInputFormatter {
  /// Crea un formateador que preserva dígitos, guiones y letras mayúsculas.
  const DteInputFormatter();

  static final _allowedCharacters = RegExp('[0-9A-Za-z-]');
  static final _completeDte = RegExp(r'^\d+-[0-9A-Z]$');

  /// Indica si el texto contiene el numero y el verificador completos.
  static bool isValid(String value) {
    return _completeDte.hasMatch(value.trim().toUpperCase());
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // La estructura completa se valida al avanzar. Durante la edición solo se
    // filtran caracteres para permitir borrar o corregir cualquier segmento.
    final filtered = FilteringTextInputFormatter.allow(
      _allowedCharacters,
    ).formatEditUpdate(oldValue, newValue);
    return filtered.copyWith(text: filtered.text.toUpperCase());
  }
}
