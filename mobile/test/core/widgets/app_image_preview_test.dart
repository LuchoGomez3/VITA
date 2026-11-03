import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/app_image_preview.dart';
import 'package:image/image.dart' as img;

void main() {
  testWidgets('llena el alto del visor y redondea el lienzo sin deformar la foto', (tester) async {
    final bytes = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: AppImagePreview(
                bytes: bytes,
                height: 180,
                fillHeight: true,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(AppImagePreview)), const Size(320, 180));
    expect(tester.getSize(find.byType(Image)).height, 180);
    expect(tester.widget<InteractiveViewer>(find.byType(InteractiveViewer)).constrained, isTrue);
    expect(tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius, BorderRadius.circular(16));
  });

  testWidgets('conserva el alto del visor cuando la foto se gira para revisión', (tester) async {
    final bytes = Uint8List.fromList(img.encodeJpg(img.Image(width: 360, height: 640)));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: AppImagePreview(bytes: bytes, height: 180, fillHeight: true, quarterTurns: 1),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(RotatedBox)).height, 180);
  });

  testWidgets('limita el desplazamiento ampliado en ambos bordes horizontales', (tester) async {
    final bytes = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: AppImagePreview(bytes: bytes, height: 180, fillHeight: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final previewFinder = find.byType(AppImagePreview);
    final center = tester.getCenter(previewFinder);
    final first = await tester.startGesture(center - const Offset(40, 0), pointer: 1);
    final second = await tester.startGesture(center + const Offset(40, 0), pointer: 2);
    await tester.pump();
    await first.moveTo(center - const Offset(80, 0));
    await second.moveTo(center + const Offset(80, 0));
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pumpAndSettle();

    final previewRect = tester.getRect(previewFinder);
    await tester.drag(previewFinder, const Offset(1000, 0));
    await tester.pumpAndSettle();
    var imageRect = tester.getRect(find.byType(Image));
    expect(imageRect.left, closeTo(previewRect.left, 0.01));
    expect(imageRect.right, greaterThanOrEqualTo(previewRect.right));

    await tester.drag(previewFinder, const Offset(-2000, 0));
    await tester.pumpAndSettle();
    imageRect = tester.getRect(find.byType(Image));
    expect(imageRect.left, lessThanOrEqualTo(previewRect.left));
    expect(imageRect.right, closeTo(previewRect.right, 0.01));
  });

  testWidgets('zoom con dos dedos dentro del scroll y recuperación al soltarlos', (tester) async {
    final bytes = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    var interacting = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              controller: scrollController,
              physics: interacting ? const NeverScrollableScrollPhysics() : null,
              child: Column(
                children: [
                  AppImagePreview(
                    bytes: bytes,
                    height: 310,
                    onInteractionChanged: (value) => setState(() => interacting = value),
                  ),
                  const SizedBox(height: 1200, width: double.infinity),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final center = tester.getCenter(find.byType(AppImagePreview));
    final first = await tester.startGesture(center - const Offset(40, 0), pointer: 1);
    await tester.pump();
    expect(interacting, isTrue);
    // El primer dedo se mueve antes de llegar el segundo: el scroll no debe
    // apropiarse del gesto e impedir el pellizco posterior.
    await first.moveBy(const Offset(0, -25));
    await tester.pump();
    final second = await tester.startGesture(center + const Offset(40, 0), pointer: 2);
    await tester.pump();
    for (var step = 0; step < 5; step++) {
      await first.moveBy(const Offset(-12, 0));
      await second.moveBy(const Offset(12, 0));
      await tester.pump();
    }

    final transforms = tester.widgetList<Transform>(
      find.descendant(of: find.byType(InteractiveViewer), matching: find.byType(Transform)),
    );
    expect(transforms.any((widget) => widget.transform.getMaxScaleOnAxis() > 1.1), isTrue);
    expect(scrollController.offset, 0);
    await first.up();
    await tester.pump();
    expect(interacting, isTrue);
    await second.up();
    await tester.pumpAndSettle();
    expect(interacting, isFalse);

    await tester.dragFrom(const Offset(400, 500), const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(scrollController.offset, greaterThan(0));
  });
}
