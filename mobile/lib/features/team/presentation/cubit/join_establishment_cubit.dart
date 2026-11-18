import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';

part 'join_establishment_cubit.freezed.dart';

/// Paso visual derivado del flujo y del resultado en curso.
enum JoinStep {
  /// Ingreso.
  enterCode,

  /// Validación.
  checking,

  /// Confirmación.
  confirm,

  /// Canje.
  joining,

  /// Aceptación confirmada.
  joined,

  /// Resultado remoto incierto: se recupera el catálogo sin repetir el canje.
  recovery,
}

/// Estado visual de la descarga, derivado de ResultState.
enum JoinDataSync {
  /// En curso.
  running,

  /// Terminada.
  done,

  /// Pendiente de recuperar.
  failed,
}

/// Cada paso transporta solo los datos válidos para ese paso.
@freezed
sealed class JoinFlow with _$JoinFlow {
  /// Código que todavía no se canjeó.
  const factory JoinFlow.entering({@Default('') String code}) = EnteringCode;

  /// Validación confirmada por backend.
  const factory JoinFlow.confirming({required String code, required InvitationPreview preview}) = ConfirmingInvitation;

  /// Membresía ya otorgada, sin conservar el código consumido.
  const factory JoinFlow.joined({required EstablishmentMembership membership, required InvitationPreview preview}) =
      JoinedEstablishment;

  /// Canje de resultado desconocido.
  const factory JoinFlow.recovery({required String code, required InvitationPreview preview}) = RecoveringMembership;
}

/// El flujo y las operaciones independientes tienen tipos separados.
@freezed
sealed class JoinEstablishmentState with _$JoinEstablishmentState {
  /// Estado inicial del canje.
  const factory JoinEstablishmentState({
    @Default(JoinFlow.entering()) JoinFlow flow,
    @Default(ResultState<InvitationPreview>.initial()) ResultState<InvitationPreview> validation,
    @Default(ResultState<TeamAcceptance>.initial()) ResultState<TeamAcceptance> acceptance,
    @Default(ResultState<void>.initial()) ResultState<void> persistence,
    @Default(ResultState<PostAuthenticationSummary>.initial()) ResultState<PostAuthenticationSummary> download,
  }) = _JoinEstablishmentState;
  const JoinEstablishmentState._();

  /// Paso derivado; no admite flags incompatibles con los datos del flujo.
  JoinStep get step => switch (flow) {
    EnteringCode() => validation is Loading<InvitationPreview> ? JoinStep.checking : JoinStep.enterCode,
    ConfirmingInvitation() => acceptance is Loading<TeamAcceptance> ? JoinStep.joining : JoinStep.confirm,
    JoinedEstablishment() => JoinStep.joined,
    RecoveringMembership() => JoinStep.recovery,
  };

  /// El código desaparece al confirmar el canje.
  String get code => switch (flow) {
    EnteringCode(:final code) || ConfirmingInvitation(:final code) || RecoveringMembership(:final code) => code,
    _ => '',
  };

  /// Alcance validado por backend.
  InvitationPreview? get preview => switch (flow) {
    ConfirmingInvitation(:final preview) ||
    JoinedEstablishment(:final preview) ||
    RecoveringMembership(:final preview) => preview,
    _ => null,
  };

  /// Membresía confirmada, independiente del estado del storage.
  EstablishmentMembership? get joined => switch (flow) {
    JoinedEstablishment(:final membership) => membership,
    _ => null,
  };

  /// Rechazo o error de validación/canje.
  DomainException? get error => switch (acceptance) {
    ResultError<TeamAcceptance>(:final error) => error,
    _ => switch (validation) {
      ResultError<InvitationPreview>(:final error) => error,
      _ => null,
    },
  };

  /// Estado visual de la descarga.
  JoinDataSync? get dataSync => switch (download) {
    Loading<PostAuthenticationSummary>() => JoinDataSync.running,
    Data<PostAuthenticationSummary>() => JoinDataSync.done,
    ResultError<PostAuthenticationSummary>() => JoinDataSync.failed,
    _ => null,
  };

  /// Solo un fallo de transporte permite repetir la validación sin editar.
  bool get canRetryValidation {
    final failure = error?.reason;
    return error?.code == DomainErrorCode.offline && (failure is! TeamFailure || failure.reason == null);
  }

  /// Código completo.
  bool get isComplete => code.length == JoinEstablishmentCubit.codeLength;
}

/// La pantalla posee las emisiones; la sesión posee la descarga persistente.
class JoinEstablishmentCubit extends Cubit<JoinEstablishmentState> {
  /// Crea el flujo a partir del caso de uso de dominio.
  JoinEstablishmentCubit(this._join, {bool Function()? isSessionCurrent})
    : _isSessionCurrent = isSessionCurrent ?? (() => true),
      super(const JoinEstablishmentState());
  final JoinEstablishmentUseCase _join;
  final bool Function() _isSessionCurrent;
  bool get _canPresent => !isClosed && _isSessionCurrent();
  int _revision = 0;

  /// Largo del código sin separador.
  static const codeLength = 6;

  /// Normalización idéntica a la aceptada por backend.
  static String normalize(String code) => code.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

