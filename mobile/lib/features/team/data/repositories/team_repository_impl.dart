import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/authentication/data/establishment_remote_summary.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/team/data/datasources/team_remote_data_source.dart';
import 'package:frontend_mayoral/features/team/data/team_json.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:frontend_mayoral/features/team/domain/repositories/team_repository.dart';
import 'package:logging/logging.dart';

/// Serializa lecturas/refrescos/mutaciones para no perder cambios confirmados.
/// Cerrar una pantalla no cancela una mutación remota ni su persistencia.
class TeamRepositoryImpl implements TeamRepository {
  /// Crea el repositorio con almacenamiento y transporte inyectables.
  TeamRepositoryImpl({
    required TeamRemoteDataSource remote,
    required SecureStorageService secureStorage,
    required EstablishmentCatalog establishmentCatalog,
    DateTime Function()? clock,
    TeamOperationQueue? operations,
    Future<void> Function(Future<void> Function())? persistSessionData,
    Future<void> Function(Future<PostAuthenticationSummary> Function())? updateCatalog,
    bool Function()? isSessionCurrent,
  }) : _remote = remote,
       _secureStorage = secureStorage,
       _catalog = establishmentCatalog,
       _clock = clock ?? DateTime.now,
       _operations = operations ?? TeamOperationQueue(),
       _persistSessionData = persistSessionData ?? ((persist) => persist()),
       _updateCatalog =
           updateCatalog ??
           ((persist) async {
             await persist();
           }),
       _isSessionCurrent = isSessionCurrent ?? (() => true);

  final TeamRemoteDataSource _remote;
  final SecureStorageService _secureStorage;
  final EstablishmentCatalog _catalog;
  final DateTime Function() _clock;
  final Future<void> Function(Future<PostAuthenticationSummary> Function()) _updateCatalog;
  final bool Function() _isSessionCurrent;
  final Future<void> Function(Future<void> Function()) _persistSessionData;

  void _requireSession() {
    if (!_isSessionCurrent()) {
      throw const DomainException(message: 'Session changed', code: DomainErrorCode.unauthorized);
    }
  }

  final TeamOperationQueue _operations;
  static final _logger = Logger('TeamRepository');

  Future<T> _serialize<T>(Future<T> Function() action) => _operations.run(action);

  @override
  Future<Result<EstablishmentMembership?>> findEstablishment(String establishmentId) =>
      _guard(() => _catalog.getById(establishmentId));

  @override
  Future<Result<TeamSnapshot?>> readCached(String establishmentId) =>
      _serialize(() => _guard(() => _cached(establishmentId)));

  Future<TeamSnapshot?> _cached(String id) async {
    final entry = (await _readCache())[id];
    if (entry is! Map<String, dynamic>) return null;
    return _snapshotFromJson(entry);
  }

  @override
  Future<Result<TeamSnapshot>> refresh(String establishmentId) => _serialize(
    () => _guard(() async {
      final members = await _remote.fetchMembers(establishmentId);
      final invitations = await _remote.fetchInvitations(establishmentId);
      final snapshot = TeamSnapshot(members: members, invitations: invitations, fetchedAt: _clock());
      await _writeSnapshot(establishmentId, snapshot);
      return snapshot;
    }),
  );

  @override
  Future<Result<TeamMutation<CreatedInvitation>>> invite(
    String establishmentId, {
    required String email,
    required UserRole role,
  }) => _mutate(
    establishmentId,
    () => _remote.invite(establishmentId, email: email.trim().toLowerCase(), role: role),
    (created) => TeamChange.invitation(created.invitation),
  );

  @override
  Future<Result<TeamMutation<CreatedInvitation>>> resend(String establishmentId, String invitationId) => _mutate(
    establishmentId,
    () => _remote.resend(establishmentId, invitationId),
    (created) => TeamChange.invitation(created.invitation),
  );

  @override
  Future<Result<TeamMutation<void>>> cancel(String establishmentId, String invitationId) => _mutate<void>(
    establishmentId,
    () => _remote.cancel(establishmentId, invitationId),
    (_) => TeamChange.cancelled(invitationId),
  );

  @override
  Future<Result<TeamMutation<void>>> removeMember(String establishmentId, String userId) => _mutate<void>(
    establishmentId,
    () => _remote.removeMember(establishmentId, userId),
    (_) => TeamChange.removed(userId),
  );

  Future<Result<TeamMutation<T>>> _mutate<T>(
    String id,
    Future<T> Function() remote,
    TeamChange Function(T) changeForValue,
  ) => _serialize(
    () => _guard(() async {
      var cached = await _guard(() => _cached(id));
      final value = await remote();
      // Si volvió el storage, releer la base antes de escribir evita reemplazar
      // un equipo completo por el único cambio que conocemos.
      if (cached is Failure<TeamSnapshot?>) cached = await _guard(() => _cached(id));
      final baseline = cached is Success<TeamSnapshot?> ? cached.data : null;
      final change = changeForValue(value);
      final snapshot = change.apply(
        baseline ??
            TeamSnapshot(
              members: const [],
              invitations: const [],
              fetchedAt: _clock(),
              isComplete: false,
            ),
      );
      // Sin base legible no se sobreescribe el registro existente.
      final persisted = cached is Failure<TeamSnapshot?>
          ? Result<void>.failure(cached.error)
          : await _guard(() => _writeSnapshot(id, snapshot));
      return TeamMutation(
        value: value,
        change: change,
        snapshot: snapshot,
        persistenceError: persisted is Failure<void> ? persisted.error : null,
      );
    }),
  );

