import 'dart:convert';

import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/animal_observation.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';

/// Identidades estables compartidas por todos los fixtures de la demo.
abstract final class DemoIds {
  static const user = '10000000-0000-4000-8000-000000000001';
  static const establishment = '20000000-0000-4000-8000-000000000001';
  static const calfCategory = 'b9a6e57b-20ae-49b1-a7bb-17c71af546f3';
  static const steerCategory = '41da4271-bd25-4ba0-ba34-24dc6586f0f2';
  static const cowCategory = 'ef69117b-c979-4665-b13f-2b26ff0f19b3';
  static const bullCategory = 'b5e8ea91-9789-4f7e-9dad-10262f1920f4';
  static const heiferCategory = 'b6d6440c-88c6-48cc-9003-0ad2cc05f3d5';
  static const femaleCalfCategory = 'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8';
  static const fastFatteningCategory = '550e8400-e29b-41d4-a716-446655440034';
  static const northLot = '40000000-0000-4000-8000-000000000001';
  static const southLot = '40000000-0000-4000-8000-000000000002';
  static const reserveLot = '40000000-0000-4000-8000-000000000003';
  static const animalOne = '50000000-0000-4000-8000-000000000001';
  static const animalTwo = '50000000-0000-4000-8000-000000000002';
  static const animalThree = '50000000-0000-4000-8000-000000000003';
  static const animalFour = '50000000-0000-4000-8000-000000000004';

  /// Venta sintética restaurada en cada inicio para mostrar el historial.
  static const sale = '90000000-0000-4000-8000-000000000001';

  /// Cobro completo de la venta sintética, sin datos de un productor real.
  static const salePayment = '90000000-0000-4000-8000-000000000002';
}

/// Siembra SQLite y el catálogo local sin leer datos reales ni usar red.
class DemoBootstrap {
  const DemoBootstrap._();

  static final _repository = AppBrickRepository.instance;
  static const _storage = FlutterSecureStorageService();

  /// Restaura opcionalmente la base y luego aplica fixtures idempotentes.
  static Future<void> initialize({required bool reset}) async {
    // Los animales se restauran en cada inicio de la presentación. Borrar sus
    // ventas evita conservar operaciones sobre animales que vuelven al stock.
    await _repository.deleteAllLocal<BrickLivestockSaleModel>();
    if (reset) await _clearLocalData();
    await _seedEstablishment();
    for (final model in _categories) await _repository.upsertLocal(model);
    for (final model in _lots) await _repository.upsertLocal(model);
    for (final model in _animals) await _repository.upsertLocal(model);
    for (final model in _weighings) await _repository.upsertLocal(model);
    for (final model in _movements) await _repository.upsertLocal(model);
    for (final model in _expenses) await _repository.upsertLocal(model);
    await _seedSale();
  }

  /// Restaura una venta cobrada y su baja de stock de forma atómica y sin red.
  static Future<void> _seedSale() async {
    final date = DateTime.utc(2026, 10, 5);
    // Un único importe mantiene consistente el precio pactado y su cobro total.
    const totalAmount = '1200000.00';
    await _repository.runLocalTransaction((transaction) async {
      final animals = await transaction.getLocal<BrickAnimalModel>();
      final animal = animals.firstWhere((animal) => animal.localId == DemoIds.animalFour);
      // Los fixtures se escriben directamente en SQLite: no representan altas
      // reales que deban enviarse al backend ni dependen de su disponibilidad.
      await transaction.upsert(
        BrickLivestockSaleModel(
          localId: DemoIds.sale,
          establishmentId: DemoIds.establishment,
          operationDate: date,
          buyerType: 'frigorifico',
          buyerName: 'Frigorífico Demo',
          isCompany: true,
          dteNumber: '12345678-9',
          saleType: 'al_bulto',
          totalAmount: totalAmount,
          animalIdsJson: jsonEncode([DemoIds.animalFour]),
          paymentCondition: 'total',
          initialPaymentJson: jsonEncode({
            'id': DemoIds.salePayment,
            'fecha_cobro': brickLivestockSaleDateToBackend(date),
            'monto': totalAmount,
            'medio_cobro': 'transferencia',
            'created_at': date.toIso8601String(),
            'updated_at': date.toIso8601String(),
          }),
          createdAt: date,
          updatedAt: date,
          syncStatus: BrickLivestockSaleSyncStatus.synchronized,
        ),
      );
      await transaction.upsert(animal.copyWith(status: 'vendido', updatedAt: date));
    });
  }

