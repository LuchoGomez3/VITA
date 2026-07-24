/// Shared validators for form fields.
class FormValidators {
  /// Prevents creating validator instances.
  const FormValidators._();

  /// Validates that the field has a non-empty value.
  static String? requiredField(
    String? value, {
    String message = 'Este campo es obligatorio.',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  /// Validates numeric input while allowing empty optional values.
  static String? numeric(
    String? value, {
    String message = 'Debe ser un valor numérico.',
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return num.tryParse(value.trim()) == null ? message : null;
  }
}
