import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_establishment_select.dart';

void main() {
  const establishments = {
    'establishment-1': EstablishmentMembership(id: 'establishment-1', name: 'La Sirena', role: UserRole.owner),
    'establishment-2': EstablishmentMembership(id: 'establishment-2', name: 'El Ombú', role: UserRole.owner),
  };

  Future<void> pumpSelect(
    WidgetTester tester, {
    String? selectedEstablishmentId,
    ValueChanged<String?>? onSelected,
    VoidCallback? onCreateEstablishment,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeEstablishmentSelect(
            establishments: establishments,
            selectedEstablishmentId: selectedEstablishmentId,
            onSelected: onSelected ?? (_) {},
            onCreateEstablishment: onCreateEstablishment ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('muestra el establecimiento activo en la línea del resumen', (tester) async {
    await pumpSelect(tester, selectedEstablishmentId: 'establishment-2');

    expect(find.text(_summaryOf('El Ombú')), findsOneWidget);
    expect(find.text('La Sirena'), findsNothing);
  });

  testWidgets('muestra "Todos los establecimientos" cuando no hay uno activo', (tester) async {
    await pumpSelect(tester);

    expect(find.text(_summaryOf(HomeStrings.allEstablishments)), findsOneWidget);
  });

  testWidgets('al tocar la línea lista los establecimientos y la opción de crear', (tester) async {
    await pumpSelect(tester);

    await tester.tap(find.text(_summaryOf(HomeStrings.allEstablishments)));
    await tester.pumpAndSettle();

    expect(find.text('La Sirena'), findsOneWidget);
    expect(find.text('El Ombú'), findsOneWidget);
    expect(find.text(HomeStrings.createEstablishmentOption), findsOneWidget);
  });

  testWidgets('informa el establecimiento elegido y cierra el menú', (tester) async {
    String? selected;
    await pumpSelect(tester, onSelected: (id) => selected = id);

    await tester.tap(find.text(_summaryOf(HomeStrings.allEstablishments)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('La Sirena'));
    await tester.pumpAndSettle();

    expect(selected, 'establishment-1');
    expect(find.text(HomeStrings.createEstablishmentOption), findsNothing);
  });

  testWidgets('abre el alta desde "Nuevo establecimiento" aun sin establecimientos', (tester) async {
    var createRequests = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeEstablishmentSelect(
            establishments: const {},
            selectedEstablishmentId: null,
            onSelected: (_) {},
            onCreateEstablishment: () => createRequests++,
          ),
        ),
      ),
    );

    await tester.tap(find.text(_summaryOf(HomeStrings.allEstablishments)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(HomeStrings.createEstablishmentOption));
    await tester.pumpAndSettle();

    expect(createRequests, 1);
  });
}

String _summaryOf(String establishmentName) => '${HomeStrings.establishmentPrefix} $establishmentName';
