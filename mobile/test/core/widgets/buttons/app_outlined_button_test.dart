import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

void main() {
  testWidgets('does not overflow with a long label and icon on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppOutlinedButton(
            label: 'Agregar otra unidad productiva (otro RENSPA)',
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
