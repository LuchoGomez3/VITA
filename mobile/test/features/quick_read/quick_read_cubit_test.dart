import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';
import 'package:frontend_mayoral/features/quick_read/domain/use_cases/quick_read_use_cases.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/cubit/quick_read_cubit.dart';

import 'fake_quick_read_repository.dart';

const _newRfid = '982000999000111';

void main() {
  late FakeQuickReadRepository repository;

  setUp(() {
    repository = FakeQuickReadRepository(
      byTag: {
        '004 0028': quickReadAnimal('a1'),
        '982000412884005': quickReadAnimal('a1'),
        '003 1287': quickReadAnimal('a2', visualTag: '003 1287', rfid: '982000412884006', lotName: 'La Cumbre'),
        'otro': quickReadAnimal('b1', visualTag: 'otro', establishmentId: 'campo-2'),
      },
    );
  });

  group('ResolveQuickReadTagUseCase', () {
    Future<Result<QuickReadItem>> resolve(
      String tag, {
      String? establishmentId,
      List<QuickReadItem> items = const [],
    }) => ResolveQuickReadTagUseCase(repository)(tag: tag, establishmentId: establishmentId, items: items);

    test('una caravana visual o RFID de un animal activo queda registrada', () async {
      final visual = (await resolve(' 004 0028 ')) as Success<QuickReadItem>;
      final rfid = (await resolve('982000412884005')) as Success<QuickReadItem>;

      expect((visual.data as RegisteredRead).animal.animal.id, 'a1');
      expect((rfid.data as RegisteredRead).animal.lastWeightKg, 442);
    });

    test('un RFID válido que no está en el celular queda para dar de alta', () async {
      final result = (await resolve('982 000 999 000 111')) as Success<QuickReadItem>;

      expect(result.data, const UnregisteredRead(_newRfid));
    });

    test('rechaza vacías, desconocidas que no son RFID, de otro campo y repetidas', () async {
      expect(((await resolve('  ')) as Failure).error.code, DomainErrorCode.validation);
      expect(((await resolve('123')) as Failure).error.code, DomainErrorCode.notFound);
      expect(((await resolve('otro', establishmentId: 'campo-1')) as Failure).error.code, DomainErrorCode.validation);
      expect(
        ((await resolve('982000412884005', items: [RegisteredRead(quickReadAnimal('a1'))])) as Failure).error.code,
        DomainErrorCode.conflict,
      );
      expect(
        ((await resolve(_newRfid, items: const [UnregisteredRead(_newRfid)])) as Failure).error.code,
        DomainErrorCode.conflict,
      );
    });
  });

  group('RefreshQuickReadUseCase', () {
    test('actualiza potreros, pasa a registrada la caravana dada de alta y saca las bajas', () async {
      final items = [
        RegisteredRead(quickReadAnimal('a1')),
        RegisteredRead(quickReadAnimal('a3')),
        const UnregisteredRead(_newRfid),
      ];
      repository.byTag['004 0028'] = quickReadAnimal('a1', lotName: 'La Cumbre');
      repository.byTag[_newRfid] = quickReadAnimal('nuevo', visualTag: '005 0001', rfid: _newRfid, weightKg: null);

      final result = (await RefreshQuickReadUseCase(repository)(items)) as Success<List<QuickReadItem>>;

      expect(result.data, hasLength(2));
      expect((result.data.first as RegisteredRead).animal.animal.lotName, 'La Cumbre');
      expect((result.data.last as RegisteredRead).animal.animal.id, 'nuevo');
    });
  });

  group('QuickReadCubit', () {
    QuickReadCubit cubit() => QuickReadCubit(
      resolveTag: ResolveQuickReadTagUseCase(repository),
      refresh: RefreshQuickReadUseCase(repository),
      getEstablishments: GetQuickReadEstablishmentsUseCase(repository),
    );

    test('con un solo establecimiento lo fija como campo de la sesión', () async {
      final reader = cubit();
      await reader.start();

      expect(reader.state.establishmentId, 'campo-1');
      expect(reader.state.establishmentName, 'La Sirena');
    });

    test('con varios establecimientos lo fija el primer animal registrado', () async {
      repository = FakeQuickReadRepository(
        byTag: {'otro': quickReadAnimal('b1', visualTag: 'otro', establishmentId: 'campo-2')},
        establishments: const [
          EstablishmentMembership(id: 'campo-1', name: 'La Sirena', role: UserRole.owner),
          EstablishmentMembership(id: 'campo-2', name: 'El Algarrobo', role: UserRole.owner),
        ],
      );
      final reader = cubit();
      await reader.start();
      expect(reader.state.establishmentId, isNull);

      expect(await reader.addTag(_newRfid), isTrue);
      expect(reader.state.establishmentId, isNull);
      expect(await reader.addTag('otro'), isTrue);
      expect(reader.state.establishmentId, 'campo-2');
    });

    test('suma lecturas con la última primero y muestra el error sin agregar', () async {
      final reader = cubit();
      await reader.start();

      await reader.addTag('004 0028');
      await reader.addTag(_newRfid);
      expect(await reader.addTag('982000412884005'), isFalse);

      expect(reader.state.items.first, const UnregisteredRead(_newRfid));
      expect(reader.state.registeredItems, hasLength(1));
      expect(reader.state.unregisteredItems, hasLength(1));
      expect(reader.state.message, contains('ya está en la lista'));

      await reader.addTag('003 1287');
      expect(reader.state.message, isNull);
    });

    test('quitar, descartar y abrir la lista', () async {
      final reader = cubit();
      await reader.start();
      await reader.addTag('004 0028');
      await reader.addTag('003 1287');

      reader.toggleList();
      expect(reader.state.isListExpanded, isTrue);
      reader.remove(reader.state.items.first);
      expect(reader.state.items, hasLength(1));
      expect(reader.state.isListExpanded, isFalse);

      reader.discard();
      expect(reader.state.items, isEmpty);
      expect(reader.state.establishmentId, 'campo-1');
    });

    test('refresh relee la sesión', () async {
      final reader = cubit();
      await reader.start();
      await reader.addTag(_newRfid);
      repository.byTag[_newRfid] = quickReadAnimal('nuevo', rfid: _newRfid);

      await reader.refresh();

      expect((reader.state.items.single as RegisteredRead).animal.animal.id, 'nuevo');
    });
  });
}
