import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/constants/health_registration_strings.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/repositories/health_repository.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_registration_cubit.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_result_cubit.dart';
import 'package:frontend_mayoral/features/health/presentation/pages/health_registration_page.dart';
import 'package:frontend_mayoral/features/health/presentation/pages/health_result_page.dart';
import 'package:go_router/go_router.dart';

const _study = HealthPractice(id: 'sampling', name: 'Sangrado', kind: HealthPracticeKind.sampling);
const _animal = HealthRecipient(animalId: 'animal', label: '001');

void main() {
  testWidgets('a catalog refresh respects a newer establishment selection in manga', (tester) async {
    final repository = _SwitchableCatalogRepository();
    final refresh = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: HealthRegistrationPage(
          capture: true,
          refreshCatalog: () => refresh.future,
          createCubit: () => HealthRegistrationCubit(
            reader: ReadHealthUseCase(repository),
            register: RegisterHealthEventsUseCase(repository),
            establishments: () async => const [
              EstablishmentMembership(id: 'farm-a', name: 'Campo A', role: UserRole.employee),
              EstablishmentMembership(id: 'farm-b', name: 'Campo B', role: UserRole.employee),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final dropdown = find.byType(DropdownButton<String>).first;

    Future<void> choose(String name) async {
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    await choose('Campo A');
    await tester.tap(find.text(HealthRegistrationStrings.refresh));
    await tester.pump();
    await choose('Campo B');
    expect(tester.widget<DropdownButton<String>>(dropdown).value, 'farm-b');

    repository.farmAAvailable = true;
    refresh.complete();
    await tester.pumpAndSettle();

    expect(tester.widget<DropdownButton<String>>(dropdown).value, 'farm-b');
    await choose('Campo A');
    expect(tester.widget<DropdownButton<String>>(dropdown).value, 'farm-a');
    expect(find.text(HealthRegistrationStrings.catalogUnavailable), findsNothing);
  });

  testWidgets('manga combines consecutive HID and manual readings without duplicate animals', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1300));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _Repository();
    await tester.pumpWidget(
      MaterialApp(
        home: HealthRegistrationPage(
          capture: true,
          establishmentId: 'farm',
          createCubit: () => HealthRegistrationCubit(
            reader: ReadHealthUseCase(repository),
            register: RegisterHealthEventsUseCase(repository),
            establishments: () async => const [
              EstablishmentMembership(id: 'farm', name: 'Campo', role: UserRole.employee),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sangrado').last);
    await tester.pumpAndSettle();

    for (final rfid in ['000000000000001', '000000000000002']) {
      for (final digit in rfid.split('')) {
        final key = LogicalKeyboardKey(LogicalKeyboardKey.digit0.keyId + int.parse(digit));
        await tester.sendKeyDownEvent(key, character: digit);
        await tester.sendKeyUpEvent(key);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    }
    await tester.pumpAndSettle();
    expect(find.text(HealthRegistrationStrings.selected(2)), findsOneWidget);

    await tester.tap(find.text(HealthRegistrationStrings.useManual));
    await tester.pumpAndSettle();
    await tester.tap(find.text(HealthRegistrationStrings.visual));
    await tester.pumpAndSettle();
    await tester.enterText(_entry(HealthRegistrationStrings.visual), '001');
    await tester.tap(find.text(HealthRegistrationStrings.addTag));
    await tester.pumpAndSettle();
    expect(find.text(HealthRegistrationStrings.duplicate), findsOneWidget);
    expect(find.text(HealthRegistrationStrings.selected(2)), findsOneWidget);
    expect(repository.registration, isNull);
  });

  testWidgets('registers a preselected animal with the sampling form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _Repository();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => TextButton(
            onPressed: () => context.push('/record'),
            child: const Text('Ficha'),
          ),
        ),
        GoRoute(
          path: '/record',
          builder: (_, _) => HealthRegistrationPage(
            createCubit: () => HealthRegistrationCubit(
              reader: ReadHealthUseCase(repository),
              register: RegisterHealthEventsUseCase(repository),
              establishments: () async => const [
                EstablishmentMembership(id: 'farm', name: 'Campo', role: UserRole.employee),
              ],
            ),
            establishmentId: 'farm',
            animalIds: const ['animal'],
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Ficha'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sangrado').last);
    await tester.pumpAndSettle();

    await tester.enterText(_entry(HealthRegistrationStrings.responsible), 'Operario');
    await tester.enterText(_entry(HealthRegistrationStrings.reason), 'Control');
    await tester.enterText(_entry(HealthRegistrationStrings.sampleType), 'Sangre');
    final confirm = find.text(HealthRegistrationStrings.confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(repository.registration?.recipients, [_animal]);
    expect(repository.registration?.details, const HealthObservation(description: 'Control', sampleType: 'Sangre'));
    expect(find.text('Ficha'), findsOneWidget);
  });

  testWidgets('a correction identifies the affected animal and field', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(
      MaterialApp(
        home: HealthRegistrationPage(
          rejected: (
            id: 'rejected-group',
            registration: HealthRegistration(
              establishmentId: 'farm',
              occurredAt: DateTime.utc(2026),
              practice: _study,
              details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
              responsible: 'Operario',
              recipients: const [
                _animal,
                HealthRecipient(animalId: 'second', label: '002'),
              ],
            ),
            rejection: (animalId: 'second', field: 'referencia_muestra'),
          ),
          createCubit: () => HealthRegistrationCubit(
            reader: ReadHealthUseCase(repository),
            register: RegisterHealthEventsUseCase(repository),
            establishments: () async => const [
              EstablishmentMembership(id: 'farm', name: 'Campo', role: UserRole.employee),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Revisá el campo «${HealthRegistrationStrings.sampleReference}» para la caravana 002.'),
      findsOneWidget,
    );
  });

  testWidgets('corrects a rejected result for the same study UUID', (tester) async {
    final repository = _Repository();
    final date = DateTime.utc(2026);
    final event = HealthEvent(
      id: 'study-existing',
      establishmentId: 'farm',
      occurredAt: date,
      createdAt: date,
      updatedAt: date,
      practice: _study,
      details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
      responsible: 'Operario',
      recordedById: 'user',
      recipient: _animal,
      resultRejection: (animalId: null, field: 'resultado'),
      resultSyncStatus: HealthSyncStatus.rejected,
      result: HealthStudyResult(value: 'Informe previo', reportedAt: date, reportedById: 'user'),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => TextButton(
            onPressed: () => context.push('/result'),
            child: const Text('Historial'),
          ),
        ),
        GoRoute(
          path: '/result',
          builder: (_, _) => HealthResultPage(
            event: event,
            createCubit: () => HealthResultCubit(RecordHealthResultUseCase(repository)),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();
    expect(find.text('Revisá el campo «${HealthRegistrationStrings.result}».'), findsOneWidget);
    await tester.enterText(_entry(HealthRegistrationStrings.result), 'Informe recibido');
    await tester.tap(find.text(HealthRegistrationStrings.saveResult));
    await tester.pumpAndSettle();

    expect(repository.result, ('study-existing', 'Informe recibido'));
    expect(find.text('Historial'), findsOneWidget);
  });
}

Finder _entry(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

class _SwitchableCatalogRepository extends _Repository {
  bool farmAAvailable = false;

  @override
  Future<HealthCatalog?> getCatalog(String establishmentId) async {
    if (establishmentId == 'farm-a' && !farmAAvailable) return null;
    return super.getCatalog(establishmentId);
  }
}

class _Repository implements HealthRepository {
  HealthRegistration? registration;
  (String, String)? result;

  @override
  Future<HealthCatalog?> getCatalog(String establishmentId) async =>
      HealthCatalog(establishmentId: establishmentId, practices: const [_study], products: const []);

  @override
  Future<List<HealthRecipient>> getRecipients(String establishmentId, List<String> animalIds) async => [
    if (animalIds.contains(_animal.animalId)) _animal,
  ];

  @override
  Future<void> register(HealthRegistration registration, {String? replacingOperationId}) async =>
      this.registration = registration;

  @override
  Future<void> recordResult(HealthEvent event, String result, DateTime reportedAt) async =>
      this.result = (event.id, result);

  @override
  Future<HealthRecipient?> findRecipient(String establishmentId, String tag, {required bool electronic}) async =>
      switch ((electronic, tag)) {
        (true, '000000000000001') || (false, '001') => _animal,
        (true, '000000000000002') => const HealthRecipient(animalId: 'second', label: '002'),
        _ => null,
      };

  @override
  Future<HealthCorrection?> getRejectedRegistration(HealthEvent event) async => null;

  @override
  Stream<List<HealthEvent>> watchHistory(String establishmentId, String animalId) => Stream.value([]);
}
