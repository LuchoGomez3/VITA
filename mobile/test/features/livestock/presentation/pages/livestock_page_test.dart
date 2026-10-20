import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_establishments_use_case.dart';
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

    final readButton = find.widgetWithText(
      AppFilledButton,
      LivestockStrings.readTagTitle,
    );
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

    expect(find.text(LivestockStrings.readTagDescription), findsOneWidget);
    expect(find.widgetWithText(AppFilledButton, LivestockStrings.readTagTitle), findsOneWidget);
    expect(find.text('Ver animal 012'), findsNothing);
  });
}

Widget _testApp({
  required Result<List<LivestockEstablishment>> result,
  required void Function(String establishmentId) onIdentifyAnimal,
}) {
  final repository = _FakeLivestockEstablishmentRepository(result);
  return _testAppWithRepository(
    repository: repository,
    onIdentifyAnimal: onIdentifyAnimal,
  );
}

Widget _testAppWithRepository({
  required LivestockEstablishmentRepository repository,
  required void Function(String establishmentId) onIdentifyAnimal,
}) {
  return MaterialApp(
    home: LivestockPage(
      createCubit: () => LivestockReaderCubit(
        GetLivestockEstablishmentsUseCase(repository),
      ),
      onIdentifyAnimal: (establishmentId) async {
        onIdentifyAnimal(establishmentId);
      },
    ),
  );
}

Future<void> _tapReadTag(WidgetTester tester) async {
  await tester.tap(
    find.widgetWithText(AppFilledButton, LivestockStrings.readTagTitle),
  );
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
