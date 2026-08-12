import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_draft_validation.dart';

void main() {
  group('RegisterEstablishmentDraftValidation', () {
    final validDraft = RegisterEstablishmentDraft.initial().copyWith(
      nombre: 'Estancia La Sirena',
      tiposProduccion: {'Cría'},
      cuitTitular: '20-12345678-6',
      nroRenspa: '07.123.0.00456/01',
      provincia: 'Córdoba',
      departamento: 'Río Cuarto',
      localidad: 'Coronel Moldes',
      ubicacionConfirmadaPorGps: true,
    );

    test('a freshly initialized draft has every step incomplete', () {
      final draft = RegisterEstablishmentDraft.initial();

      expect(draft.isIdentificationStepValid, isFalse);
      expect(draft.isRenspaStepValid, isFalse);
      expect(draft.isLocationStepValid, isFalse);
      expect(draft.isSurfaceStepValid, isTrue);
    });

    test('a fully completed draft is valid for every step', () {
      expect(validDraft.isValidForStep(RegisterEstablishmentStep.identification), isTrue);
      expect(validDraft.isValidForStep(RegisterEstablishmentStep.renspa), isTrue);
      expect(validDraft.isValidForStep(RegisterEstablishmentStep.location), isTrue);
      expect(validDraft.isValidForStep(RegisterEstablishmentStep.surface), isTrue);
      expect(validDraft.isValidForStep(RegisterEstablishmentStep.review), isTrue);
    });

    test('identification requires a name and at least one production type', () {
      expect(validDraft.copyWith(nombre: '').isIdentificationStepValid, isFalse);
      expect(validDraft.copyWith(nombre: ' ').isIdentificationStepValid, isFalse);
      expect(validDraft.copyWith(tiposProduccion: {}).isIdentificationStepValid, isFalse);
      expect(validDraft.copyWith(nombre: 'a' * 61).isIdentificationStepValid, isFalse);
    });

    test('renspa step rejects an invalid CUIT check digit', () {
      expect(validDraft.copyWith(cuitTitular: '20-12345678-0').isRenspaStepValid, isFalse);
    });

    test('renspa step rejects an incomplete RENSPA', () {
      expect(validDraft.copyWith(nroRenspa: '07.123.0.00456').isRenspaStepValid, isFalse);
    });

    test('location step requires the GPS confirmation flag', () {
      expect(validDraft.copyWith(ubicacionConfirmadaPorGps: false).isLocationStepValid, isFalse);
    });

    test('location step requires every dropdown to be selected', () {
      expect(validDraft.copyWith(provincia: '').isLocationStepValid, isFalse);
      expect(validDraft.copyWith(departamento: '').isLocationStepValid, isFalse);
      expect(validDraft.copyWith(localidad: '').isLocationStepValid, isFalse);
    });

    test('review requires every previous step to be valid', () {
      final invalidDraft = validDraft.copyWith(nombre: '');

      expect(invalidDraft.isValidForStep(RegisterEstablishmentStep.review), isFalse);
    });
  });
}
