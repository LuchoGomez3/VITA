import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/current_location_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/get_current_location_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/location_map_preview.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/steps/establishment_register_review_step.dart';

void main() {
  Future<void> pumpReview(WidgetTester tester, RegisterEstablishmentDraft draft) async {
    final bloc = RegisterEstablishmentBloc(
      registerEstablishmentUseCase: RegisterEstablishmentUseCase(_UnusedRegistrationRepository()),
      getCurrentLocationUseCase: GetCurrentLocationUseCase(_UnusedLocationRepository()),
      initialStep: RegisterEstablishmentStep.review,
    )..add(RegisterEstablishmentEvent.draftChanged(draft));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: const EstablishmentRegisterReviewStep(showSatelliteImagery: false),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the drawn field on the map, framed around the polygon', (tester) async {
    await pumpReview(tester, _draft.copyWith(poligono: _square));

    final preview = tester.widget<LocationMapPreview>(find.byType(LocationMapPreview));
    expect(preview.boundary, _square);
    expect(find.byType(PolygonLayer), findsOneWidget);
    expect(find.text('4 vértices'), findsOneWidget);
    expect(find.text(EstablishmentRegisterStrings.reviewManualSurfaceChipLabel), findsNothing);
  });

  testWidgets('shows the map with the reference pin when the surface was entered by hand', (tester) async {
    await pumpReview(tester, _draft.copyWith(superficieManualHectareas: 320));

    expect(find.byType(LocationMapPreview), findsOneWidget);
    expect(find.byType(PolygonLayer), findsNothing);
    expect(find.text('320 ha'), findsOneWidget);
    expect(find.text(EstablishmentRegisterStrings.reviewManualSurfaceChipLabel), findsOneWidget);
  });
}

final RegisterEstablishmentDraft _draft = RegisterEstablishmentDraft.initial().copyWith(
  latitud: -33.61,
  longitud: -64.59,
  ubicacionConfirmadaPorGps: true,
);

const _square = [
  BoundaryPoint(latitud: -33.608, longitud: -64.592),
  BoundaryPoint(latitud: -33.608, longitud: -64.588),
  BoundaryPoint(latitud: -33.612, longitud: -64.588),
  BoundaryPoint(latitud: -33.612, longitud: -64.592),
];

class _UnusedLocationRepository implements CurrentLocationRepository {
  @override
  Future<Result<CurrentLocation>> getCurrentLocation() => throw UnimplementedError();
}

class _UnusedRegistrationRepository implements EstablishmentRegistrationRepository {
  @override
  Future<Result<RegisteredEstablishment>> register(EstablishmentRegistration registration) =>
      throw UnimplementedError();
}
