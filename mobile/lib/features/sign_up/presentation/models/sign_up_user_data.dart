/// Datos del usuario que se muestran al finalizar el registro.
class SignUpUserData {
  /// Crea los datos seguros que pueden navegar a la pantalla de exito.
  const SignUpUserData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cuit,
  });

  /// Nombre del usuario registrado.
  final String firstName;

  /// Apellido del usuario registrado.
  final String lastName;

  /// Correo del usuario registrado.
  final String email;

  /// CUIT/CUIL del usuario registrado.
  final String cuit;

  /// Nombre completo que se muestra en el resumen.
  String get fullName => '$firstName $lastName'.trim();

  /// Iniciales usadas por el avatar del resumen.
  String get initials {
    final firstInitial = firstName.trim().isEmpty ? '' : firstName.trim()[0];
    final lastInitial = lastName.trim().isEmpty ? '' : lastName.trim()[0];
    return '$firstInitial$lastInitial'.toUpperCase();
  }
}
