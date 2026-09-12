import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/theme/app_colors.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/vision_camera_header.dart';

void main() {
  testWidgets('adjuntar una foto desde configuración no cambia el modo calibración', (tester) async {
    var attachments = 0;
    var calibrationChanges = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              VisionCameraHeader(
                orientation: DeviceOrientation.portraitUp,
                calibration: true,
                busy: false,
                onCalibrationChanged: (_) => calibrationChanges++,
                onAttachPhoto: () => attachments++,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip(VisionWeighingStrings.settings));
    await tester.pumpAndSettle();
    expect(find.text(VisionWeighingStrings.calibration), findsOneWidget);
    await tester.tap(find.text(VisionWeighingStrings.attachPhoto));
    await tester.pumpAndSettle();

    expect(attachments, 1);
    expect(calibrationChanges, 0);
  });

  testWidgets('el intento vertical destaca el aviso y horizontal muestra el tick verde', (tester) async {
    // Se conserva el aviso solicitado para comprobar que la orientación
    // horizontal tiene prioridad sobre el estado de advertencia anterior.
    Widget header(DeviceOrientation orientation, {bool highlighted = false}) => MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            VisionCameraHeader(
              orientation: orientation,
              orientationWarningHighlighted: highlighted,
              calibration: false,
              busy: false,
              onCalibrationChanged: (_) {},
              onAttachPhoto: () {},
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(header(DeviceOrientation.portraitUp));
    expect(find.text(VisionWeighingStrings.rotate), findsOneWidget);
    final normalText = tester.widget<Text>(find.text(VisionWeighingStrings.rotate));
    expect(normalText.style?.fontWeight, FontWeight.w500);

    await tester.pumpWidget(header(DeviceOrientation.portraitUp, highlighted: true));
    await tester.pumpAndSettle();
    final warningText = tester.widget<Text>(find.text(VisionWeighingStrings.rotate));
    final warningPill = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(warningText.style?.fontWeight, FontWeight.w700);
    expect((warningPill.decoration! as BoxDecoration).color, AppColors.error);

    for (final orientation in [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]) {
      await tester.pumpWidget(header(orientation, highlighted: true));
      await tester.pumpAndSettle();
      expect(find.text(VisionWeighingStrings.rotate), findsNothing);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      final readyPill = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((readyPill.decoration! as BoxDecoration).color, AppColors.primary);
    }
  });
}
