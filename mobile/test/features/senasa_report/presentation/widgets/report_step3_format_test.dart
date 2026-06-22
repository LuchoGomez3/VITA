import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step3_format.dart';

void main() {
  testWidgets('requires responsible name and DNI', (tester) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final dniController = TextEditingController();
    addTearDown(nameController.dispose);
    addTearDown(dniController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportStep3Format(
            formKey: formKey,
            selectedFormat: SenasaStrings.step3pdf,
            onFormatChanged: (_) {},
            responsibleNameController: nameController,
            responsibleDniController: dniController,
          ),
        ),
      ),
    );

    expect(formKey.currentState?.validate(), isFalse);
    await tester.pump();

    expect(find.text(SenasaStrings.responsibleNameRequired), findsOneWidget);
    expect(find.text(SenasaStrings.responsibleDniRequired), findsOneWidget);

    nameController.text = 'Juan Perez';
    dniController.text = '30111222';

    expect(formKey.currentState?.validate(), isTrue);
  });
}
