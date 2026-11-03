import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';
import 'package:frontend_mayoral/features/user_manual/domain/repositories/user_manual_repository.dart';
import 'package:logging/logging.dart';

/// Lee las membresías de la persona (el catálogo offline del celular).
typedef ReadMemberships = Future<List<EstablishmentMembership>> Function();

/// Arma el manual con las secciones que la persona puede usar.
///
/// El rol es por establecimiento: con varios campos se muestra la unión de lo
/// que aplica a cada uno de sus roles. Sin un rol conocido (catálogo vacío o
/// ilegible) quedan solo las secciones generales.
class GetUserManualUseCase {
  /// Crea el caso de uso.
  const GetUserManualUseCase({
    required UserManualRepository repository,
    required ReadMemberships readMemberships,
  }) : _repository = repository,
       _readMemberships = readMemberships;

  final UserManualRepository _repository;
  final ReadMemberships _readMemberships;

  static final Logger _logger = Logger('GetUserManualUseCase');

  /// Devuelve el manual filtrado por los roles de la persona.
  Future<Result<UserManual>> call() async {
    final result = await _repository.getSections();
    if (result case Failure<List<ManualSection>>(:final error)) {
      return Result.failure(error);
    }
    final sections = (result as Success<List<ManualSection>>).data;
    final roles = await _readRoles();
    final visible = roles.isEmpty
        ? sections.where((section) => section.isGeneral)
        : sections.where((section) => section.appliesToAny(roles));
    return Result.success(UserManual(sections: List.unmodifiable(visible), userRoles: roles));
  }

  Future<Set<UserRole>> _readRoles() async {
    try {
      final memberships = await _readMemberships();
      return {for (final membership in memberships) ?_manualRole(membership.role)};
    } on Object catch (error, stackTrace) {
      // El manual se puede leer igual: con las secciones generales.
      _logger.warning('No se pudo leer el rol para filtrar el manual.', error, stackTrace);
      return const {};
    }
  }

  /// El veterinario opera hoy como empleado (adr-0012); un rol desconocido no
  /// suma secciones.
  static UserRole? _manualRole(UserRole role) => switch (role) {
    UserRole.owner || UserRole.admin || UserRole.employee => role,
    UserRole.veterinarian => UserRole.employee,
    UserRole.unknown => null,
  };
}
