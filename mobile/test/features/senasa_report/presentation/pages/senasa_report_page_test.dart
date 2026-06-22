import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

void main() {
  testWidgets('does not continue without an establishment', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SenasaReportPage()),
    );

    await tester.tap(find.text(SenasaStrings.btnContinue));
    await tester.pumpAndSettle();

    expect(find.text(SenasaStrings.establishmentRequired), findsOneWidget);
    expect(find.text(SenasaStrings.step1Title), findsOneWidget);
    expect(find.text(SenasaStrings.step2Title), findsNothing);
  });
}
