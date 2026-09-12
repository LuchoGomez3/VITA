import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/app_image_preview.dart';
import 'package:image/image.dart' as img;

void main() {
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
