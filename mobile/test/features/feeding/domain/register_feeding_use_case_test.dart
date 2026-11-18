import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:frontend_mayoral/features/feeding/domain/repositories/feeding_repositories.dart';
import 'package:frontend_mayoral/features/feeding/domain/use_cases/feeding_use_cases.dart';

void main() {
  late _MemoryRegisterRepository repository;
  late RegisterFeedingUseCase register;
  var ids = 0;

  setUp(() {
    ids = 0;
    repository = _MemoryRegisterRepository();
    register = RegisterFeedingUseCase(
      repository: repository,
      createId: () => 'id-${++ids}',
      now: () => DateTime(2026, 11, 17, 15),
    );
  });

  Future<Result<int>> registerWith({
    List<String> animals = const ['a1', 'a2'],
    String quantity = '2,5',
    String? foodId = 'maiz',
    NewFoodInput? newFood,
    DateTime? start,
    DateTime? end,
    String? reason,
  }) => register(
    establishmentId: 'est-1',
    type: FeedingType.supplement,
    animalIds: animals,
    quantityText: quantity,
    unitCode: 'kg',
    basis: FeedingQuantityBasis.perAnimalDay,
    startDate: start ?? DateTime(2026, 11, 10, 18),
    endDate: end,
    foodId: foodId,
    newFood: newFood,
    reason: reason,
  );

  test('guarda un registro para varios animales con cantidad decimal', () async {
    final result = await registerWith(reason: '  Sequía ');

    expect((result as Success<int>).data, 2);
    final record = repository.records.single;
    expect(record.quantity, '2.5');
    expect(record.startDate, DateTime(2026, 11, 10));
    expect(record.animalIds, ['a1', 'a2']);
    expect(record.reason, 'Sequía');
    expect(repository.newFoods, [null]);
  });

  test('un alimento nuevo se guarda junto con el registro y lo referencia', () async {
    await registerWith(
      foodId: null,
      newFood: const NewFoodInput(name: ' Núcleo ', categoryCode: 'concentrado', unitCode: 'bolsa'),
    );

    final food = repository.newFoods.single!;
    expect(food.name, 'Núcleo');
    expect(repository.records.single.foodId, food.id);
  });

  test('los animales repetidos se registran una sola vez', () async {
    await registerWith(animals: ['a1', 'a1', 'a2']);

    expect(repository.records.single.animalIds, ['a1', 'a2']);
  });

  final invalidos = <String, Future<Result<int>> Function()>{
    'sin animales': () => registerWith(animals: []),
    'sin alimento': () => registerWith(foodId: null),
    'cantidad cero': () => registerWith(quantity: '0'),
    'cantidad ilegible': () => registerWith(quantity: 'dos'),
    'fecha futura': () => registerWith(start: DateTime(2026, 11, 18)),
    'fin antes del inicio': () => registerWith(end: DateTime(2026, 11, 9)),
    'alimento nuevo sin nombre': () => registerWith(
      foodId: null,
      newFood: const NewFoodInput(name: ' ', categoryCode: 'otro', unitCode: 'kg'),
    ),
  };
  for (final caso in invalidos.entries) {
    test('rechaza ${caso.key} sin guardar nada', () async {
      final result = await caso.value();

      expect((result as Failure<int>).error.code, DomainErrorCode.validation);
      expect(repository.records, isEmpty);
    });
  }
}

class _MemoryRegisterRepository implements FeedingRegisterRepository {
  final List<FeedingRecord> records = [];
  final List<Food?> newFoods = [];

  @override
  Future<Result<void>> saveRecord(FeedingRecord record, {Food? newFood}) async {
    records.add(record);
    newFoods.add(newFood);
    return const Result.success(null);
  }

  @override
  Future<Result<FeedingAnimal?>> findAnimalByTag(String tag, {required String establishmentId}) async =>
      const Result.success(null);

  @override
  Future<Result<FeedingAnimal?>> getAnimal(String animalId) async => const Result.success(null);

  @override
  Future<Result<List<Food>>> getFoods(String establishmentId) async => const Result.success([]);

  @override
  Future<Result<List<FeedingLot>>> getLots(String establishmentId) async => const Result.success([]);
}
