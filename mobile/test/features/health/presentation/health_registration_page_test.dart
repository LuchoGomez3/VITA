import 'package:flutter/material.dart';
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

  testWidgets('saves a result for the same study UUID', (tester) async {
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
  Future<HealthRecipient?> findRecipient(String establishmentId, String tag, {required bool electronic}) async => null;

  @override
  Future<({String id, HealthRegistration registration})?> getRejectedRegistration(HealthEvent event) async => null;

  @override
  Stream<List<HealthEvent>> watchHistory(String establishmentId, String animalId) => Stream.value([]);
}
