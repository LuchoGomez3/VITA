import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

void main() {
  testWidgets('el selector se dibuja dentro de un AlertDialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppDropdownFormField<String>(
                        title: 'Lote de destino',
                        hintText: 'Lote de destino',
                        options: const [AppDropdownOption(value: 'a', label: 'El Bajo')],
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    // Antes: "LayoutBuilder does not support returning intrinsic dimensions".
    expect(tester.takeException(), isNull);
    expect(find.text('Lote de destino'), findsWidgets);
  });
}
