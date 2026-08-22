part of 'sign_up_bloc.dart';

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
@freezed
sealed class SignUpState with _$SignUpState {
  /// Crea un estado del flujo de registro.
  const factory SignUpState({
    /// Etapa que la interfaz debe comunicar al usuario.
    required SignUpStage stage,

    /// Sesion persistida luego del auto-login exitoso.
    AuthSession? session,

    /// Error bloqueante de registro o auto-login.
    DomainException? error,

    /// Indica que el alta termino aunque un paso posterior haya fallado.
    @Default(false) bool accountCreated,
  }) = _SignUpState;

  const SignUpState._();

  /// Estado inicial del formulario.
  factory SignUpState.initial() => const SignUpState(stage: SignUpStage.idle);

  /// Indica si debe mantenerse deshabilitado el formulario.
  bool get isProcessing => switch (stage) {
    SignUpStage.registering || SignUpStage.success => true,
    _ => false,
  };
}
