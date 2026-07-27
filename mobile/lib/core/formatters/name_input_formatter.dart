import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/validators/validators.dart';

/// Filtra nombres y reporta el motivo de cada intento invalido.
class NameInputFormatter extends TextInputFormatter {
  /// Crea un formateador de letras con un limite configurable.
  NameInputFormatter({this.onValidationChanged, this.maxLength = 50});

  /// Recibe el resultado de validacion previo a descartar la entrada.
  final ValueChanged<NameValidationError?>? onValidationChanged;

  /// Cantidad maxima de caracteres validos aceptados.
  final int maxLength;

  static final _allowedCharacters = RegExp('[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final error = FormValidators.nameError(newValue.text, maxLength: maxLength);
    onValidationChanged?.call(error);
    final filteredValue = FilteringTextInputFormatter.allow(
      _allowedCharacters,
    ).formatEditUpdate(oldValue, newValue);
    return filteredValue;
  }
}
