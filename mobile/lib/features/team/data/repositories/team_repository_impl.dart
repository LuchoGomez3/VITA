import 'dart:convert';

import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/sync/data/models/establishment_remote_summary.dart';
import 'package:frontend_mayoral/features/team/data/datasources/team_remote_data_source.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/repositories/team_repository.dart';

/// Equipo con cache local en secure storage y acciones online-only.
class TeamRepositoryImpl implements TeamRepository {
  /// Crea el repositorio.
  TeamRepositoryImpl({
    required TeamRemoteDataSource remote,
    required SecureStorageService secureStorage,
    required EstablishmentCatalog establishmentCatalog,
    DateTime Function()? clock,
  }) : _remote = remote,
       _secureStorage = secureStorage,
       _catalog = establishmentCatalog,
       _clock = clock ?? DateTime.now;

  final TeamRemoteDataSource _remote;
  final SecureStorageService _secureStorage;
  final EstablishmentCatalog _catalog;
  final DateTime Function() _clock;

  @override
  Future<TeamSnapshot?> readCached(String establishmentId) async {
    try {
      final entry = (await _readCache())[establishmentId];
      return entry is Map<String, dynamic> ? _snapshotFromJson(entry) : null;
    } on Object {
      // Una cache ilegible no es un error para el usuario: se vuelve a traer.
      return null;
    }
  }

  @override
  Future<Result<TeamSnapshot>> refresh(String establishmentId) => _guard(() async {
    final members = await _remote.fetchMembers(establishmentId);
    final invitations = await _remote.fetchInvitations(establishmentId);
    final snapshot = (members: members, invitations: invitations, fetchedAt: _clock());
    await _writeSnapshot(establishmentId, snapshot);
    return snapshot;
  });

  @override
  Future<Result<TeamInvitation>> invite(String establishmentId, {required String email, required UserRole role}) =>
      _guard(() => _remote.invite(establishmentId, email: email.trim().toLowerCase(), role: role));

  @override
  Future<Result<TeamInvitation>> resend(String establishmentId, String invitationId) =>
      _guard(() => _remote.resend(establishmentId, invitationId));

  @override
  Future<Result<void>> cancel(String establishmentId, String invitationId) =>
      _guard(() => _remote.cancel(establishmentId, invitationId));

  @override
  Future<Result<void>> removeMember(String establishmentId, String userId) =>
      _guard(() => _remote.removeMember(establishmentId, userId));

  @override
  Future<Result<InvitationPreview>> preview(String code) => _guard(() => _remote.preview(code));

  @override
  Future<Result<EstablishmentMembership>> accept(String code) => _guard(() async {
    final summary = EstablishmentRemoteSummary.fromJson(await _remote.accept(code));
    final membership = EstablishmentMembership(id: summary.id, name: summary.name, role: summary.role);
    // Mismo formato que la sincronización inicial: Perfil y Home lo leen igual.
    await _catalog.upsert(membership, metadata: summary.toJson());
    return membership;
  });

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on DomainException catch (error) {
      return Result.failure(error);
    } on FormatException catch (error) {
      return Result.failure(DomainException(message: 'Respuesta inesperada del servidor: ${error.message}'));
      // Un campo con otro tipo en la respuesta (`as String` sobre un null) es un
      // error del contrato, no un crash: se informa como respuesta inesperada.
      // ignore: avoid_catching_errors
    } on TypeError {
      return const Result.failure(DomainException(message: 'Respuesta inesperada del servidor.'));
    }
  }

  Future<Map<String, dynamic>> _readCache() async {
    final encoded = await _secureStorage.read(SecureStorageKeys.teamSnapshot);
    if (encoded == null || encoded.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(encoded);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  Future<void> _writeSnapshot(String establishmentId, TeamSnapshot snapshot) async {
    Map<String, dynamic> cache;
    try {
      cache = await _readCache();
    } on FormatException {
      cache = {};
    }
    cache[establishmentId] = _snapshotToJson(snapshot);
    await _secureStorage.write(key: SecureStorageKeys.teamSnapshot, value: jsonEncode(cache));
  }

  static Map<String, Object?> _snapshotToJson(TeamSnapshot snapshot) => {
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

  TeamSnapshot _snapshotFromJson(Map<String, dynamic> json) => (
    fetchedAt: DateTime.parse(json['fetched_at'] as String),
    members: [
      for (final member in (json['members'] as List).cast<Map<String, dynamic>>())
        (
          userId: member['user_id'] as String,
          firstName: member['first_name'] as String,
          lastName: member['last_name'] as String,
          email: member['email'] as String,
          role: UserRolePermissions.fromBackend(member['role'] as String?),
          isHolder: member['is_holder'] == true,
          headerColor: member['header_color'] as String?,
          memberSince: DateTime.parse(member['member_since'] as String),
        ),
    ],
    invitations: [
      for (final invitation in (json['invitations'] as List).cast<Map<String, dynamic>>())
        (
          id: invitation['id'] as String,
          email: invitation['email'] as String,
          role: UserRolePermissions.fromBackend(invitation['role'] as String?),
          expiresAt: DateTime.parse(invitation['expires_at'] as String),
          // El vencimiento se recalcula: la cache puede tener días.
          isExpired: !DateTime.parse(invitation['expires_at'] as String).isAfter(_clock()),
          emailSent: invitation['email_sent'] == true,
          createdAt: DateTime.parse(invitation['created_at'] as String),
        ),
    ],
  );
}
