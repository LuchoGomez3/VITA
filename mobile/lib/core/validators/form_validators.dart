class FormValidators {
  static String? requiredField(
    String? value, {
    String message = 'Este campo es obligatorio.',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  static String? numeric(
    String? value, {
    String message = 'Debe ser un valor numérico.',
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return num.tryParse(value.trim()) == null ? message : null;
  }

  const FormValidators._();
}
