import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';

void main() {
  const vaccine = HealthPractice(
    id: 'vaccine',
    name: 'Vacunación',
    kind: HealthPracticeKind.application,
    productIds: ['product'],
  );
  const sampling = HealthPractice(id: 'sampling', name: 'Sangrado', kind: HealthPracticeKind.sampling);
  const lesion = HealthPractice(id: 'lesion', name: 'Lesión', kind: HealthPracticeKind.lesion);
  const catalog = HealthCatalog(
    establishmentId: 'farm',
    practices: [vaccine, sampling, lesion],
    products: [HealthProduct(id: 'product', name: 'Producto de prueba')],
  );
  final registration = HealthRegistration(
    establishmentId: 'farm',
    occurredAt: DateTime.utc(2026),
    practice: vaccine,
    details: const HealthEventDetails.application(
      productId: 'product',
      productName: 'Producto de prueba',
      dose: '2,5',
      unit: 'ml',
      route: 'Inyectable',
    ),
    responsible: 'Operario',
    recipients: const [HealthRecipient(animalId: 'animal', label: '001')],
  );

  Matcher failsWith(HealthProblem problem) =>
      throwsA(isA<HealthFailure>().having((e) => e.problem, 'problem', problem));

  test('accepts decimal application and rejects unavailable products and other farms', () {
    RegisterHealthEventsUseCase.validate(registration, catalog);
    expect(
      () => RegisterHealthEventsUseCase.validate(registration, catalog.copyWith(products: [])),
      failsWith(HealthProblem.unavailablePractice),
    );
    expect(
      () => RegisterHealthEventsUseCase.validate(registration, catalog.copyWith(establishmentId: 'other')),
      failsWith(HealthProblem.unavailablePractice),
    );
  });

  test('sampling requires a sample type and permits an optional reference per animal', () {
    final study = registration.copyWith(
      practice: sampling,
      details: const HealthEventDetails.observation(description: 'Control', sampleType: 'Sangre'),
      recipients: [
        ...registration.recipients,
        const HealthRecipient(animalId: 'second', label: '002', sampleReference: 'M-2'),
      ],
    );
    RegisterHealthEventsUseCase.validate(study, catalog);
    expect(
      () => RegisterHealthEventsUseCase.validate(
        study.copyWith(details: const HealthEventDetails.observation(description: 'Control')),
        catalog,
      ),
      failsWith(HealthProblem.invalidDetails),
    );
  });

  test('rejects duplicate animals and empty observations', () {
    expect(
      () => RegisterHealthEventsUseCase.validate(
        registration.copyWith(recipients: [...registration.recipients, ...registration.recipients]),
        catalog,
      ),
      failsWith(HealthProblem.invalidSelection),
    );
    expect(
      () => RegisterHealthEventsUseCase.validate(
        registration.copyWith(
          practice: lesion,
          details: const HealthEventDetails.observation(description: ' '),
        ),
        catalog,
      ),
      failsWith(HealthProblem.invalidDetails),
    );
  });
}