  static Future<void> _seedEstablishment() => _storage.write(
    key: SecureStorageKeys.establishmentCatalog,
    value: jsonEncode([
      {
        'id': DemoIds.establishment,
        'owner_id': DemoIds.user,
        'name': 'Establecimiento La Esperanza',
        'role': 'owner',
        'renspa_number': '04.001.0.00001/00',
        'cuit': '20-00000000-0',
        'area_hectares': 79.3,
        'province': 'Córdoba',
        'department': 'Río Cuarto',
        'locality': 'Las Higueras',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-10-05T00:00:00.000Z',
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
      name: 'Ternero',
      description: 'Animal macho menor a un año',
      allowedSex: 'macho',
      createdAt: DateTime.utc(2026, 1),
      updatedAt: DateTime.utc(2026, 1),
      syncStatus: BrickCategoriaSyncStatus.synchronized,
    ),
    BrickCategoriaModel(
      localId: DemoIds.steerCategory,
      name: 'Novillo',
      allowedSex: 'macho',
      createdAt: DateTime.utc(2026, 1),
      updatedAt: DateTime.utc(2026, 1),
      syncStatus: BrickCategoriaSyncStatus.synchronized,
    ),
    _category(DemoIds.cowCategory, 'Vaca', 'hembra', allowsReproductiveStatus: true),
    _category(DemoIds.bullCategory, 'Toro', 'macho'),
    _category(DemoIds.heiferCategory, 'Vaquillona', 'hembra', allowsReproductiveStatus: true),
    _category(DemoIds.femaleCalfCategory, 'Ternera', 'hembra'),
    _category(DemoIds.fastFatteningCategory, 'Engorde Rápido', 'ambos'),
  ];

  static BrickCategoriaModel _category(
    String id,
    String name,
    String allowedSex, {
    bool allowsReproductiveStatus = false,
  }) => BrickCategoriaModel(
    localId: id,
    name: name,
    allowedSex: allowedSex,
    allowsReproductiveStatus: allowsReproductiveStatus,
    createdAt: DateTime.utc(2026, 10, 5),
    updatedAt: DateTime.utc(2026, 10, 5),
    syncStatus: BrickCategoriaSyncStatus.synchronized,
  );

  // Esquinas marcadas por el equipo sobre campo.png (5052 × 2846).
  // Los puntos ya incluyen la transformación del PGW y la conversión al
  // lienzo 0..1000: así el perímetro acompaña la foto rotada en todos los visores.
  // Se restauran al iniciar la demo, manteniendo los identificadores de los
  // lotes para conservar las referencias de animales y movimientos.
  static final List<BrickLotModel> _lots = [
    _lot(DemoIds.northLot, 'Potrero Norte', 325, 'alfalfa', [
      (x: 119.015, y: 756.815),
      (x: 242.048, y: 729.698),
      (x: 213.312, y: 525.987),
      (x: 90.279, y: 553.105),
    ]),
    _lot(DemoIds.southLot, 'Potrero Sur', 278, 'pasto_natural', [
      (x: 186.427, y: 530.196),
      (x: 312.569, y: 502.393),
      (x: 288.610, y: 332.542),
      (x: 162.468, y: 360.345),
    ]),
    _lot(DemoIds.reserveLot, 'Reserva', 190, 'sorgo', [
      (x: 355.874, y: 770.427),
      (x: 627.257, y: 710.612),
      (x: 590.065, y: 446.954),
      (x: 318.682, y: 506.769),
    ]),
  ];

  /// Construye cada lote con su perímetro local, sin limitarlo a un rectángulo.
  static BrickLotModel _lot(
    String id,
    String name,
    int surface,
    String forage,
    List<({double x, double y})> vertices,
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
        for (final point in vertices) {'x': point.x, 'y': point.y},
      ],
    }),
    surfaceTenths: surface,
    forageResourceCode: forage,
    hasWater: true,
    statusCode: 'activo',
    createdAt: DateTime.utc(2026, 1),
    updatedAt: DateTime.utc(2026, 9, 20),
    syncStatus: BrickLotSyncStatus.synchronized,
  );

  static final _animals = [
    _animal(
      DemoIds.animalOne,
      '999000000000001',
      '001',
      BrickAnimalSex.male,
      DemoIds.steerCategory,
      'Novillo',
      DemoIds.southLot,
      'Potrero Sur',
      302,
    ),
    _animal(
      DemoIds.animalTwo,
      '999000000000002',
      '002',
      BrickAnimalSex.female,
      DemoIds.femaleCalfCategory,
      'Ternera',
      DemoIds.northLot,
      'Potrero Norte',
      188,
    ),
    _animal(
      DemoIds.animalThree,
      '999000000000003',
      '003',
      BrickAnimalSex.male,
      DemoIds.steerCategory,
      'Novillo',
      DemoIds.southLot,
      'Potrero Sur',
      315,
    ),
    _animal(
      DemoIds.animalFour,
      '999000000000004',
      '004',
      BrickAnimalSex.female,
      DemoIds.femaleCalfCategory,
      'Ternera',
      DemoIds.northLot,
      'Potrero Norte',
      176,
    ),
    _csvAnimal(
      id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      rfid: '123123123123124',
      visualTag: '1829319823',
      sex: BrickAnimalSex.male,
      breed: 'Wagyu',
      birthDate: DateTime.utc(2026, 7, 4),
      categoryId: DemoIds.calfCategory,
      categoryName: 'Ternero',
      lotId: DemoIds.reserveLot,
      lotName: 'Reserva',
      coat: 'Overo',
      status: 'muerto',
    ),
    _csvAnimal(
      id: '550e8400-e29b-41d4-a716-446655440059',
      rfid: '123123123123123',
      visualTag: '012',
      sex: BrickAnimalSex.male,
      breed: 'Hereford',
      birthDate: DateTime.utc(2026, 1, 19),
      categoryId: DemoIds.bullCategory,
      categoryName: 'Toro',
      lotId: DemoIds.southLot,
      lotName: 'Potrero Sur',
      coat: 'Pintas',
      observations: 'Toro nuevo',
    ),
    _csvAnimal(
      id: '550e8400-e29b-41d4-a716-446655440060',
      rfid: '123123123123125',
      visualTag: '013',
      sex: BrickAnimalSex.female,
      breed: 'Angus',
      birthDate: DateTime.utc(2025, 10, 7),
      categoryId: DemoIds.cowCategory,
      categoryName: 'Vaca',
      lotId: DemoIds.northLot,
      lotName: 'Potrero Norte',
      coat: 'Rojo',
    ),
    _csvAnimal(
      id: '550e8400-e29b-41d4-a716-446655440061',
      rfid: '123123123123126',
      visualTag: '014',
      sex: BrickAnimalSex.male,
      breed: '',
      birthDate: DateTime.utc(2026, 7, 10),
      categoryId: DemoIds.bullCategory,
      categoryName: 'Toro',
      lotId: DemoIds.reserveLot,
      lotName: 'Reserva',
      coat: 'Pintas',
      observations: 'Novillo nuevo',
    ),
  ];

  static BrickAnimalModel _csvAnimal({
    required String id,
    required String rfid,
    required String visualTag,
    required BrickAnimalSex sex,
    required String breed,
    required DateTime birthDate,
    required String categoryId,
    required String categoryName,
    required String lotId,
    required String lotName,
    required String coat,
    String status = 'activo',
    String? observations,
  }) => BrickAnimalModel(
    localId: id,
    rfidTagNumber: rfid,
    visualTag: visualTag,
    sex: sex,
    breed: breed,
    birthDate: birthDate,
    categoryId: categoryId,
    categoryName: categoryName,
    lotId: lotId,
    lotName: lotName,
    establishmentId: DemoIds.establishment,
    initialWeight: null,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: DateTime.utc(2026, 10, 5),
    coat: coat,
    observations: observations,
    status: status,
    createdAt: DateTime.utc(2026, 10, 5),
    updatedAt: DateTime.utc(2026, 10, 5),
    syncStatus: BrickAnimalSyncStatus.synchronized,
  );

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
    _expense(
      '80000000-0000-4000-8000-000000000001',
      '125000.00',
      'costo_produccion',
      'sanidad',
      'Vacunas reproductivas',
      DateTime.utc(2026, 10, 2),
    ),
    _expense(
      '80000000-0000-4000-8000-000000000002',
      '284500.00',
      'costo_produccion',
      'alimentacion',
      'Suplemento mineral',
      DateTime.utc(2026, 9, 22),
    ),
    _expense(
      '80000000-0000-4000-8000-000000000003',
      '98600.00',
      'gasto_administrativo',
      'combustible',
      'Gasoil',
      DateTime.utc(2026, 9, 10),
    ),
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
