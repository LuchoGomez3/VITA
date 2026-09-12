import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_capture_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_cubit.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/capture_review.dart';
import 'package:image/image.dart' as img;

class _Repository implements VisionCaptureRepository {
  @override
  Future<VisionCapture> prepare(Uint8List bytes) async => VisionCapture(
    jpegBytes: bytes,
    quality: CaptureQuality.reviewRequired,
    sharpness: 100,
  );
}

void main() {
  testWidgets('calibración exige peso y los tres controles manuales', (tester) async {
    final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    final cubit = VisionCaptureCubit(PrepareVisionCapture(_Repository()));
    addTearDown(cubit.close);
    await cubit.process(photo);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: BlocBuilder<VisionCaptureCubit, ResultState<VisionCapture>>(
              builder: (context, state) => CaptureReview(
                capture: (state as Data<VisionCapture>).data,
                calibration: true,
                captureOrientation: DeviceOrientation.landscapeRight,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is RotatedBox && widget.quarterTurns == 3,
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text(VisionWeighingStrings.confirm));
    await tester.tap(find.text(VisionWeighingStrings.confirm));
    await tester.pumpAndSettle();
    expect(find.text(VisionWeighingStrings.invalidWeight), findsOneWidget);
    expect(find.text(VisionWeighingStrings.confirmManualReview), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '410,25');
    for (var index = 0; index < 3; index++) {
      final checkbox = find.byType(CheckboxListTile).at(index);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
    }
    await tester.ensureVisible(find.text(VisionWeighingStrings.confirm));
    await tester.tap(find.text(VisionWeighingStrings.confirm));
    await tester.pumpAndSettle();
    expect((cubit.state as Data<VisionCapture>).data.calibrationWeightKg, 410.25);
    expect(find.text(VisionWeighingStrings.draftReady), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
