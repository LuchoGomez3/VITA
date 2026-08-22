import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/fields/app_text_form_field.dart';

void main() {
  testWidgets('transfiere el focusNode y prefixText al campo de Flutter', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextFormField(
            focusNode: focusNode,
            title: 'Monto',
            prefixText: r'$ ',
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
    expect(find.text(r'$ '), findsOneWidget);
  });
}
