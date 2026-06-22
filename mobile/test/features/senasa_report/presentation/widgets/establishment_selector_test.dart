import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/establishment_data_form.dart';

void main() {
  testWidgets('requires an establishment selection', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: EstablishmentSelector(
              selectedOrigin: null,
              onOriginChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState?.validate(), isFalse);
    await tester.pump();

    expect(find.text(SenasaStrings.establishmentRequired), findsOneWidget);
  });
}
