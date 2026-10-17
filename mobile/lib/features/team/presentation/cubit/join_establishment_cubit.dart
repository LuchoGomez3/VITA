import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:meta/meta.dart';

/// Paso del canje de un código (pantallas `InvIngresarCodigo` → `InvExito`).
enum JoinStep {
  /// Escribiendo el código; si hay [JoinEstablishmentState.error] se muestra
  /// en rojo (`InvError`).
  enterCode,

  /// Validando el código contra el servidor.
  checking,

  /// Mostrando a qué campo y con qué rol se suma, antes de confirmar.
  confirm,

  /// Canjeando.
  joining,

  /// Ya forma parte; se bajan los datos del campo para usarlos sin señal.
  joined,
}

/// Cómo terminó la descarga de los datos del campo nuevo.
enum JoinDataSync {
  /// Bajando.
  running,

  /// Quedaron en el celular.
  done,

  /// No se pudo; se completan en la próxima sincronización.
  failed,
}

/// Estado de "Sumarme a un establecimiento".
@immutable
class JoinEstablishmentState {
  /// Crea el estado.
  const JoinEstablishmentState({
    this.step = JoinStep.enterCode,
    this.code = '',
    this.preview,
    this.joined,
    this.error,
    this.dataSync,
  });

  /// Paso actual.
  final JoinStep step;

  /// Código escrito, normalizado (sin guion y en mayúsculas).
  final String code;

  /// Campo y rol del código, cuando se validó.
  final InvitationPreview? preview;

  /// Establecimiento al que se sumó.
  final EstablishmentMembership? joined;

  /// Error del último intento; queda visible hasta que se edite el código.
  final DomainException? error;

  /// Estado de la descarga de datos después de sumarse.
  final JoinDataSync? dataSync;

  /// Si el código tiene el largo completo.
  bool get isComplete => code.length == JoinEstablishmentCubit.codeLength;

  @override
  bool operator ==(Object other) =>
      other is JoinEstablishmentState &&
      other.step == step &&
      other.code == code &&
      other.preview == preview &&
      other.joined == joined &&
      other.error == error &&
      other.dataSync == dataSync;

  @override
  int get hashCode => Object.hash(step, code, preview, joined, error, dataSync);
}

/// Valida un código de invitación, lo previsualiza, lo canjea y baja los datos
/// del campo nuevo.
class JoinEstablishmentCubit extends Cubit<JoinEstablishmentState> {
  /// Crea el Cubit; [syncData] es la sincronización inicial de la app.
  JoinEstablishmentCubit(this._join, {required PreparePostAuthentication syncData})
    : _syncData = syncData,
      super(const JoinEstablishmentState());

  final JoinEstablishmentUseCase _join;
  final PreparePostAuthentication _syncData;

  /// Largo del código sin guion.
  static const codeLength = 6;

  /// Deja solo letras y números en mayúscula, como lo compara el servidor.
  static String normalize(String code) => code.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

  /// Actualiza el código escrito (o pegado). Editar borra el error anterior.
  void edit(String code) {
    final normalized = normalize(code);
    final trimmed = normalized.length > codeLength ? normalized.substring(0, codeLength) : normalized;
    if (state.step == JoinStep.enterCode && trimmed != state.code) {
      emit(JoinEstablishmentState(code: trimmed));
    }
  }

  /// Saca el error y deja el código para corregirlo ("Volver a intentar"
  /// cuando el servidor lo rechazó: reintentar el mismo no serviría).
  void dismissError() {
    if (state.step == JoinStep.enterCode && state.error != null) {
      emit(JoinEstablishmentState(code: state.code));
    }
  }

  /// Borra el código para escribir otro ("Borrar y escribir de nuevo", "No es
  /// mi invitación").
  void clear() => emit(const JoinEstablishmentState());

  /// Valida el código escrito y muestra el campo y el rol.
  Future<void> check() async {
    if (!state.isComplete || state.step == JoinStep.checking) {
      return;
    }
    final code = state.code;
    emit(JoinEstablishmentState(step: JoinStep.checking, code: code));
    final result = await _join.preview(code);
    switch (result) {
      case Success<InvitationPreview>(:final data):
        emit(JoinEstablishmentState(step: JoinStep.confirm, code: code, preview: data));
      case Failure<InvitationPreview>(:final error):
        emit(JoinEstablishmentState(code: code, error: error));
    }
  }

  /// Canjea el código validado y baja los datos del campo.
  Future<void> confirm() async {
    if (state.step != JoinStep.confirm) {
      return;
    }
    final preview = state.preview;
    final code = state.code;
    emit(JoinEstablishmentState(step: JoinStep.joining, code: code, preview: preview));
    final result = await _join.accept(code);
    switch (result) {
      case Success<EstablishmentMembership>(:final data):
        emit(
          JoinEstablishmentState(
            step: JoinStep.joined,
            code: code,
            preview: preview,
            joined: data,
            dataSync: JoinDataSync.running,
          ),
        );
        final synced = await _syncData();
        emit(
          JoinEstablishmentState(
            step: JoinStep.joined,
            code: code,
            preview: preview,
            joined: data,
            dataSync: synced is Success ? JoinDataSync.done : JoinDataSync.failed,
          ),
        );
      case Failure<EstablishmentMembership>(:final error):
        emit(JoinEstablishmentState(step: JoinStep.confirm, code: code, preview: preview, error: error));
    }
  }
}