  /// Edita solo antes de validar.
  void edit(String code) {
    if (!_canPresent || state.step != JoinStep.enterCode) return;
    final normalized = normalize(code);
    final trimmed = normalized.length > codeLength ? normalized.substring(0, codeLength) : normalized;
    if (trimmed == state.code) return;
    ++_revision;
    emit(JoinEstablishmentState(flow: JoinFlow.entering(code: trimmed)));
  }

  /// Vuelve a editar sin repetir una validación rechazada.
  void dismissError() {
    if (_canPresent && state.step == JoinStep.enterCode) {
      emit(JoinEstablishmentState(flow: JoinFlow.entering(code: state.code)));
    }
  }

  /// Descarta una validación pendiente. Una aceptación en curso no se deshace.
  void clear() {
    if (!_canPresent ||
        state.step == JoinStep.joining ||
        state.step == JoinStep.joined ||
        state.step == JoinStep.recovery) {
      return;
    }
    ++_revision;
    emit(const JoinEstablishmentState());
  }

  /// Una validación tardía no reemplaza un código nuevo ni una pantalla cerrada.
  Future<void> check() async {
    if (!_canPresent || !state.isComplete || state.step != JoinStep.enterCode) return;
    final revision = ++_revision;
    final code = state.code;
    emit(state.copyWith(validation: const ResultState.loading()));
    final result = await _join.preview(code);
    if (!_canPresent || revision != _revision) return;
    switch (result) {
      case Success<InvitationPreview>(:final data):
        emit(
          state.copyWith(
            flow: JoinFlow.confirming(code: code, preview: data),
            validation: ResultState.data(data),
          ),
        );
      case Failure<InvitationPreview>(:final error):
        emit(state.copyWith(validation: ResultState.error(error)));
    }
  }

  /// Una confirmación remota continúa guardándose y descargándose al salir.
  Future<void> confirm() async {
    if (!_canPresent || state.step != JoinStep.confirm) return;
    final flow = state.flow;
    if (flow is! ConfirmingInvitation) return;
    await _accept(flow.code, flow.preview);
  }

  Future<void> _accept(String code, InvitationPreview preview) async {
    emit(state.copyWith(acceptance: const ResultState.loading()));
    final result = await _join.accept(code);
    if (!_isSessionCurrent()) return;
    switch (result) {
      case Success<TeamAcceptance>(:final data):
        if (_canPresent) {
          emit(
            state.copyWith(
              flow: JoinFlow.joined(membership: data.membership, preview: preview),
              acceptance: ResultState.data(data),
              persistence: data.persistenceError == null
                  ? const ResultState.data(null)
                  : ResultState.error(data.persistenceError!),
              download: const ResultState.loading(),
            ),
          );
        }
        // El coordinador de sesión posee sus recursos y sobrevive a esta ruta.
        final synced = await _join.synchronize();
        if (!_canPresent) return;
        await _publishSync(synced);
      case Failure<TeamAcceptance>(:final error):
        if (!_canPresent) return;
        final reason = error.reason;
        final uncertain = reason is TeamFailure && reason.reason == TeamErrorReason.acceptanceNeedsRecovery;
        emit(
          state.copyWith(
            flow: uncertain
                ? JoinFlow.recovery(code: code, preview: preview)
                : JoinFlow.confirming(code: code, preview: preview),
            acceptance: ResultState.error(error),
          ),
        );
    }
  }

  /// Recupera catálogo/descarga sin volver a usar el código.
  Future<void> recover() async {
    if (!_canPresent ||
        state.acceptance is Loading<TeamAcceptance> ||
        state.download is Loading<PostAuthenticationSummary> ||
        (state.step != JoinStep.joined && state.step != JoinStep.recovery)) {
      return;
    }
    if (state.flow case RecoveringMembership(:final code, :final preview)) {
      // El servidor reconoce exclusivamente el reintento del aceptante y
      // devuelve su acceso vigente. La caché no prueba que el canje ocurrió.
      await _accept(code, preview);
      return;
    }
    emit(state.copyWith(download: const ResultState.loading()));
    final result = await _join.synchronize();
    if (!_canPresent) return;
    await _publishSync(result);
  }

  Future<void> _publishSync(Result<PostAuthenticationSummary> result) async {
    if (state.flow case JoinedEstablishment(
      :final membership,
    ) when result is Failure<PostAuthenticationSummary> && state.persistence is ResultError<void>) {
      // La descarga puede fallar después de guardar el catálogo. Una entrada
      // anterior con otro rol o nombre no acredita el guardado de este canje.
      final persisted = await _join.hasPersistedMembership(membership);
      if (!_canPresent) return;
      if (persisted case Success<bool>(data: true)) {
        emit(state.copyWith(persistence: const ResultState.data(null)));
      }
    }
    switch (result) {
      case Success<PostAuthenticationSummary>(:final data):
        emit(state.copyWith(download: ResultState.data(data), persistence: const ResultState.data(null)));
      case Failure<PostAuthenticationSummary>(:final error):
        emit(state.copyWith(download: ResultState.error(error)));
    }
  }
}
