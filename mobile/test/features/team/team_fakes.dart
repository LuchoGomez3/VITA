import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/repositories/team_repository.dart';

/// Secure storage en memoria.
class MemoryStorage implements SecureStorageService {
  final Map<String, String> values = {};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

const offlineError = DomainException(message: 'sin señal', code: DomainErrorCode.offline);

final TeamMember holder = (
  userId: 'u-ceci',
  firstName: 'Cecilia',
  lastName: 'Lazarte',
  email: 'ceci@example.com',
  role: UserRole.owner,
  isHolder: true,
  headerColor: '#2E7D32',
  memberSince: DateTime.utc(2026, 10),
);

final TeamMember worker = (
  userId: 'u-mariano',
  firstName: 'Mariano',
  lastName: 'Suárez',
  email: 'mariano@example.com',
  role: UserRole.employee,
  isHolder: false,
  headerColor: null,
  memberSince: DateTime.utc(2026, 10, 2),
);

final TeamInvitation pendingVet = (
  id: 'inv-1',
  email: 'vet@example.com',
  role: UserRole.veterinarian,
  expiresAt: DateTime.utc(2026, 10, 24),
  isExpired: false,
  emailSent: true,
  createdAt: DateTime.utc(2026, 10, 17),
);

TeamSnapshot snapshotOf({List<TeamMember>? members, List<TeamInvitation>? invitations}) => (
  members: members ?? [holder, worker],
  invitations: invitations ?? [pendingVet],
  fetchedAt: DateTime.utc(2026, 10, 17, 12),
);

/// Repositorio configurable que registra las llamadas.
class FakeTeamRepository implements TeamRepository {
  TeamSnapshot? cached;
  Result<TeamSnapshot> refreshResult = Result.success(snapshotOf());
  Result<CreatedInvitation> inviteResult = Result.success((invitation: pendingVet, code: '7K4-P2M'));
  Result<CreatedInvitation> resendResult = Result.success((invitation: pendingVet, code: 'Q8R-T3W'));
  Result<void> cancelResult = const Result.success(null);
  Result<void> removeResult = const Result.success(null);
  Result<InvitationPreview> previewResult = Result.success((
    establishmentId: 'campo-1',
    establishmentName: 'La Sirena',
    renspa: '07.123.0.00456/01',
    locality: 'Coronel Moldes',
    province: 'Córdoba',
    role: UserRole.veterinarian,
    email: 'vet@example.com',
    invitedBy: 'Cecilia Lazarte',
    invitedByRole: UserRole.owner,
    expiresAt: DateTime.utc(2026, 10, 24),
  ));
  Result<EstablishmentMembership> acceptResult = const Result.success(
    EstablishmentMembership(id: 'campo-1', name: 'La Sirena', role: UserRole.veterinarian),
  );

  final List<String> calls = [];

  @override
  Future<TeamSnapshot?> readCached(String establishmentId) async => cached;

  @override
  Future<Result<TeamSnapshot>> refresh(String establishmentId) async {
    calls.add('refresh');
    return refreshResult;
  }

  @override
  Future<Result<CreatedInvitation>> invite(
    String establishmentId, {
    required String email,
    required UserRole role,
  }) async {
    calls.add('invite:$email:${role.backendValue}');
    return inviteResult;
  }

  @override
  Future<Result<CreatedInvitation>> resend(String establishmentId, String invitationId) async {
    calls.add('resend:$invitationId');
    return resendResult;
  }

  @override
  Future<Result<void>> cancel(String establishmentId, String invitationId) async {
    calls.add('cancel:$invitationId');
    return cancelResult;
  }

  @override
  Future<Result<void>> removeMember(String establishmentId, String userId) async {
    calls.add('remove:$userId');
    return removeResult;
  }

  @override
  Future<Result<InvitationPreview>> preview(String code) async {
    calls.add('preview:$code');
    return previewResult;
  }

  @override
  Future<Result<EstablishmentMembership>> accept(String code) async {
    calls.add('accept:$code');
    return acceptResult;
  }
}
