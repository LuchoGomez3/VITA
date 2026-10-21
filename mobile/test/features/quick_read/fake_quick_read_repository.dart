import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';
import 'package:frontend_mayoral/features/quick_read/domain/repositories/quick_read_repository.dart';

/// Animal registrado de prueba (datos sintéticos).
QuickReadAnimal quickReadAnimal(
  String id, {
  String visualTag = '004 0028',
  String rfid = '982000412884005',
  String establishmentId = 'campo-1',
  String lotName = 'El Bajo',
  double? weightKg = 442,
}) => QuickReadAnimal(
  animal: MovementAnimal(
    id: id,
    establishmentId: establishmentId,
    visualTag: visualTag,
    rfidTagNumber: rfid,
    breed: 'Hereford',
    categoryName: 'Novillo',
    lotId: 'lote-$lotName',
    lotName: lotName,
  ),
  lastWeightKg: weightKg,
  lastWeighingDate: weightKg == null ? null : DateTime(2026, 10, 12),
);

/// Repositorio en memoria: [byTag] se busca por caravana visual o RFID.
class FakeQuickReadRepository implements QuickReadRepository {
  /// Crea el repositorio.
  FakeQuickReadRepository({
    Map<String, QuickReadAnimal>? byTag,
    this.establishments = const [
      EstablishmentMembership(id: 'campo-1', name: 'La Sirena', role: UserRole.owner),
    ],
  }) : byTag = byTag ?? {};

  /// Animales por caravana; se puede cambiar en el test (alta, movimiento).
  final Map<String, QuickReadAnimal> byTag;

  /// Establecimientos del usuario.
  final List<EstablishmentMembership> establishments;

  @override
  Future<Result<QuickReadAnimal?>> findByTag(String tag) async => Result.success(byTag[tag]);

  @override
  Future<Result<QuickReadAnimal?>> getAnimal(String animalId) async =>
      Result.success(byTag.values.where((animal) => animal.animal.id == animalId).firstOrNull);

  @override
  Future<Result<List<EstablishmentMembership>>> getEstablishments() async => Result.success(establishments);
}
