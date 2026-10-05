import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/demo/demo_bootstrap.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';

/// Alta temporal que conserva el establecimiento únicamente en el catálogo local.
class DemoEstablishmentRegistrationRepository implements EstablishmentRegistrationRepository {
  const DemoEstablishmentRegistrationRepository({required EstablishmentCatalog catalog}) : _catalog = catalog;

  final EstablishmentCatalog _catalog;

  @override
  Future<Result<RegisteredEstablishment>> register(EstablishmentRegistration registration) async {
    final id = generateUuidV4();
    final createdAt = DateTime.now().toUtc();
    await _catalog.upsert(
      EstablishmentMembership(id: id, name: registration.nombre, role: UserRole.owner),
      metadata: {
        'owner_id': DemoIds.user,
        'renspa_number': registration.nroRenspa,
        'cuit': registration.cuitTitular,
        'area_hectares': registration.superficieHectareas,
        'province': registration.provincia,
        'department': registration.departamento,
        'locality': registration.localidad,
        'created_at': createdAt.toIso8601String(),
        'updated_at': createdAt.toIso8601String(),
      },
    );
    return Result.success(
      RegisteredEstablishment(
        id: id,
        registration: registration,
        createdAt: createdAt,
        role: UserRole.owner,
      ),
    );
  }
}
