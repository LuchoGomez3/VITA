import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:meta/meta.dart';

/// Paso del canje de un código.
enum JoinStep {
  /// Escribiendo el código.
  enterCode,

  /// Validando el código contra el servidor.
  checking,

  /// Mostrando a qué campo y con qué rol se suma, antes de confirmar.
  confirm,

  /// Canjeando.
  joining,

  /// Ya forma parte del equipo.
  joined,
}

/// Estado de "Sumarme a otro establecimiento".
@immutable
class JoinEstablishmentState {
  /// Crea el estado.
  const JoinEstablishmentState({
    this.step = JoinStep.enterCode,
    this.code = '',
    this.preview,
    this.joined,
    this.error,
  });

  /// Paso actual.
  final JoinStep step;

  /// Código validado (el que se canjea al confirmar).
  final String code;

  /// Campo y rol del código, cuando se validó.
  final InvitationPreview? preview;

  /// Establecimiento al que se sumó.
  final EstablishmentMembership? joined;

  /// Error del último paso, para mostrarlo una vez.
  final DomainException? error;

  @override
  bool operator ==(Object other) =>
      other is JoinEstablishmentState &&
      other.step == step &&
      other.code == code &&
      other.preview == preview &&
      other.joined == joined &&
      other.error == error;

  @override
  int get hashCode => Object.hash(step, code, preview, joined, error);
}

/// Valida un código de invitación, lo previsualiza y lo canjea.
class JoinEstablishmentCubit extends Cubit<JoinEstablishmentState> {
  /// Crea el Cubit.
  JoinEstablishmentCubit(this._join) : super(const JoinEstablishmentState());

  final JoinEstablishmentUseCase _join;

  /// Largo del código sin guion.
  static const codeLength = 8;

  /// Deja solo letras y números en mayúscula, como lo compara el servidor.
  static String normalize(String code) => code.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

  /// Valida [code] y muestra el campo y el rol.
  Future<void> check(String code) async {
    final normalized = normalize(code);
    if (normalized.length != codeLength || state.step == JoinStep.checking) {
      return;
    }
    emit(JoinEstablishmentState(step: JoinStep.checking, code: normalized));
    final result = await _join.preview(normalized);
    switch (result) {
      case Success<InvitationPreview>(:final data):
        emit(JoinEstablishmentState(step: JoinStep.confirm, code: normalized, preview: data));
      case Failure<InvitationPreview>(:final error):
        emit(JoinEstablishmentState(code: normalized, error: error));
    }
  }

  /// Vuelve a escribir otro código.
  void editCode() => emit(JoinEstablishmentState(code: state.code));

  /// Canjea el código validado.
  Future<void> confirm() async {
    if (state.step != JoinStep.confirm) {
      return;
    }
    final preview = state.preview;
    emit(JoinEstablishmentState(step: JoinStep.joining, code: state.code, preview: preview));
    final result = await _join.accept(state.code);
    switch (result) {
      case Success<EstablishmentMembership>(:final data):
        emit(JoinEstablishmentState(step: JoinStep.joined, code: state.code, preview: preview, joined: data));
      case Failure<EstablishmentMembership>(:final error):
        emit(JoinEstablishmentState(step: JoinStep.confirm, code: state.code, preview: preview, error: error));
    }
  }
}
