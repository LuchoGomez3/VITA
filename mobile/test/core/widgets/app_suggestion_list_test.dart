import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/app_suggestion_list.dart';

void main() {
  testWidgets('muestra resultados y devuelve el elemento seleccionado', (
    tester,
  ) async {
    String? selectedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSuggestionList<String>(
            items: const ['Primero', 'Segundo'],
            itemKeyBuilder: (item) => ValueKey('suggestion-$item'),
            itemBuilder: (_, item) => Text(item),
            onSelected: (item) => selectedItem = item,
          ),
        ),
      ),
    );

    expect(find.text('Primero'), findsOneWidget);
    expect(find.text('Segundo'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('suggestion-Segundo')));

    expect(selectedItem, 'Segundo');
  });
}
