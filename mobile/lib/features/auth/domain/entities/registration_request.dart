/// Datos requeridos por el dominio para registrar un nuevo usuario.
final class RegistrationRequest {
  /// Crea una solicitud de registro con los datos validados por el formulario.
  const RegistrationRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cuit,
    required this.password,
  });

  /// Nombre que se envia al backend.
  final String firstName;

  /// Apellido que se envia al backend.
  final String lastName;

  /// Correo que se envia al backend.
  final String email;

  /// CUIT/CUIL que se envia al backend.
  final String cuit;

  /// Contrasena que se envia al backend.
  final String password;

  @override
  String toString() => 'RegistrationRequest(password: ***)';
}
