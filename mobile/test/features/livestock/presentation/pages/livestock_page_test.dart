import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/animal_list_repository.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_animal_list_use_case.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_establishments_use_case.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_sale_establishments_use_case.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/animal_list_cubit.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_access_cubit.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_reader_cubit.dart';
import 'package:frontend_mayoral/features/livestock/presentation/pages/livestock_page.dart';
import 'package:frontend_mayoral/features/livestock/presentation/strings/livestock_strings.dart';

void main() {
  testWidgets('ignora aperturas concurrentes del lector', (tester) async {
    final resultCompleter = Completer<Result<List<LivestockEstablishment>>>();
    final repository = _PendingLivestockEstablishmentRepository(resultCompleter);
    final selectedIds = <String>[];
    await tester.pumpWidget(
      _testAppWithRepository(
        repository: repository,
        onIdentifyAnimal: selectedIds.add,
      ),
    );

    final readButton = find.byTooltip(LivestockStrings.readTagTitle);
    await tester.tap(readButton);
    await tester.tap(readButton);

    expect(repository.callCount, 1);

    resultCompleter.complete(
      Result.success([
        _establishment(id: 'establishment-1', name: 'El Ombú'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(repository.callCount, 1);
    expect(selectedIds, ['establishment-1']);
  });

  testWidgets('informa cuando no hay establecimientos disponibles', (tester) async {
    final selectedIds = <String>[];
    await tester.pumpWidget(
      _testApp(
        result: const Result.success([]),
        onIdentifyAnimal: selectedIds.add,
      ),
    );

    await _tapReadTag(tester);

    expect(find.text(LivestockStrings.noEstablishments), findsOneWidget);
    expect(selectedIds, isEmpty);
  });

  testWidgets('abre directamente el único establecimiento habilitado', (tester) async {
    final selectedIds = <String>[];
    await tester.pumpWidget(
      _testApp(
        result: Result.success([_establishment(id: 'establishment-1', name: 'El Ombú')]),
        onIdentifyAnimal: selectedIds.add,
      ),
    );

    await _tapReadTag(tester);

    expect(selectedIds, ['establishment-1']);
  });

  testWidgets('permite elegir entre varios establecimientos', (tester) async {
    final selectedIds = <String>[];
    await tester.pumpWidget(
      _testApp(
        result: Result.success([
          _establishment(id: 'establishment-1', name: 'El Ombú'),
          _establishment(id: 'establishment-2', name: 'La Esperanza'),
        ]),
        onIdentifyAnimal: selectedIds.add,
      ),
    );

    await _tapReadTag(tester);
    expect(find.text(LivestockStrings.selectEstablishment), findsOneWidget);

    await tester.tap(find.text('La Esperanza'));
    await tester.pumpAndSettle();

    expect(selectedIds, ['establishment-2']);
  });

  testWidgets('no navega cuando se cancela el selector', (tester) async {
    final selectedIds = <String>[];
    await tester.pumpWidget(
      _testApp(
        result: Result.success([
          _establishment(id: 'establishment-1', name: 'El Ombú'),
          _establishment(id: 'establishment-2', name: 'La Esperanza'),
        ]),
        onIdentifyAnimal: selectedIds.add,
      ),
    );

    await _tapReadTag(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(selectedIds, isEmpty);
  });

  testWidgets('muestra un error recuperable cuando falla el catálogo local', (tester) async {
    final selectedIds = <String>[];
    await tester.pumpWidget(
      _testApp(
        result: const Result.failure(
          DomainException(message: 'catalog unavailable'),
        ),
        onIdentifyAnimal: selectedIds.add,
      ),
    );

    await _tapReadTag(tester);

    expect(find.text(LivestockStrings.establishmentsError), findsOneWidget);
    expect(selectedIds, isEmpty);
  });

  testWidgets('falla cerrado cuando el catálogo solo contiene un rol desconocido', (tester) async {
    final selectedIds = <String>[];
    await tester.pumpWidget(
      _testApp(
        result: Result.success([
          _establishment(
            id: 'establishment-unknown',
            name: 'Sin rol',
            role: UserRole.unknown,
          ),
        ]),
        onIdentifyAnimal: selectedIds.add,
      ),
    );

    await _tapReadTag(tester);

    expect(find.text(LivestockStrings.noEstablishments), findsOneWidget);
    expect(selectedIds, isEmpty);
  });

  testWidgets('conserva los accesos visuales de Hacienda', (tester) async {
    await tester.pumpWidget(
      _testApp(
        result: const Result.success([]),
        onIdentifyAnimal: (_) {},
      ),
    );

    // Las tarjetas del #74 pasaron a ser accesos de la cabecera de la lista.
    expect(find.byTooltip(LivestockStrings.readTagTitle), findsOneWidget);
    expect(find.byTooltip(LivestockStrings.fieldTitle), findsOneWidget);
    expect(find.text('Ver animal 012'), findsNothing);
  });

  testWidgets('con un campo elegido en el selector lee ahí sin preguntar', (tester) async {
    final repository = _FakeLivestockEstablishmentRepository(const Result.success([]));
    final selectedIds = <String>[];
    await tester.pumpWidget(
      _testAppWithRepository(
        repository: repository,
        onIdentifyAnimal: selectedIds.add,
        listEstablishments: const [
          EstablishmentMembership(id: 'establishment-1', name: 'El Ombú', role: UserRole.owner),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await _tapReadTag(tester);

    expect(selectedIds, ['establishment-1']);
  });

  testWidgets('abre la venta para el unico establecimiento financiero', (
    tester,
  ) async {
    final selectedIds = <String>[];
    await tester.pumpWidget(
      _testApp(
        result: const Result.success([]),
        saleAccessResult: Result.success([
          _establishment(id: 'establishment-1', name: 'El Ombú'),
        ]),
        onIdentifyAnimal: (_) {},
        onRegisterSale: (establishmentId) async {
          selectedIds.add(establishmentId);
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(LivestockStrings.saleRegisterTitle));
    await tester.pumpAndSettle();

    expect(selectedIds, ['establishment-1']);
  });

  testWidgets('no bloquea el acceso mientras la ruta de venta sigue abierta', (
    tester,
  ) async {
    final navigationCompleter = Completer<void>();
    addTearDown(() {
      if (!navigationCompleter.isCompleted) navigationCompleter.complete();
    });
    await tester.pumpWidget(
      _testApp(
        result: const Result.success([]),
        saleAccessResult: Result.success([
          _establishment(id: 'establishment-1', name: 'El Ombú'),
        ]),
        onIdentifyAnimal: (_) {},
        onRegisterSale: (_) => navigationCompleter.future,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(LivestockStrings.saleRegisterTitle));
    await tester.pump();

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.attach_money),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('oculta la venta cuando el rol no tiene acceso financiero', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        result: const Result.success([]),
        saleAccessResult: Result.success([
          _establishment(
            id: 'employee-establishment',
            name: 'Campo Empleado',
            role: UserRole.employee,
          ),
        ]),
        onIdentifyAnimal: (_) {},
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byTooltip(LivestockStrings.saleRegisterTitle),
      findsNothing,
    );
  });
}

Widget _testApp({
  required Result<List<LivestockEstablishment>> result,
  required void Function(String establishmentId) onIdentifyAnimal,
  Result<List<LivestockEstablishment>> saleAccessResult = const Result.success(
    [],
  ),
  Future<void> Function(String establishmentId)? onRegisterSale,
}) {
  final repository = _FakeLivestockEstablishmentRepository(result);
  return _testAppWithRepository(
    repository: repository,
    saleAccessResult: saleAccessResult,
    onIdentifyAnimal: onIdentifyAnimal,
    onRegisterSale: onRegisterSale,
  );
}

/// [listEstablishments] son los campos del selector de la lista: con uno solo
/// queda elegido y el lector no pregunta; vacío equivale a "Todos".
Widget _testAppWithRepository({
  required LivestockEstablishmentRepository repository,
  required void Function(String establishmentId) onIdentifyAnimal,
  Result<List<LivestockEstablishment>> saleAccessResult = const Result.success(
    [],
  ),
  Future<void> Function(String establishmentId)? onRegisterSale,
  List<EstablishmentMembership> listEstablishments = const [],
}) {
  final listRepository = _FakeAnimalListRepository(listEstablishments);
  final saleAccessRepository = _FakeLivestockEstablishmentRepository(
    saleAccessResult,
  );
  return MaterialApp(
    home: LivestockPage(
      createCubit: () => AnimalListCubit(
        getAnimalListUseCase: GetAnimalListUseCase(listRepository),
        getEstablishmentsUseCase: GetAnimalListEstablishmentsUseCase(listRepository),
      ),
      createReaderCubit: () => LivestockReaderCubit(
        GetLivestockEstablishmentsUseCase(repository),
      ),
      createAccessCubit: () => LivestockAccessCubit(
        getSaleEstablishments: GetLivestockSaleEstablishmentsUseCase(
          saleAccessRepository,
        ),
      ),
      onIdentifyAnimal: (establishmentId) async {
        onIdentifyAnimal(establishmentId);
      },
      onRegisterSale: (establishmentId) async {
        await onRegisterSale?.call(establishmentId);
      },
    ),
  );
}

Future<void> _tapReadTag(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip(LivestockStrings.readTagTitle));
  await tester.pumpAndSettle();
}

LivestockEstablishment _establishment({
  required String id,
  required String name,
  UserRole role = UserRole.owner,
}) => LivestockEstablishment(id: id, name: name, role: role);

class _FakeLivestockEstablishmentRepository implements LivestockEstablishmentRepository {
  _FakeLivestockEstablishmentRepository(this.result);

  final Result<List<LivestockEstablishment>> result;

  @override
  Future<Result<List<LivestockEstablishment>>> getEstablishments() async => result;
}

class _PendingLivestockEstablishmentRepository implements LivestockEstablishmentRepository {
  _PendingLivestockEstablishmentRepository(this.resultCompleter);

  final Completer<Result<List<LivestockEstablishment>>> resultCompleter;
  int callCount = 0;

  @override
  Future<Result<List<LivestockEstablishment>>> getEstablishments() {
    callCount++;
    return resultCompleter.future;
  }
}

class _FakeAnimalListRepository implements AnimalListRepository {
  _FakeAnimalListRepository(this.establishments);

  final List<EstablishmentMembership> establishments;

  @override
  Future<Result<List<AnimalListEntry>>> getAnimals() async => const Result.success([]);

  @override
  Future<Result<List<EstablishmentMembership>>> getEstablishments() async => Result.success(establishments);
}
