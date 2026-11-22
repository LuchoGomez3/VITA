import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_forage_period_repository.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/save_lot_forage_period_use_case.dart';

void main() {
  late _MemoryPeriodRepository repository;
  late SaveLotForagePeriodUseCase save;

  setUp(() {
    repository = _MemoryPeriodRepository();
    save = SaveLotForagePeriodUseCase(
      repository: repository,
      createId: () => 'period-${repository.records.length + 1}',
      now: () => DateTime(2026, 11, 17, 15, 30),
    );
  });

  Future<Result<LotForagePeriod>> saveAvena({DateTime? start, DateTime? end, String code = 'avena', String? detail}) =>
      save(
        establishmentId: 'est-1',
        lotId: 'lot-1',
        resourceCode: code,
        startDate: start ?? DateTime(2026, 11, 1, 18),
        endDate: end,
        description: detail,
      );

  test('guarda el período como día calendario, sin hora', () async {
    final result = await saveAvena();

    expect(result, isA<Success<LotForagePeriod>>());
    final saved = repository.records.single;
    expect(saved.startDate, DateTime(2026, 11));
    expect(saved.updatedAt, DateTime(2026, 11, 17, 15, 30).toUtc());
  });

  test('rechaza una fecha futura', () async {
    final result = await saveAvena(start: DateTime(2026, 11, 18));

    expect((result as Failure).error.code, DomainErrorCode.validation);
    expect(repository.records, isEmpty);
  });

  test('rechaza un fin anterior al inicio', () async {
    final result = await saveAvena(end: DateTime(2026, 10, 30));

    expect((result as Failure).error.code, DomainErrorCode.validation);
  });

  test('"Otro" exige descripción', () async {
    final sinDetalle = await saveAvena(code: 'otro', detail: '   ');
    final conDetalle = await saveAvena(code: 'otro', detail: ' Alfalfa + festuca ');

    expect(sinDetalle, isA<Failure<LotForagePeriod>>());
    expect(conDetalle, isA<Success<LotForagePeriod>>());
    expect(repository.records.single.description, 'Alfalfa + festuca');
  });

  test('no permite dos períodos del mismo lote que empiezan el mismo día', () async {
    await saveAvena();

    final result = await saveAvena(code: 'sorgo');

    expect((result as Failure).error.code, DomainErrorCode.conflict);
    expect(repository.records, hasLength(1));
  });

  test('corregir un período conserva su identidad y puede mantener la fecha', () async {
    await saveAvena();
    final existing = repository.records.single;

    final result = await save(
      establishmentId: 'est-1',
      lotId: 'lot-1',
      resourceCode: 'centeno',
      startDate: existing.startDate,
      endDate: DateTime(2026, 11, 10),
      existing: existing,
    );

    expect(result, isA<Success<LotForagePeriod>>());
    final corrected = repository.records.single;
    expect(corrected.id, existing.id);
    expect(corrected.resourceCode, 'centeno');
    expect(corrected.endDate, DateTime(2026, 11, 10));
  });

  test('borrar deja un tombstone sincronizable', () async {
    await saveAvena();

    await save.delete(repository.records.single);

    expect(repository.records.single.deletedAt, isNotNull);
  });
}

class _MemoryPeriodRepository implements LotForagePeriodRepository {
  final List<LotForagePeriod> records = [];

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<Result<List<LotForagePeriod>>> getPeriods({
    required String establishmentId,
    required String lotId,
  }) async => Result.success(
    records.where((p) => p.lotId == lotId && p.deletedAt == null).toList(),
  );

  @override
  Future<Result<LotForagePeriod>> savePeriod(LotForagePeriod period) async {
    records
      ..removeWhere((p) => p.id == period.id)
      ..add(period);
    return Result.success(period);
  }
}
