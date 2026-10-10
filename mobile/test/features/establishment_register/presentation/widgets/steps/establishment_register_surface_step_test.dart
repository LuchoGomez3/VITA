import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/current_location_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/get_current_location_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_draft_validation.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/steps/establishment_register_surface_step.dart';

void main() {
  late _FakeCurrentLocationRepository locationRepository;
  late RegisterEstablishmentBloc bloc;

  setUp(() {
    locationRepository = _FakeCurrentLocationRepository();
  });

  /// Crea el BLoC dentro del test: así sus emisiones corren en el mismo reloj
  /// falso que `pump` y la UI se redibuja.
  Future<void> pumpStep(WidgetTester tester) async {
    bloc =
        RegisterEstablishmentBloc(
          registerEstablishmentUseCase: RegisterEstablishmentUseCase(_UnusedRegistrationRepository()),
          getCurrentLocationUseCase: GetCurrentLocationUseCase(locationRepository),
          initialStep: RegisterEstablishmentStep.surface,
        )..add(
          RegisterEstablishmentEvent.draftChanged(
            RegisterEstablishmentDraft.initial().copyWith(
              latitud: -33.61,
              longitud: -64.59,
              ubicacionConfirmadaPorGps: true,
            ),
          ),
        );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: const EstablishmentRegisterSurfaceStep(showSatelliteImagery: false),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> addPoints(WidgetTester tester, List<BoundaryPoint> points) async {
    for (final point in points) {
      bloc.add(RegisterEstablishmentEvent.boundaryPointAdded(point));
    }
    // Dentro de testWidgets el reloj es falso: pump procesa los eventos del
    // BLoC y redibuja (un Future.delayed no avanzaría nunca).
    await tester.pump();
    await tester.pump();
  }

  testWidgets('without a polygon, offers to enter the surface by hand', (tester) async {
    await pumpStep(tester);

    expect(find.text(EstablishmentRegisterStrings.stepFourHintEmpty), findsOneWidget);
    expect(find.text(EstablishmentRegisterStrings.stepFourManualSurfaceTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), '320,5');
    await tester.pump();

    expect(bloc.state.draft.superficieManualHectareas, 320.5);
    expect(bloc.state.draft.isSurfaceStepValid, isTrue);
  });

  testWidgets('tapping the map adds a vertex', (tester) async {
    await pumpStep(tester);

    await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
    // flutter_map espera a descartar un doble toque antes de confirmar el toque.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(bloc.state.draft.poligono, hasLength(1));
    expect(_vertexLabel('1'), findsOneWidget);
    expect(find.text(EstablishmentRegisterStrings.stepFourHintTooFewVertices), findsOneWidget);
  });

  testWidgets('a complete polygon shows its area and hides the manual surface field', (tester) async {
    await pumpStep(tester);
    await addPoints(tester, _square);

    expect(find.text(EstablishmentRegisterStrings.stepFourManualSurfaceTitle), findsNothing);
    expect(
      find.text(EstablishmentRegisterStrings.hectares(bloc.state.draft.superficieHectareas)),
      findsOneWidget,
    );
    expect(find.text(EstablishmentRegisterStrings.stepFourHintText), findsOneWidget);
    for (final label in ['1', '2', '3', '4']) {
      expect(_vertexLabel(label), findsOneWidget);
    }
  });

  testWidgets('warns when the sides of the polygon cross', (tester) async {
    await pumpStep(tester);
    await addPoints(tester, [_square[0], _square[2], _square[1], _square[3]]);

    expect(find.text(EstablishmentRegisterStrings.stepFourHintSelfIntersecting), findsOneWidget);
  });

  testWidgets('undo and clear buttons edit the polygon', (tester) async {
    await pumpStep(tester);
    await addPoints(tester, _square);

    await tester.tap(find.byTooltip(EstablishmentRegisterStrings.stepFourUndoTooltip));
    await tester.pump();
    expect(bloc.state.draft.poligono, hasLength(3));

    await tester.tap(find.byTooltip(EstablishmentRegisterStrings.stepFourClearTooltip));
    await tester.pump();
    expect(bloc.state.draft.poligono, isEmpty);
    expect(find.text(EstablishmentRegisterStrings.stepFourManualSurfaceTitle), findsOneWidget);
  });

  testWidgets('marks a vertex with the GPS and confirms it with its precision', (tester) async {
    await pumpStep(tester);

    await tester.tap(find.byTooltip(EstablishmentRegisterStrings.stepFourGpsVertexTooltip));
    await tester.pump();
    await tester.pump();

    expect(bloc.state.draft.poligono, hasLength(1));
    expect(find.text(EstablishmentRegisterStrings.stepFourGpsVertexAdded(6)), findsOneWidget);
  });

  testWidgets('explains why the GPS vertex could not be read', (tester) async {
    locationRepository.result = const Result.failure(
      DomainException(message: 'gps apagado', reason: CurrentLocationFailure.serviceDisabled),
    );
    await pumpStep(tester);

    await tester.tap(find.byTooltip(EstablishmentRegisterStrings.stepFourGpsVertexTooltip));
    await tester.pump();
    await tester.pump();

    expect(bloc.state.draft.poligono, isEmpty);
    expect(find.text(EstablishmentRegisterStrings.stepThreeLocationServiceDisabledError), findsOneWidget);
  });
}

/// Número de vértice dibujado sobre el mapa (no el contador del chip).
Finder _vertexLabel(String label) => find.descendant(of: find.byType(MarkerLayer), matching: find.text(label));

const _square = [
  BoundaryPoint(latitud: -33.600, longitud: -64.600),
  BoundaryPoint(latitud: -33.600, longitud: -64.580),
  BoundaryPoint(latitud: -33.620, longitud: -64.580),
  BoundaryPoint(latitud: -33.620, longitud: -64.600),
];

class _FakeCurrentLocationRepository implements CurrentLocationRepository {
  Result<CurrentLocation> result = const Result.success(
    CurrentLocation(latitud: -33.605, longitud: -64.595, precisionMetros: 6),
  );

  @override
  Future<Result<CurrentLocation>> getCurrentLocation() async => result;
}

class _UnusedRegistrationRepository implements EstablishmentRegistrationRepository {
  @override
  Future<Result<RegisteredEstablishment>> register(EstablishmentRegistration registration) {
    throw UnimplementedError('El paso 4 no registra el establecimiento.');
  }
}
