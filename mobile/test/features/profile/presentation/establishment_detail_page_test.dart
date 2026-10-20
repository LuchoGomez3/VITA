import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/location_map_preview.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/presentation/pages/establishment_detail_page.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_establishments_section.dart';

void main() {
  group('EstablishmentDetailPage', () {
    testWidgets('sin ubicación muestra el aviso en lugar del mapa', (tester) async {
      await tester.pumpWidget(MaterialApp(home: EstablishmentDetailPage(establishment: _withoutLocation)));

      expect(find.byType(LocationMapPreview), findsNothing);
      expect(find.text(ProfileStrings.noLocation), findsOneWidget);
      expect(find.text('847 ha'), findsOneWidget);
      expect(find.text(ProfileStrings.boundaryMissing), findsOneWidget);
      expect(find.text('07.123.0.00456/01'), findsOneWidget);
    });

    testWidgets('con contorno dibuja el mapa y calcula la superficie delimitada', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EstablishmentDetailPage(establishment: _withBoundary, showSatelliteImagery: false),
        ),
      );

      expect(find.byType(LocationMapPreview), findsOneWidget);
      expect(find.text(ProfileStrings.boundaryDrawn), findsOneWidget);
      expect(find.text(ProfileStrings.boundaryMissing), findsNothing);
      // Cuadrado de ~1 km de lado: unas 100 ha.
      final mappedArea = tester.widget<Text>(
        find.descendant(
          of: find.ancestor(of: find.text(ProfileStrings.mappedAreaLabel), matching: find.byType(Column)).first,
          matching: find.textContaining(' ha'),
        ),
      );
      final hectares = double.parse(mappedArea.data!.replaceAll(' ha', '').replaceAll('.', '').replaceAll(',', '.'));
      expect(hectares, closeTo(100, 3));
      expect(find.text(ProfileStrings.coordinates(-33.1, -64.3)), findsOneWidget);
    });
  });

  testWidgets('la ficha lleva al equipo del establecimiento', (tester) async {
    var teamTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: EstablishmentDetailPage(establishment: _withoutLocation, onOpenTeam: () => teamTaps++),
      ),
    );

    await tester.scrollUntilVisible(
      find.text(ProfileStrings.teamRowLabel),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(ProfileStrings.teamRowManageSubtitle), findsOneWidget);
    await tester.tap(find.text(ProfileStrings.teamRowLabel));

    expect(teamTaps, 1);
  });

  testWidgets('la lista abre la ficha tocada y ofrece sumarse a otro campo', (tester) async {
    EstablishmentDetails? opened;
    var joinTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileEstablishmentsSection(
            establishments: [_withoutLocation],
            onOpen: (establishment) => opened = establishment,
            onJoin: () => joinTaps++,
          ),
        ),
      ),
    );

    expect(find.text('Dueño · 847 ha'), findsOneWidget);
    await tester.tap(find.text('Prueba 1'));
    await tester.tap(find.text(ProfileStrings.joinEstablishmentLabel));

    expect(opened?.id, 'establishment-id');
    expect(joinTaps, 1);
  });

  test('formatea las hectáreas con separadores de Argentina', () {
    expect(ProfileStrings.hectares(847), '847 ha');
    expect(ProfileStrings.hectares(1250.46), '1.250,5 ha');
    expect(ProfileStrings.hectares(1234567), '1.234.567 ha');
  });
}

final _createdAt = DateTime.utc(2026, 8, 27);

final EstablishmentDetails _withoutLocation = (
  id: 'establishment-id',
  ownerId: 'owner-id',
  name: 'Prueba 1',
  role: UserRole.owner,
  renspaNumber: '07.123.0.00456/01',
  cuit: '20434499810',
  areaHectares: 847.0,
  province: 'Córdoba',
  department: 'Río Cuarto',
  locality: 'Río Cuarto',
  latitude: null,
  longitude: null,
  boundary: const [],
  createdAt: _createdAt,
  updatedAt: _createdAt,
);

/// Cuadrado de 0,009° de lado (~1 km) alrededor del punto de referencia.
final EstablishmentDetails _withBoundary = (
  id: 'establishment-id',
  ownerId: 'owner-id',
  name: 'Prueba 1',
  role: UserRole.owner,
  renspaNumber: '07.123.0.00456/01',
  cuit: '20434499810',
  areaHectares: 847.0,
  province: 'Córdoba',
  department: 'Río Cuarto',
  locality: 'Río Cuarto',
  latitude: -33.1,
  longitude: -64.3,
  boundary: const [
    (latitude: -33.0955, longitude: -64.3054),
    (latitude: -33.0955, longitude: -64.2946),
    (latitude: -33.1045, longitude: -64.2946),
    (latitude: -33.1045, longitude: -64.3054),
  ],
  createdAt: _createdAt,
  updatedAt: _createdAt,
);
