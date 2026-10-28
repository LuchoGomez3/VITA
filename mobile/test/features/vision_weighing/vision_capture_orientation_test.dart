import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/storage/animal_photo_store.dart';
import 'package:frontend_mayoral/core/widgets/app_image_preview.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/repositories/brick_vision_weight_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/repositories/local_vision_capture_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/services/tflite_weight_estimator.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_weight_estimate.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_estimator_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/confirm_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/estimate_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/process_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/save_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/capture_photo_preview.dart';
import 'package:image/image.dart' as img;

class _Estimator implements VisionWeightEstimatorRepository {
  Uint8List? jpeg;
  Float32List? tensor;

  @override
  Future<VisionWeightEstimate> estimateWeight(Uint8List jpegBytes) async {
    jpeg = jpegBytes;
    tensor = prepareWeightInput(jpegBytes);
    return const VisionWeightEstimate(weightKg: 400, lowerKg: 320, upperKg: 480, targetCoverage: .9);
  }
}

class _Animals extends Fake implements AnimalBrickStore {
  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async {
    final now = DateTime.utc(2026, 10, 26);
    return BrickAnimalModel(
      localId: animalId,
      establishmentId: 'farm',
      rfidTagNumber: '123456789012345',
      visualTag: '1',
      sex: BrickAnimalSex.female,
      breed: 'Angus',
      birthDate: now,
      categoryId: 'category',
      lotId: 'lot',
      initialWeight: 200,
      weighingMethod: BrickAnimalWeighingMethod.manual,
      weighingDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _Weights extends Fake implements PesajeBrickStore {
  @override
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje) async => pesaje;
}

// Cuadrantes distintos permiten detectar giros que una imagen simétrica oculta.
Uint8List _photoWithExif(int orientation) {
  final upright = img.Image(width: 640, height: 360);
  for (final pixel in upright) {
    if (pixel.y < 180) {
      pixel.setRgb(pixel.x < 320 ? 240 : 15, pixel.x < 320 ? 15 : 240, 15);
    } else {
      pixel.setRgb(pixel.x < 320 ? 15 : 240, pixel.x < 320 ? 15 : 240, pixel.x < 320 ? 240 : 15);
    }
  }
  final encodedPixels = img.copyRotate(
    upright,
    angle: switch (orientation) {
      6 => -90,
      8 => 90,
      3 => 180,
      _ => 0,
    },
  );
  encodedPixels.exif.imageIfd.orientation = orientation;
  return Uint8List.fromList(img.encodeJpg(encodedPixels, quality: 95));
}

void main() {
  for (final orientation in [1, 6, 8, 3]) {
    testWidgets('EXIF $orientation usa los mismos píxeles enderezados en modelo, revisión y foto privada', (
      tester,
    ) async {
      final directory = (await tester.runAsync(() => Directory.systemTemp.createTemp('vita_vision_orientation_')))!;
      addTearDown(() => directory.delete(recursive: true));
      final photos = AnimalPhotoStore(directoryProvider: () async => directory);
      final estimator = _Estimator();
      final process = ProcessVisionCapture(
        const PrepareVisionCapture(LocalVisionCaptureRepository()),
        EstimateVisionWeight(estimator),
      );
      // compute realiza trabajo real en un isolate, fuera del reloj simulado.
      final capture = (await tester.runAsync(() => process(_photoWithExif(orientation))))!;
      final decoded = img.decodeJpg(capture.jpegBytes)!;
      expect((decoded.width, decoded.height), (640, 360));
      expect(decoded.exif.imageIfd.orientation ?? 1, 1);
      final upperLeft = decoded.getPixel(50, 50);
      final upperRight = decoded.getPixel(590, 50);
      final lowerLeft = decoded.getPixel(50, 310);
      expect(upperLeft.r, greaterThan(200));
      expect(upperLeft.g, lessThan(60));
      expect(upperRight.g, greaterThan(200));
      expect(lowerLeft.b, greaterThan(200));
      expect(estimator.jpeg, orderedEquals(capture.jpegBytes));
      expect(estimator.tensor![0], greaterThan(.5));
      expect(estimator.tensor![1], lessThan(-.5));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CapturePhotoPreview(capture: capture)),
        ),
      );
      await tester.pumpAndSettle();
      final preview = tester.widget<AppImagePreview>(find.byType(AppImagePreview));
      expect(preview.bytes, orderedEquals(estimator.jpeg!));
      expect(preview.quarterTurns, 0);
      await tester.tap(find.byType(AppImagePreview));
      await tester.pumpAndSettle();
      for (final viewer in tester.widgetList<AppImagePreview>(find.byType(AppImagePreview))) {
        expect(viewer.bytes, orderedEquals(estimator.jpeg!));
        expect(viewer.quarterTurns, 0);
      }
      await tester.tap(find.byTooltip(VisionWeighingStrings.closeExpandedPhoto));
      await tester.pumpAndSettle();

      final save = SaveVisionWeight(BrickVisionWeightRepository(_Animals(), _Weights(), photoStore: photos));
      final reviewed = const ConfirmVisionCapture()(
        capture: capture,
        sharpnessConfirmed: true,
        completeAnimalConfirmed: true,
        lateralConfirmed: true,
      );
      final saved = await tester.runAsync(() async {
        await save(animalId: 'animal', reviewedCapture: reviewed);
        return photos.readPhotoBytes(establishmentId: 'farm', animalId: 'animal');
      });
      expect(saved, orderedEquals(estimator.jpeg!));
    });
  }
}
