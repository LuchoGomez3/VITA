import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/current_location_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/get_current_location_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/steps/establishment_register_location_step.dart';

void main() {
  testWidgets('shows the real map centered on the GPS reading, and a hint before it', (tester) async {
    final bloc = RegisterEstablishmentBloc(
      registerEstablishmentUseCase: RegisterEstablishmentUseCase(_UnusedRegistrationRepository()),
      getCurrentLocationUseCase: GetCurrentLocationUseCase(_FakeCurrentLocationRepository()),
      initialStep: RegisterEstablishmentStep.location,
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: const EstablishmentRegisterLocationStep(showSatelliteImagery: false),
          ),
        ),
      ),
    );

    expect(find.text(EstablishmentRegisterStrings.stepThreePreviewPlaceholder), findsOneWidget);
    expect(find.byType(FlutterMap), findsNothing);

    await tester.ensureVisible(find.text(EstablishmentRegisterStrings.stepThreeUseCurrentLocationButton));
    await tester.tap(find.text(EstablishmentRegisterStrings.stepThreeUseCurrentLocationButton));
    await tester.pump();
    await tester.pump();

    expect(find.text(EstablishmentRegisterStrings.stepThreePreviewPlaceholder), findsNothing);
    final camera = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(camera.options.initialCenter.latitude, -33.7242);
    expect(camera.options.initialCenter.longitude, -64.5891);
  });
}

class _FakeCurrentLocationRepository implements CurrentLocationRepository {
  @override
  Future<Result<CurrentLocation>> getCurrentLocation() async =>
      const Result.success(CurrentLocation(latitud: -33.7242, longitud: -64.5891, precisionMetros: 5));
}

class _UnusedRegistrationRepository implements EstablishmentRegistrationRepository {
  @override
  Future<Result<RegisteredEstablishment>> register(EstablishmentRegistration registration) {
    throw UnimplementedError('El paso 3 no registra el establecimiento.');
  }
}
