import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock/presentation/pages/livestock_page.dart';
import 'package:frontend_mayoral/features/livestock/presentation/strings/livestock_strings.dart';

void main() {
  testWidgets('abre la identificación y no presenta accesos demo', (tester) async {
    var identificationRequests = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: LivestockPage(
          onIdentifyAnimal: () => identificationRequests++,
        ),
      ),
    );

    expect(find.text(LivestockStrings.readTagDescription), findsOneWidget);
    expect(find.text('Ver animal 012'), findsNothing);

    await tester.tap(
      find.widgetWithText(AppFilledButton, LivestockStrings.readTagTitle),
    );

    expect(identificationRequests, 1);
  });
}
