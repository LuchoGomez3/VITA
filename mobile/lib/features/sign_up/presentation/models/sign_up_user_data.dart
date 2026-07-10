/// Datos del usuario que se muestran al finalizar el registro.
class SignUpUserData {
  const SignUpUserData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cuit,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String cuit;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final firstInitial = firstName.trim().isEmpty ? '' : firstName.trim()[0];
    final lastInitial = lastName.trim().isEmpty ? '' : lastName.trim()[0];
    return '$firstInitial$lastInitial'.toUpperCase();
  }
}
