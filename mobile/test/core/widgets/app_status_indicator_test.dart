import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/app_status_indicator.dart';

void main() {
  testWidgets('alterna entre progreso indeterminado y resultado completo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppStatusIndicator(
          icon: Icons.cloud_upload_outlined,
          color: Colors.green,
          isLoading: true,
        ),
      ),
    );

    var progress = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(progress.value, isNull);

    await tester.pumpWidget(
      const MaterialApp(
        home: AppStatusIndicator(
          icon: Icons.check,
          color: Colors.green,
          isLoading: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    progress = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(progress.value, 1);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
