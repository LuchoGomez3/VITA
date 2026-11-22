import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/widgets/manual_rfid_entry.dart';

void main() {
  testWidgets('solo habilita búsqueda con quince números y rechaza letras o pegados largos', (tester) async {
    String? submitted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ManualRfidEntry(onSubmitted: (value) => submitted = value)),
      ),
    );
    final field = find.byType(TextFormField);
    final button = find.byType(AppOutlinedButton);
    expect(tester.widget<AppOutlinedButton>(button).onPressed, isNull);
    await tester.enterText(field, '98200041299141');
    await tester.pump();
    expect(tester.widget<AppOutlinedButton>(button).onPressed, isNull);
    await tester.enterText(field, 'A982000412991416');
    await tester.pump();
    expect(tester.widget<TextFormField>(field).controller!.text, '98200041299141');
    await tester.enterText(field, '9820004129914160');
    await tester.pump();
    expect(tester.widget<TextFormField>(field).controller!.text, '98200041299141');
    await tester.enterText(field, '982000412991416');
    await tester.pump();
    expect(tester.widget<AppOutlinedButton>(button).onPressed, isNotNull);
    await tester.tap(button);
    expect(submitted, '982000412991416');
  });
}
