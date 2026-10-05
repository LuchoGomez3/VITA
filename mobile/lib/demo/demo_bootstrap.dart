import 'dart:convert';

import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/animal_observation.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';

/// Identidades estables compartidas por todos los fixtures de la demo.
abstract final class DemoIds {
  static const user = '10000000-0000-4000-8000-000000000001';
  static const establishment = '20000000-0000-4000-8000-000000000001';
  static const calfCategory = '30000000-0000-4000-8000-000000000001';
  static const steerCategory = '30000000-0000-4000-8000-000000000002';
  static const northLot = '40000000-0000-4000-8000-000000000001';
  static const southLot = '40000000-0000-4000-8000-000000000002';
  static const reserveLot = '40000000-0000-4000-8000-000000000003';
  static const animalOne = '50000000-0000-4000-8000-000000000001';
  static const animalTwo = '50000000-0000-4000-8000-000000000002';
  static const animalThree = '50000000-0000-4000-8000-000000000003';
  static const animalFour = '50000000-0000-4000-8000-000000000004';
}

/// Siembra SQLite y el catálogo local sin leer datos reales ni usar red.
class DemoBootstrap {
  const DemoBootstrap._();

  static final _repository = AppBrickRepository.instance;
  static const _storage = FlutterSecureStorageService();

  /// Restaura opcionalmente la base y luego aplica fixtures idempotentes.
  static Future<void> initialize({required bool reset}) async {
    if (reset) await _clearLocalData();
    await _seedEstablishment();
    for (final model in _categories) await _repository.upsertLocal(model);
    for (final model in _lots) await _repository.upsertLocal(model);
    for (final model in _animals) await _repository.upsertLocal(model);
    for (final model in _weighings) await _repository.upsertLocal(model);
    for (final model in _movements) await _repository.upsertLocal(model);
    for (final model in _expenses) await _repository.upsertLocal(model);
  }

  static Future<void> _seedEstablishment() => _storage.write(
    key: SecureStorageKeys.establishmentCatalog,
    value: jsonEncode([
      {
        'id': DemoIds.establishment,
        'name': 'Establecimiento La Esperanza',
        'role': 'owner',
        'renspa_number': '04.001.0.00001/00',
        'province': 'Córdoba',
        'department': 'Río Cuarto',
        'locality': 'Las Higueras',
      },
    ]),
  );

  static Future<void> _clearLocalData() async {
    await _repository.deleteAllLocal<BrickAnimalObservationModel>();
    await _repository.deleteAllLocal<BrickAnimalLotMovementModel>();
    await _repository.deleteAllLocal<BrickPesajeModel>();
    await _repository.deleteAllLocal<BrickAnimalModel>();
    await _repository.deleteAllLocal<BrickLotModel>();
    await _repository.deleteAllLocal<BrickCategoriaModel>();
    await _repository.deleteAllLocal<BrickOperatingExpenseModel>();
    await _repository.deleteAllLocal<BrickOperatingExpenseCategoryModel>();
  }

  static final _categories = [
    BrickCategoriaModel(
      localId: DemoIds.calfCategory,
      name: 'Terneros',
      description: 'Animales en recría',
      createdAt: DateTime.utc(2026, 1),
      updatedAt: DateTime.utc(2026, 1),
      syncStatus: BrickCategoriaSyncStatus.synchronized,
    ),
    BrickCategoriaModel(
      localId: DemoIds.steerCategory,
      name: 'Novillos',
      description: 'Animales en terminación',
      createdAt: DateTime.utc(2026, 1),
      updatedAt: DateTime.utc(2026, 1),
      syncStatus: BrickCategoriaSyncStatus.synchronized,
    ),
  ];

  static final _lots = [
    _lot(DemoIds.northLot, 'Potrero Norte', 325, 'alfalfa', 80, 80, 450, 380),
    _lot(DemoIds.southLot, 'Potrero Sur', 278, 'pasto_natural', 500, 100, 880, 410),
    _lot(DemoIds.reserveLot, 'Reserva', 190, 'sorgo', 250, 520, 680, 850),
  ];

  static BrickLotModel _lot(
    String id,
    String name,
    int surface,
    String forage,
    int left,
    int top,
    int right,
    int bottom,
  ) => BrickLotModel(
    localId: id,
    establishmentId: DemoIds.establishment,
    name: name,
    boundaryJson: jsonEncode({
      'type': 'LocalPolygon',
      'coordinate_space': 'establishment_canvas_v1',
      'version': 1,
      'extent': {'width': 1000, 'height': 1000},
      'vertices': [
        {'x': left, 'y': top},
        {'x': right, 'y': top},
        {'x': right, 'y': bottom},
        {'x': left, 'y': bottom},
      ],
    }),
    surfaceTenths: surface,
    forageResourceCode: forage,
    hasWater: true,
    statusCode: 'active',
    createdAt: DateTime.utc(2026, 1),
    updatedAt: DateTime.utc(2026, 9, 20),
    syncStatus: BrickLotSyncStatus.synchronized,
  );

