import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';

/// Etapa visible del registro y autenticacion inicial.
enum SignUpStage {
  /// El formulario todavia no fue enviado.
  idle,

  /// El backend esta creando la cuenta.
  registering,

  /// El flujo completo termino y la sesion esta disponible.
  success,

  /// Alguna operacion bloqueante fallo.
  failure,
}

/// Estado completo del registro con auto-login.
class SignUpState {
  /// Crea un estado del flujo de registro.
  const SignUpState({
    required this.stage,
    this.session,
    this.error,
    this.accountCreated = false,
  });

  /// Estado inicial del formulario.
  const SignUpState.initial() : this(stage: SignUpStage.idle);

  /// Etapa que la interfaz debe comunicar al usuario.
  final SignUpStage stage;

  /// Sesion persistida luego del auto-login exitoso.
  final AuthSession? session;

  /// Error bloqueante de registro o auto-login.
  final DomainException? error;

  /// Indica que el alta termino aunque un paso posterior haya fallado.
  final bool accountCreated;

  /// Indica si debe mantenerse deshabilitado el formulario.
  bool get isProcessing => switch (stage) {
    SignUpStage.registering || SignUpStage.success => true,
    _ => false,
  };
}
