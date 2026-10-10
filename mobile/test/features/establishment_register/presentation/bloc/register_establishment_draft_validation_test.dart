import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/services/field_boundary_geometry.dart';
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
      superficieManualHectareas: 320,
    );

    const square = [
      BoundaryPoint(latitud: -33.60, longitud: -64.60),
      BoundaryPoint(latitud: -33.60, longitud: -64.58),
      BoundaryPoint(latitud: -33.62, longitud: -64.58),
      BoundaryPoint(latitud: -33.62, longitud: -64.60),
    ];

    test('a freshly initialized draft has every step incomplete', () {
      final draft = RegisterEstablishmentDraft.initial();

      expect(draft.isIdentificationStepValid, isFalse);
      expect(draft.isRenspaStepValid, isFalse);
      expect(draft.isLocationStepValid, isFalse);
      expect(draft.isSurfaceStepValid, isFalse);
      expect(draft.surfaceStepIssue, SurfaceStepIssue.missingSurface);
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

    test('surface step accepts a hand-entered surface without a polygon', () {
      expect(validDraft.isSurfaceStepValid, isTrue);
      expect(validDraft.superficieHectareas, 320);
    });

    test('surface step rejects a missing or non-positive hand-entered surface', () {
      expect(
        validDraft.copyWith(superficieManualHectareas: null).surfaceStepIssue,
        SurfaceStepIssue.missingSurface,
      );
      expect(
        validDraft.copyWith(superficieManualHectareas: 0).surfaceStepIssue,
        SurfaceStepIssue.missingSurface,
      );
    });

    test('surface step rejects a polygon with fewer than 3 vertices, even with a hand-entered surface', () {
      final draft = validDraft.copyWith(poligono: square.sublist(0, 2));

      expect(draft.surfaceStepIssue, SurfaceStepIssue.tooFewVertices);
      expect(draft.superficieHectareas, 0);
    });

    test('surface step rejects a polygon whose sides cross', () {
      final bowTie = [square[0], square[2], square[1], square[3]];

      expect(validDraft.copyWith(poligono: bowTie).surfaceStepIssue, SurfaceStepIssue.selfIntersecting);
    });

    test('a valid polygon sets the surface from its area, ignoring the hand-entered one', () {
      final draft = validDraft.copyWith(poligono: square);

      expect(draft.isSurfaceStepValid, isTrue);
      expect(draft.superficieHectareas, FieldBoundaryGeometry.areaHectares(square));
      expect(draft.superficieHectareas, isNot(320));
    });

    test('review requires every previous step to be valid', () {
      final invalidDraft = validDraft.copyWith(nombre: '');

      expect(invalidDraft.isValidForStep(RegisterEstablishmentStep.review), isFalse);
    });
  });
}
