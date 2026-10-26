import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_appearance_sheet.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_sliver_header.dart';

void main() {
  testWidgets('"Quitar foto" solo aparece si hay foto', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showProfileAppearanceSheet(context, currentColor: null, hasPhoto: false),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text(ProfileStrings.removePhoto), findsNothing);
    expect(find.text(ProfileStrings.takePhoto), findsOneWidget);
    expect(find.text(ProfileStrings.pickFromGallery), findsOneWidget);
    expect(find.text(ProfileStrings.chooseAvatar), findsOneWidget);
  });

  testWidgets('la hoja es baja en "Foto" y crece en "Color de fondo"', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showProfileAppearanceSheet(context, currentColor: null, hasPhoto: true),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    final photoHeight = tester.getSize(find.byType(ProfileAppearanceSheet)).height;

    await tester.tap(find.text(ProfileStrings.colorTab));
    await tester.pumpAndSettle();
    final colorHeight = tester.getSize(find.byType(ProfileAppearanceSheet)).height;

    expect(photoHeight, lessThan(colorHeight * 0.7));

    await tester.tap(find.text(ProfileStrings.photoTab));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(ProfileAppearanceSheet)).height, photoHeight);
  });

  testWidgets('elegir un color guardado y aplicarlo devuelve ese color', (tester) async {
    ProfileAppearanceChoice? choice;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                choice = await showProfileAppearanceSheet(context, currentColor: null, hasPhoto: true),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ProfileStrings.colorTab));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('#1565C0'));
    await tester.pump();
    await tester.dragUntilVisible(
      find.widgetWithText(TextField, ProfileStrings.blueLabel),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    // Los campos RGB acompañan la selección.
    expect(find.widgetWithText(TextField, '21'), findsOneWidget);
    expect(find.widgetWithText(TextField, '101'), findsOneWidget);
    expect(find.widgetWithText(TextField, '192'), findsOneWidget);

    await tester.tap(find.text(ProfileStrings.applyColor));
    await tester.pumpAndSettle();

    expect(choice, isA<HeaderColorChoice>().having((c) => c.color, 'color', 0xFF1565C0));
  });

  testWidgets('escribir el RGB a mano elige ese color', (tester) async {
    ProfileAppearanceChoice? choice;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                choice = await showProfileAppearanceSheet(context, currentColor: 0xFF1565C0, hasPhoto: false),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ProfileStrings.colorTab));
    await tester.pumpAndSettle();

    final red = find.widgetWithText(TextField, ProfileStrings.redLabel);
    await tester.dragUntilVisible(red, find.byType(ListView).last, const Offset(0, -200));
    await tester.enterText(red, '255');
    await tester.enterText(find.widgetWithText(TextField, ProfileStrings.greenLabel), '0');
    await tester.enterText(find.widgetWithText(TextField, ProfileStrings.blueLabel), '128');
    await tester.tap(find.text(ProfileStrings.applyColor));
    await tester.pumpAndSettle();

    expect(choice, isA<HeaderColorChoice>().having((c) => c.color, 'color', 0xFFFF0080));
  });

  testWidgets('el lápiz está arriba de todo y desaparece al scrollear', (tester) async {
    var edits = 0;
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            controller: controller,
            slivers: [
              ProfileSliverHeader(firstName: 'Lucho', lastName: 'Test', onEdit: () => edits++),
              const SliverToBoxAdapter(child: SizedBox(height: 2000)),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip(ProfileStrings.editAppearanceTooltip));
    expect(edits, 1);

    controller.jumpTo(60);
    await tester.pump();

    expect(find.byTooltip(ProfileStrings.editAppearanceTooltip), findsNothing);
  });

  testWidgets('sobre un color claro el texto de la cabecera pasa a oscuro', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [ProfileSliverHeader(firstName: 'Lucho', lastName: 'Test', headerColor: Color(0xFFFFF59D))],
          ),
        ),
      ),
    );

    final name = tester.widget<Text>(find.text('Lucho Test'));
    expect(name.style?.color, isNot(Colors.white));
    expect(name.style!.color!.computeLuminance(), lessThan(0.2));
  });
}
