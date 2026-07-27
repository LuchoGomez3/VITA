import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';

/// Evento del flujo de registro.
///
/// Los eventos expresan intenciones de UI ya validadas localmente. La validacion
/// definitiva sigue viviendo en backend y vuelve como error de dominio si el
/// email, CUIT o password no son aceptados.
sealed class SignUpEvent {
  /// Crea un evento base del registro.
  const SignUpEvent();
}

/// Solicita registrar una cuenta con datos ya validados por el formulario.
final class SignUpSubmitted extends SignUpEvent {
  /// Crea el evento de envio del formulario.
  const SignUpSubmitted({required this.request});

  /// Datos requeridos por el backend para crear el usuario.
  final RegistrationRequest request;
}
