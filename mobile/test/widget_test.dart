import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/app.dart';

void main() {
  testWidgets('renders app home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const FrontendMayoralApp());
    await tester.pumpAndSettle();

    expect(find.text('Trazabilidad ganadera'), findsOneWidget);
    expect(find.text('Registrar animal'), findsOneWidget);
  });
}
