/// Validaciones puras y reutilizables para campos de formulario.
class FormValidators {
  const FormValidators._();

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _namePattern = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]*$');

  /// Valida que el campo contenga un valor no vacio.
  static String? requiredField(
    String? value, {
    String message = 'Este campo es obligatorio.',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  /// Valida un valor numerico opcional.
  static String? numeric(
    String? value, {
    String message = 'Debe ser un valor numérico.',
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return num.tryParse(value.trim()) == null ? message : null;
  }

  /// Valida los caracteres y el largo de un nombre o apellido.
  static NameValidationError? nameError(String value, {int maxLength = 50}) {
    if (!_namePattern.hasMatch(value)) {
      return NameValidationError.invalidCharacters;
    }
    if (value.length > maxLength) {
      return NameValidationError.maxLength;
    }
    return null;
  }

  /// Indica si un correo cumple el formato local `texto@texto.texto`.
  static bool isEmailValid(String value) => _emailPattern.hasMatch(value.trim());

  /// Valida el digito verificador de un CUIT/CUIL mediante modulo 11.
  static bool isCuitCheckDigitValid(String value) {
    final digits = value.replaceAll(RegExp(r'[\s-]'), '');
    if (digits.length != 11 || !RegExp(r'^\d{11}$').hasMatch(digits)) {
      return false;
    }

    const weights = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2];
    var sum = 0;
    for (var index = 0; index < weights.length; index++) {
      sum += int.parse(digits[index]) * weights[index];
    }

    final result = 11 - (sum % 11);
    final expectedCheckDigit = result == 11 ? 0 : result;
    return expectedCheckDigit != 10 && expectedCheckDigit == int.parse(digits[10]);
  }

  /// Calcula en forma pura los requisitos y la fuerza de una contraseña.
  static PasswordValidation validatePassword(String value) {
    final hasMinimumLength = value.length >= 8;
    final hasUppercase = RegExp('[A-ZÁÉÍÓÚÑÜ]').hasMatch(value);
    final hasNumber = RegExp(r'\d').hasMatch(value);
    final hasSymbol = RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value);
    final score = [
      hasMinimumLength,
      hasUppercase,
      hasNumber,
      hasSymbol,
      value.length >= 12,
    ].where((condition) => condition).length;
    final strength = switch (score) {
      <= 1 => PasswordStrength.weak,
      2 => PasswordStrength.normal,
      3 => PasswordStrength.strong,
      _ => PasswordStrength.veryStrong,
    };

    return PasswordValidation(
      hasMinimumLength: hasMinimumLength,
      hasUppercase: hasUppercase,
      hasNumber: hasNumber,
      strength: strength,
    );
  }
}

/// Motivos de rechazo posibles para un nombre o apellido.
enum NameValidationError {
  /// El texto supera el largo configurado.
  maxLength,

  /// El texto contiene caracteres distintos de letras o espacios.
  invalidCharacters,
}

/// Niveles de fortaleza calculados para una contraseña.
enum PasswordStrength {
  /// Contraseña debil.
  weak,

  /// Contraseña de fuerza normal.
  normal,

  /// Contraseña fuerte.
  strong,

  /// Contraseña muy fuerte.
  veryStrong,
}

/// Resultado inmutable de la validacion local de una contraseña.
class PasswordValidation {
  /// Crea el resultado de validacion de los requisitos de contraseña.
  const PasswordValidation({
    required this.hasMinimumLength,
    required this.hasUppercase,
    required this.hasNumber,
    required this.strength,
  });

  /// Indica si contiene al menos ocho caracteres.
  final bool hasMinimumLength;

  /// Indica si contiene al menos una mayuscula.
  final bool hasUppercase;

  /// Indica si contiene al menos un numero.
  final bool hasNumber;

  /// Fortaleza estimada usando requisitos, simbolos y largo adicional.
  final PasswordStrength strength;

  /// Indica si se cumplen todos los requisitos obligatorios.
  bool get isValid => hasMinimumLength && hasUppercase && hasNumber;
}