  static final _animals = [
    _animal(DemoIds.animalOne, 'AR-DEMO-0001', '001', BrickAnimalSex.male, DemoIds.steerCategory, 'Novillos', DemoIds.southLot, 'Potrero Sur', 302),
    _animal(DemoIds.animalTwo, 'AR-DEMO-0002', '002', BrickAnimalSex.female, DemoIds.calfCategory, 'Terneros', DemoIds.northLot, 'Potrero Norte', 188),
    _animal(DemoIds.animalThree, 'AR-DEMO-0003', '003', BrickAnimalSex.male, DemoIds.steerCategory, 'Novillos', DemoIds.southLot, 'Potrero Sur', 315),
    _animal(DemoIds.animalFour, 'AR-DEMO-0004', '004', BrickAnimalSex.female, DemoIds.calfCategory, 'Terneros', DemoIds.northLot, 'Potrero Norte', 176),
  ];

  static BrickAnimalModel _animal(
    String id,
    String rfid,
    String tag,
    BrickAnimalSex sex,
    String categoryId,
    String categoryName,
    String lotId,
    String lotName,
    double weight,
  ) => BrickAnimalModel(
    localId: id,
    rfidTagNumber: rfid,
    visualTag: tag,
    sex: sex,
    breed: 'Aberdeen Angus',
    birthDate: DateTime.utc(2025, 3, 15),
    categoryId: categoryId,
    categoryName: categoryName,
    lotId: lotId,
    lotName: lotName,
    establishmentId: DemoIds.establishment,
    initialWeight: weight,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: DateTime.utc(2026, 7, 1),
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 10, 2),
    syncStatus: BrickAnimalSyncStatus.synchronized,
  );

  static final _weighings = [
    _weighing('60000000-0000-4000-8000-000000000001', DemoIds.animalOne, 329, DateTime.utc(2026, 8, 15)),
    _weighing('60000000-0000-4000-8000-000000000002', DemoIds.animalOne, 358, DateTime.utc(2026, 10, 1)),
    _weighing('60000000-0000-4000-8000-000000000003', DemoIds.animalTwo, 207, DateTime.utc(2026, 8, 15)),
    _weighing('60000000-0000-4000-8000-000000000004', DemoIds.animalTwo, 229, DateTime.utc(2026, 10, 1)),
    _weighing('60000000-0000-4000-8000-000000000005', DemoIds.animalThree, 373, DateTime.utc(2026, 10, 1)),
    _weighing('60000000-0000-4000-8000-000000000006', DemoIds.animalFour, 218, DateTime.utc(2026, 10, 1)),
  ];

  static BrickPesajeModel _weighing(String id, String animalId, double weight, DateTime date) => BrickPesajeModel(
    localId: id,
    establishmentId: DemoIds.establishment,
    animalId: animalId,
    weightKg: weight,
    date: date,
    createdAt: date,
    updatedAt: date,
    syncStatus: BrickPesajeSyncStatus.synchronized,
  );

  static final _movements = [
    BrickAnimalLotMovementModel(
      localId: '70000000-0000-4000-8000-000000000001',
      establishmentId: DemoIds.establishment,
      sourceLotId: DemoIds.northLot,
      destinationLotId: DemoIds.southLot,
      animalIdsJson: jsonEncode([DemoIds.animalOne, DemoIds.animalThree]),
      occurredAt: DateTime.utc(2026, 9, 18),
      reason: 'Cambio a lote de terminación',
      createdAt: DateTime.utc(2026, 9, 18),
      updatedAt: DateTime.utc(2026, 9, 18),
      responsibleId: DemoIds.user,
      syncStatus: BrickMovementSyncStatus.synchronized,
    ),
  ];

  static final _expenses = [
    _expense('80000000-0000-4000-8000-000000000001', '125000.00', 'costo_produccion', 'sanidad', 'Vacunas reproductivas', DateTime.utc(2026, 10, 2)),
    _expense('80000000-0000-4000-8000-000000000002', '284500.00', 'costo_produccion', 'alimentacion', 'Suplemento mineral', DateTime.utc(2026, 9, 22)),
    _expense('80000000-0000-4000-8000-000000000003', '98600.00', 'gasto_administrativo', 'combustible', 'Gasoil', DateTime.utc(2026, 9, 10)),
  ];

  static BrickOperatingExpenseModel _expense(
    String id,
    String amount,
    String type,
    String category,
    String supply,
    DateTime date,
  ) => BrickOperatingExpenseModel(
    localId: id,
    establishmentId: DemoIds.establishment,
    amount: amount,
    type: type,
    category: category,
    supply: supply,
    date: date,
    loadedById: DemoIds.user,
    loadedByName: 'Martina Demo',
    createdAt: date,
    updatedAt: date,
    syncStatus: BrickOperatingExpenseSyncStatus.synchronized,
  );
}
