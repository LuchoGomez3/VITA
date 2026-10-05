import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_change.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';

/// Ficha de prueba con categorías de ambos sexos y restricciones reproductivas.
AnimalDetail animalDetailFixture() => AnimalDetail(
  id: 'animal-id',
  rfidTagNumber: '123456',
  visualTag: '123',
  sex: AnimalSex.female,
  breed: 'Angus',
  birthDate: DateTime.utc(2024),
  categoryId: 'cow',
  categoryName: 'Vaca',
  lotId: 'lot',
  lotName: 'Lote',
  establishmentId: 'establishment',
  currentWeight: 300,
  weighingMethod: AnimalWeighingMethod.manual,
  weighingDate: DateTime.utc(2026),
  syncStatus: AnimalSyncStatus.synchronized,
  updatedAt: DateTime.utc(2026),
  weightHistory: [],
  categories: const [
    AnimalDetailCategory(id: 'cow', name: 'Vaca', allowedSex: AnimalSex.female, allowsReproductiveStatus: true),
    AnimalDetailCategory(id: 'calf', name: 'Ternero', allowsReproductiveStatus: false),
    AnimalDetailCategory(id: 'bull', name: 'Toro', allowedSex: AnimalSex.male, allowsReproductiveStatus: false),
  ],
);

/// Repositorio en memoria para comprobar que la UI ejecuta la intención confirmada.
class MemoryAnimalDetailRepository implements AnimalDetailRepository {
  /// Inicia una ficha sin persistencia ni conexiones HTTP.
  MemoryAnimalDetailRepository() : detail = animalDetailFixture();

  /// Versión vigente que devuelven las lecturas.
  AnimalDetail detail;

  /// Intenciones efectivamente guardadas.
  final changes = <AnimalDetailChange>[];
  @override
  Future<Result<AnimalDetail>> getById(String animalId, {bool refreshRemote = true}) async => Result.success(detail);
  @override
  Future<Result<AnimalDetail>> applyChange(String animalId, AnimalDetailChange change) async {
    changes.add(change);
    detail = detail.copyWith(updatedAt: detail.updatedAt.add(const Duration(milliseconds: 1)));
    if (change is RecordAnimalDeath) detail = detail.copyWith(status: AnimalStatus.dead);
    if (change is UndoAnimalDeath) detail = detail.copyWith(status: change.previousStatus);
    return Result.success(detail);
  }

  @override
  Future<Result<void>> retrySync(String animalId) async => const Result.success(null);
}