  @override
  Future<Result<InvitationPreview>> preview(String code) => _guard(() => _remote.preview(code));

  @override
  Future<Result<TeamAcceptance>> accept(String code) => _serialize(() async {
    final response = await _guard(() => _remote.accept(code));
    return response.when(success: _accepted, failure: (error) async => Result.failure(error));
  });

  Future<Result<TeamAcceptance>> _accepted(Map<String, dynamic> data) async {
    final parsed = await _guard(() async => EstablishmentRemoteSummary.fromJson(data));
    if (parsed case Success<EstablishmentRemoteSummary>(:final data)) {
      final membership = EstablishmentMembership(id: data.id, name: data.name, role: data.role);
      final persisted = await _guard(
        () => _updateCatalog(() async {
          await _persistSessionData(() async {
            _requireSession();
            await _catalog.upsert(membership, metadata: data.toJson());
          });
          final memberships = await _catalog.getMemberships();
          return PostAuthenticationSummary(establishmentIds: memberships.map((membership) => membership.id).toList());
        }),
      );
      return Result.success(
        TeamAcceptance(membership: membership, persistenceError: persisted is Failure<void> ? persisted.error : null),
      );
    }
    return Result.failure(teamError(TeamErrorReason.acceptanceNeedsRecovery));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      _requireSession();
      final value = await action();
      _requireSession();
      return Result.success(value);
    } on DomainException catch (error) {
      return Result.failure(error);
    } on FormatException catch (_, stack) {
      return _localFailure(TeamErrorReason.invalidResponse, stack);
    } on TimeoutException catch (_, stack) {
      return _localFailure(TeamErrorReason.storageUnavailable, stack);
    } on PlatformException catch (_, stack) {
      return _localFailure(TeamErrorReason.storageUnavailable, stack);
    }
  }

  Result<T> _localFailure<T>(TeamErrorReason reason, StackTrace stack) {
    _logger.warning('Team data failure: ${reason.name}', null, stack);
    return Result.failure(teamError(reason));
  }

  Future<Map<String, dynamic>> _readCache() async {
    final encoded = await _secureStorage.read(SecureStorageKeys.teamSnapshot);
    if (encoded == null || encoded.isEmpty) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Invalid team cache');
    return decoded;
  }

  Future<void> _writeSnapshot(String establishmentId, TeamSnapshot snapshot) async {
    Map<String, dynamic> cache;
    try {
      cache = await _readCache();
    } on FormatException {
      cache = {};
    }
    cache[establishmentId] = _snapshotToJson(snapshot);
    await _persistSessionData(() async {
      _requireSession();
      await _secureStorage.write(key: SecureStorageKeys.teamSnapshot, value: jsonEncode(cache));
    });
  }

  static Map<String, Object?> _snapshotToJson(TeamSnapshot snapshot) => {
    'is_complete': snapshot.isComplete,
    'fetched_at': snapshot.fetchedAt.toUtc().toIso8601String(),
    'members': [
      for (final member in snapshot.members)
        {
          'user_id': member.userId,
          'first_name': member.firstName,
          'last_name': member.lastName,
          'email': member.email,
          'role': member.role.backendValue,
          'is_holder': member.isHolder,
          'header_color': member.headerColor,
          'member_since': member.memberSince.toUtc().toIso8601String(),
        },
    ],
    'invitations': [
      for (final invitation in snapshot.invitations)
        {
          'id': invitation.id,
          'email': invitation.email,
          'role': invitation.role.backendValue,
          'expires_at': invitation.expiresAt.toUtc().toIso8601String(),
          'email_sent': invitation.emailSent,
          'created_at': invitation.createdAt.toUtc().toIso8601String(),
        },
    ],
  };

  TeamSnapshot _snapshotFromJson(Map<String, dynamic> json) => TeamSnapshot(
    isComplete: json['is_complete'] != false,
    fetchedAt: DateTime.parse(teamString(json, 'fetched_at')),
    members: [
      for (final member in teamObjects(json['members']))
        (
          userId: teamString(member, 'user_id'),
          firstName: teamString(member, 'first_name'),
          lastName: teamString(member, 'last_name'),
          email: teamString(member, 'email'),
          role: UserRolePermissions.fromBackend(teamOptionalString(member, 'role')),
          isHolder: member['is_holder'] == true,
          headerColor: teamOptionalString(member, 'header_color'),
          memberSince: DateTime.parse(teamString(member, 'member_since')),
        ),
    ],
    invitations: [
      for (final invitation in teamObjects(json['invitations']))
        (
          id: teamString(invitation, 'id'),
          email: teamString(invitation, 'email'),
          role: UserRolePermissions.fromBackend(teamOptionalString(invitation, 'role')),
          expiresAt: DateTime.parse(teamString(invitation, 'expires_at')),
          // El vencimiento se recalcula: la cache puede tener días.
          isExpired: !DateTime.parse(teamString(invitation, 'expires_at')).isAfter(_clock()),
          emailSent: invitation['email_sent'] == true,
          createdAt: DateTime.parse(teamString(invitation, 'created_at')),
        ),
    ],
  );
}

/// Cola perteneciente a una sesión; se comparte explícitamente entre rutas.
class TeamOperationQueue {
  Future<void>? _pending;

  /// Termina una operación persistente antes de empezar la siguiente.
  Future<T> run<T>(Future<T> Function() action) async {
    final previous = _pending;
    final completed = Completer<void>();
    _pending = completed.future;
    await previous;
    try {
      return await action();
    } finally {
      if (identical(_pending, completed.future)) _pending = null;
      completed.complete();
    }
  }
}
