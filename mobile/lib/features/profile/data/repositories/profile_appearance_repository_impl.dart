import 'dart:typed_data';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/profile/data/datasources/profile_appearance_local_data_source.dart';
import 'package:frontend_mayoral/features/profile/data/datasources/profile_appearance_remote_data_source.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/profile_appearance.dart';
import 'package:frontend_mayoral/features/profile/domain/repositories/profile_appearance_repository.dart';
import 'package:logging/logging.dart';

/// Offline-first: cada cambio se guarda primero en el celular y después se
/// intenta subir. Lo que no sube queda marcado y se reintenta en el próximo
/// [sync]; mientras tanto el celular manda sobre la cuenta.
class ProfileAppearanceRepositoryImpl implements ProfileAppearanceRepository {
  /// Crea el repositorio.
  ProfileAppearanceRepositoryImpl({
    required ProfileAppearanceLocalDataSource local,
    required ProfileAppearanceRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  static final _logger = Logger('ProfileAppearanceRepository');

  final ProfileAppearanceLocalDataSource _local;
  final ProfileAppearanceRemoteDataSource _remote;

  @override
  Future<Result<ProfileAppearance>> load(String userId) => _guard(() async => _toEntity(await _local.read(userId)));

  @override
  Future<Result<ProfileAppearance>> sync(String userId) => _guard(() async {
    try {
      // _push y _pull guardan cada paso apenas termina: si se corta a mitad de
      // camino, lo que ya subió no se repite.
      await _local.write(await _pull(await _push(await _local.read(userId))));
    } on _RejectedAvatar catch (rejected) {
      // El servidor no acepta esa foto: reintentarla no la va a arreglar, así
      // que se descarta y se le avisa al usuario.
      await _local.deleteAvatar(userId);
      await _local.write(_copy(await _local.read(userId), avatarPending: null, avatarUpdatedAt: null));
      throw rejected.error;
    } on DomainException catch (error) {
      // Sin señal o con el servidor caído no se pierde nada: queda pendiente.
      _logger.info('Apariencia sin sincronizar: ${error.code.name}');
    }
    return _toEntity(await _local.read(userId));
  });

  @override
  Future<Result<ProfileAppearance>> changeHeaderColor(String userId, int? color) => _guard(() async {
    final state = await _local.read(userId);
    await _local.write((
      userId: userId,
      headerColor: color == null ? null : _hex(color),
      headerColorPending: true,
      avatarUpdatedAt: state.avatarUpdatedAt,
      avatarPending: state.avatarPending,
      avatarVersion: state.avatarVersion,
    ));
    return _unwrap(await sync(userId));
  });

  @override
  Future<Result<ProfileAppearance>> changeAvatar(String userId, Uint8List jpeg) => _guard(() async {
    final state = await _local.read(userId);
    await _local.saveAvatar(userId, jpeg);
    await _local.write((
      userId: userId,
      headerColor: state.headerColor,
      headerColorPending: state.headerColorPending,
      avatarUpdatedAt: state.avatarUpdatedAt,
      avatarPending: PendingAvatarChange.upload,
      avatarVersion: state.avatarVersion + 1,
    ));
    return _unwrap(await sync(userId));
  });

  @override
  Future<Result<ProfileAppearance>> removeAvatar(String userId) => _guard(() async {
    final state = await _local.read(userId);
    await _local.deleteAvatar(userId);
    await _local.write((
      userId: userId,
      headerColor: state.headerColor,
      headerColorPending: state.headerColorPending,
      avatarUpdatedAt: null,
      avatarPending: PendingAvatarChange.delete,
      avatarVersion: state.avatarVersion + 1,
    ));
    return _unwrap(await sync(userId));
  });

  /// Sube lo pendiente. Cada paso guarda apenas termina, así un corte a mitad
  /// de camino no repite lo que ya subió.
  /// [sync] nunca falla por falta de señal: solo por el storage local.
  static ProfileAppearance _unwrap(Result<ProfileAppearance> result) {
    if (result is Success<ProfileAppearance>) {
      return result.data;
    }
    throw (result as Failure<ProfileAppearance>).error;
  }

  Future<StoredProfileAppearance> _push(StoredProfileAppearance state) async {
    var current = state;
    if (current.headerColorPending) {
      await _remote.updateHeaderColor(current.headerColor);
      current = _copy(current, headerColorPending: false);
      await _local.write(current);
    }
    switch (current.avatarPending) {
      case PendingAvatarChange.upload:
        final jpeg = await _local.readAvatar(current.userId);
        if (jpeg == null) {
          // El archivo se perdió (p. ej. se limpiaron los datos): no hay qué subir.
          current = _copy(current, avatarPending: null);
          break;
        }
        final RemoteProfileAppearance remote;
        try {
          remote = await _remote.uploadAvatar(jpeg);
        } on DomainException catch (error) {
          if (error.code == DomainErrorCode.validation) {
            throw _RejectedAvatar(error);
          }
          rethrow;
        }
        current = _copy(current, avatarPending: null, avatarUpdatedAt: remote.avatarUpdatedAt);
      case PendingAvatarChange.delete:
        await _remote.deleteAvatar();
        current = _copy(current, avatarPending: null, avatarUpdatedAt: null);
      case null:
        break;
    }
    await _local.write(current);
    return current;
  }

  /// Trae lo que cambió en la cuenta, sin pisar lo que sigue pendiente.
  Future<StoredProfileAppearance> _pull(StoredProfileAppearance state) async {
    final remote = await _remote.fetch();
    var current = state;
    if (!current.headerColorPending && remote.headerColor != current.headerColor) {
      current = _copy(current, headerColor: remote.headerColor);
    }
    if (current.avatarPending == null && remote.avatarUpdatedAt != current.avatarUpdatedAt) {
      final jpeg = remote.avatarUpdatedAt == null ? null : await _remote.downloadAvatar();
      if (jpeg == null) {
        await _local.deleteAvatar(current.userId);
      } else {
        await _local.saveAvatar(current.userId, jpeg);
      }
      current = _copy(
        current,
        avatarUpdatedAt: jpeg == null ? null : remote.avatarUpdatedAt,
        avatarVersion: current.avatarVersion + 1,
      );
    }
    return current;
  }

  Future<ProfileAppearance> _toEntity(StoredProfileAppearance state) async {
    final color = state.headerColor;
    return ProfileAppearance(
      headerColor: color == null ? null : int.tryParse('FF${color.substring(1)}', radix: 16),
      avatarPath: await _local.avatarPath(state.userId),
      avatarVersion: state.avatarVersion,
      hasPendingChanges: state.headerColorPending || state.avatarPending != null,
    );
  }

  static String _hex(int color) => '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  static StoredProfileAppearance _copy(
    StoredProfileAppearance state, {
    Object? headerColor = _keep,
    bool? headerColorPending,
    Object? avatarUpdatedAt = _keep,
    Object? avatarPending = _keep,
    int? avatarVersion,
  }) {
    return (
      userId: state.userId,
      headerColor: identical(headerColor, _keep) ? state.headerColor : headerColor as String?,
      headerColorPending: headerColorPending ?? state.headerColorPending,
      avatarUpdatedAt: identical(avatarUpdatedAt, _keep) ? state.avatarUpdatedAt : avatarUpdatedAt as DateTime?,
      avatarPending: identical(avatarPending, _keep) ? state.avatarPending : avatarPending as PendingAvatarChange?,
      avatarVersion: avatarVersion ?? state.avatarVersion,
    );
  }

  static const _keep = Object();

  Future<Result<ProfileAppearance>> _guard(Future<ProfileAppearance> Function() action) async {
    try {
      return Result.success(await action());
    } on DomainException catch (error) {
      return Result.failure(error);
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudo guardar la apariencia del perfil', error, stackTrace);
      return const Result.failure(
        DomainException(message: 'No se pudo guardar el cambio en el celular. Probá de nuevo.'),
      );
    }
  }
}

/// La foto pendiente que el servidor rechazó por su contenido.
class _RejectedAvatar implements Exception {
  const _RejectedAvatar(this.error);

  final DomainException error;
}
