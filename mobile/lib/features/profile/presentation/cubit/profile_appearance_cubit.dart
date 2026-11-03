import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/profile_appearance.dart';
import 'package:frontend_mayoral/features/profile/domain/use_cases/profile_appearance_use_cases.dart';
import 'package:meta/meta.dart';

/// Qué avisarle al usuario después de un cambio.
enum ProfileAppearanceNotice {
  /// Quedó guardado en la cuenta.
  saved,

  /// Quedó guardado en el celular y se sube cuando vuelva la señal.
  savedOffline,
}

/// Estado de la apariencia de Perfil.
@immutable
class ProfileAppearanceState {
  /// Crea el estado.
  const ProfileAppearanceState({
    this.appearance = const ProfileAppearance(),
    this.isSaving = false,
    this.notice,
    this.errorMessage,
  });

  /// Color y foto actuales.
  final ProfileAppearance appearance;

  /// Si hay un cambio guardándose.
  final bool isSaving;

  /// Aviso del último cambio, para mostrarlo una vez.
  final ProfileAppearanceNotice? notice;

  /// Error del último cambio, para mostrarlo una vez.
  final String? errorMessage;

  @override
  bool operator ==(Object other) =>
      other is ProfileAppearanceState &&
      other.appearance == appearance &&
      other.isSaving == isSaving &&
      other.notice == notice &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(appearance, isSaving, notice, errorMessage);
}

/// Carga, sincroniza y cambia el color de la cabecera y la foto del usuario.
class ProfileAppearanceCubit extends Cubit<ProfileAppearanceState> {
  /// Crea el Cubit para [userId].
  ProfileAppearanceCubit({
    required String userId,
    required LoadProfileAppearanceUseCase load,
    required SyncProfileAppearanceUseCase sync,
    required ChangeHeaderColorUseCase changeHeaderColor,
    required ChangeAvatarUseCase changeAvatar,
    required RemoveAvatarUseCase removeAvatar,
  }) : _userId = userId,
       _load = load,
       _sync = sync,
       _changeHeaderColor = changeHeaderColor,
       _changeAvatar = changeAvatar,
       _removeAvatar = removeAvatar,
       super(const ProfileAppearanceState());

  final String _userId;
  final LoadProfileAppearanceUseCase _load;
  final SyncProfileAppearanceUseCase _sync;
  final ChangeHeaderColorUseCase _changeHeaderColor;
  final ChangeAvatarUseCase _changeAvatar;
  final RemoveAvatarUseCase _removeAvatar;

  /// Muestra lo guardado en el celular y después sincroniza en silencio.
  Future<void> start() async {
    _applySilently(await _load(_userId));
    _applySilently(await _sync(_userId));
  }

  /// Cambia el color de la cabecera (`null` vuelve al verde original).
  Future<void> changeHeaderColor(int? color) => _save(() => _changeHeaderColor(_userId, color));

  /// Reemplaza la foto por [jpeg].
  Future<void> changeAvatar(Uint8List jpeg) => _save(() => _changeAvatar(_userId, jpeg));

  /// Quita la foto.
  Future<void> removeAvatar() => _save(() => _removeAvatar(_userId));

  /// Limpia el aviso o el error ya mostrados.
  void clearMessages() {
    emit(ProfileAppearanceState(appearance: state.appearance, isSaving: state.isSaving));
  }

  Future<void> _save(Future<Result<ProfileAppearance>> Function() action) async {
    emit(ProfileAppearanceState(appearance: state.appearance, isSaving: true));
    final result = await action();
    if (isClosed) {
      return;
    }
    switch (result) {
      case Success<ProfileAppearance>(:final data):
        emit(
          ProfileAppearanceState(
            appearance: data,
            notice: data.hasPendingChanges ? ProfileAppearanceNotice.savedOffline : ProfileAppearanceNotice.saved,
          ),
        );
      case Failure<ProfileAppearance>(:final error):
        // Puede haber cambiado algo (p. ej. se descartó una foto rechazada).
        final current = await _load(_userId);
        if (isClosed) {
          return;
        }
        emit(
          ProfileAppearanceState(
            appearance: current is Success<ProfileAppearance> ? current.data : state.appearance,
            errorMessage: error.message,
          ),
        );
    }
  }

  void _applySilently(Result<ProfileAppearance> result) {
    if (!isClosed && result is Success<ProfileAppearance>) {
      emit(ProfileAppearanceState(appearance: result.data, isSaving: state.isSaving));
    }
  }
}
