import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_camera_info.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_weight_estimate.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_animal_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_capture_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_photo_picker_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_estimator_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/capture_vision_photo.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/confirm_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/dispose_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/estimate_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/get_vision_animal_options.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/initialize_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/pick_vision_photo.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/process_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/save_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/watch_vision_camera_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_cubit.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_view_data.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/models/vision_camera_dependencies.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/pages/vision_weighing_page.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/capture_review.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

class _Repository implements VisionCaptureRepository {
  @override
  Future<VisionCapture> prepare(Uint8List bytes) async => VisionCapture(
    jpegBytes: bytes,
    quality: CaptureQuality.reviewRequired,
    sharpness: 100,
  );
}

class _WeightRepository implements VisionWeightEstimatorRepository, VisionWeightRepository {
  String? savedAnimalId;
  Completer<void>? pending;
  bool fail = false;

  @override
  Future<VisionWeightEstimate> estimateWeight(Uint8List jpegBytes) async => const VisionWeightEstimate(
    weightKg: 390,
    lowerKg: 304.73,
    upperKg: 475.27,
    targetCoverage: .9,
  );

  @override
  Future<void> saveEstimate({required String animalId, required double weightKg, required Uint8List jpegBytes}) async {
    await pending?.future;
    if (fail) throw const VisionDeviceException();
    savedAnimalId = animalId;
  }
}

VisionCaptureCubit _createCubit(_WeightRepository repository) => VisionCaptureCubit(
  ProcessVisionCapture(PrepareVisionCapture(_Repository()), EstimateVisionWeight(repository)),
  const ConfirmVisionCapture(),
  SaveVisionWeight(repository),
);

class _AnimalRepository implements VisionAnimalRepository {
  @override
  Future<VisionAnimalOptions> getOptions() async => VisionAnimalOptions(
    animals: [
      VisionAnimal(
        id: 'animal-1',
        establishmentId: 'establishment-1',
        rfidTagNumber: 'AR-1',
        visualTag: '1',
        updatedAt: DateTime.utc(2026),
      ),
    ],
    establishments: const [VisionEstablishment(id: 'establishment-1', name: 'Campo 1')],
  );
}

void main() {
  testWidgets('la ruta de captura devuelve la estimación confirmada y sale sin valor al volver', (tester) async {
    final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    final repository = _WeightRepository();
    final camera = _CameraRepository();
    final results = <double?>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () async => results.add(await context.push<double>('/capture')),
              child: const Text('Capturar peso'),
            ),
          ),
        ),
        GoRoute(
          path: '/capture',
          builder: (context, state) => VisionWeighingPage(
            returnWeight: true,
            createCubit: () => _createCubit(repository),
            getAnimalOptions: GetVisionAnimalOptions(_AnimalRepository()),
            pickPhoto: PickVisionPhoto(_PhotoPicker(photo)),
            cameraDependencies: VisionCameraDependencies(
              initialize: InitializeVisionCamera(camera),
              capture: CaptureVisionPhoto(camera),
              watchOrientation: WatchVisionCameraOrientation(camera),
              dispose: DisposeVisionCamera(camera),
              previewBuilder: (_) => const ColoredBox(color: Colors.black),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    Future<void> openReview() async {
      await tester.tap(find.text('Capturar peso'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(VisionWeighingStrings.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text(VisionWeighingStrings.attachPhoto));
      await tester.pumpAndSettle();
      expect(find.text(VisionWeighingStrings.review), findsOneWidget);
    }

    await openReview();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(results, [null]);

    await openReview();
    for (final checkbox in find.byType(CheckboxListTile).evaluate().toList()) {
      final control = find.byWidget(checkbox.widget);
      await tester.ensureVisible(control);
      await tester.tap(control);
    }
    await tester.ensureVisible(find.text(VisionWeighingStrings.confirm));
    await tester.tap(find.text(VisionWeighingStrings.confirm));
    await tester.pumpAndSettle();
    expect(find.text(VisionWeighingStrings.animalSectionTitle), findsNothing);
    await tester.ensureVisible(find.text(VisionWeighingStrings.useEstimate));
    await tester.tap(find.text(VisionWeighingStrings.useEstimate));
    await tester.pumpAndSettle();
    expect(results, [null, 390.0]);
    expect(repository.savedAnimalId, isNull);
    expect(camera.disposals, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renderiza progreso, error y reintento desde el estado sin perder la selección', (tester) async {
    final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    final repository = _WeightRepository()
      ..pending = Completer<void>()
      ..fail = true;
    final cubit = _createCubit(repository);
    addTearDown(cubit.close);
    await cubit.process(photo);
    cubit.confirm(sharpnessConfirmed: true, completeAnimalConfirmed: true, lateralConfirmed: true);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: BlocBuilder<VisionCaptureCubit, ResultState<VisionCaptureViewData>>(
              builder: (context, state) => CaptureReview(
                review: (state as Data<VisionCaptureViewData>).data,
                getAnimalOptions: GetVisionAnimalOptions(_AnimalRepository()),
                calibration: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Caravana RFID: AR-1'));
    await tester.tap(find.text('Caravana RFID: AR-1'));
    await tester.ensureVisible(find.text(VisionWeighingStrings.saveEstimate));
    await tester.tap(find.text(VisionWeighingStrings.saveEstimate));
    await tester.pump();
    expect(find.text(VisionWeighingStrings.saving), findsOneWidget);
    expect(tester.widget<AppFilledButton>(find.byType(AppFilledButton)).isLoading, isTrue);
    expect(tester.widget<AppOutlinedButton>(find.byType(AppOutlinedButton).last).onPressed, isNull);

    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.text(VisionWeighingStrings.saveError), findsOneWidget);
    expect(find.text('Caravana RFID: AR-1'), findsOneWidget);
    expect(find.text(VisionWeighingStrings.saved), findsNothing);
    repository.fail = false;
    await tester.ensureVisible(find.text(VisionWeighingStrings.saveEstimate));
    await tester.tap(find.text(VisionWeighingStrings.saveEstimate));
    await tester.pumpAndSettle();
    expect(find.text(VisionWeighingStrings.saveError), findsNothing);
    expect(find.text(VisionWeighingStrings.saved), findsOneWidget);
    expect(repository.savedAnimalId, 'animal-1');
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra el rango con énfasis y permite revisar la captura', (tester) async {
    final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    final repository = _WeightRepository();
    final cubit = _createCubit(repository);
    addTearDown(cubit.close);
    await cubit.process(photo);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: BlocBuilder<VisionCaptureCubit, ResultState<VisionCaptureViewData>>(
              builder: (context, state) => CaptureReview(
                review: (state as Data<VisionCaptureViewData>).data,
                getAnimalOptions: GetVisionAnimalOptions(_AnimalRepository()),
                calibration: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    await tester.tap(find.byType(AppImagePreview));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byTooltip(VisionWeighingStrings.closeExpandedPhoto), findsOneWidget);
    await tester.tap(find.byTooltip(VisionWeighingStrings.closeExpandedPhoto));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.text(VisionWeighingStrings.weightRange(304.73, 475.27)), findsOneWidget);
    expect(find.text(VisionWeighingStrings.manualReviewTitle), findsOneWidget);
    expect(find.text(VisionWeighingStrings.animalSectionTitle), findsNothing);
    for (var index = 0; index < 3; index++) {
      final checkbox = find.byType(CheckboxListTile).at(index);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
    }
    await tester.ensureVisible(find.text(VisionWeighingStrings.confirm));
    await tester.tap(find.text(VisionWeighingStrings.confirm));
    await tester.pumpAndSettle();
    expect(find.text(VisionWeighingStrings.manualReviewTitle), findsNothing);
    expect(find.text(VisionWeighingStrings.animalSectionTitle), findsOneWidget);
    expect(find.text(VisionWeighingStrings.saveEstimate), findsOneWidget);
    expect(repository.savedAnimalId, isNull);
  });

  testWidgets('muestra peso, exige caravana y guarda al confirmar la revisión', (tester) async {
    final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    final weightRepository = _WeightRepository();
    final cubit = _createCubit(weightRepository);
    addTearDown(cubit.close);
    await cubit.process(photo);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: BlocBuilder<VisionCaptureCubit, ResultState<VisionCaptureViewData>>(
              builder: (context, state) => CaptureReview(
                review: (state as Data<VisionCaptureViewData>).data,
                getAnimalOptions: GetVisionAnimalOptions(_AnimalRepository()),
                calibration: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('390.0 kg'), findsOneWidget);
    expect(find.text(VisionWeighingStrings.weightRange(304.73, 475.27)), findsOneWidget);
    expect(find.textContaining('Cobertura objetivo'), findsNothing);
    expect(find.text(VisionWeighingStrings.estimatedWeight), findsOneWidget);
    final weightText = tester.widget<Text>(find.text('390.0 kg'));
    expect(weightText.style?.color, AppColors.primary);
    final weightCard = tester
        .widgetList<AppSurfaceCard>(find.byType(AppSurfaceCard))
        .singleWhere((card) => card.color == AppColors.backgroundSecondaryLight);
    expect(weightCard.padding, const EdgeInsets.all(AppSpacing.md));
    final weightCardFinder = find.ancestor(
      of: find.text('390.0 kg'),
      matching: find.byType(AppSurfaceCard),
    );
    final imageRect = tester.getRect(find.byType(AppImagePreview));
    final weightCardRect = tester.getRect(weightCardFinder);
    expect(weightCardRect.width, lessThan(imageRect.width));
    expect(weightCardRect.top, lessThan(imageRect.bottom));
    expect(weightCardRect.bottom, greaterThan(imageRect.bottom));
    expect(find.text(VisionWeighingStrings.animalSectionTitle), findsNothing);
    final reviewCard = tester
        .widgetList<AppSurfaceCard>(find.byType(AppSurfaceCard))
        .singleWhere((card) => card.color == AppColors.surface);
    for (var index = 0; index < 3; index++) {
      final checkbox = find.byType(CheckboxListTile).at(index);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
    }
    await tester.ensureVisible(find.text(VisionWeighingStrings.confirm));
    await tester.tap(find.text(VisionWeighingStrings.confirm));
    await tester.pumpAndSettle();
    expect(find.text(VisionWeighingStrings.manualReviewTitle), findsNothing);
    expect(find.text(VisionWeighingStrings.animalSectionTitle), findsOneWidget);
    final animalCard = tester
        .widgetList<AppSurfaceCard>(find.byType(AppSurfaceCard))
        .singleWhere((card) => card.color == AppColors.surface);
    expect(animalCard.color, reviewCard.color);
    expect(animalCard.elevation, reviewCard.elevation);
    expect(animalCard.shadowColor, reviewCard.shadowColor);
    expect(animalCard.padding, reviewCard.padding);
    await tester.ensureVisible(find.text(VisionWeighingStrings.saveEstimate));
    await tester.tap(find.text(VisionWeighingStrings.saveEstimate));
    await tester.pumpAndSettle();
    expect(find.text(VisionWeighingStrings.selectAnimalBeforeSave), findsOneWidget);

    await tester.ensureVisible(find.text('Caravana RFID: AR-1'));
    await tester.tap(find.text('Caravana RFID: AR-1'));
    await tester.ensureVisible(find.text(VisionWeighingStrings.saveEstimate));
    await tester.tap(find.text(VisionWeighingStrings.saveEstimate));
    await tester.pumpAndSettle();
    expect(weightRepository.savedAnimalId, 'animal-1');
    expect(find.text(VisionWeighingStrings.saved), findsOneWidget);
  });

  testWidgets('avisa sólo cuando la estimación supera los 3 segundos', (tester) async {
    final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    final cubit = _createCubit(_WeightRepository());
    addTearDown(cubit.close);
    final capture = VisionCapture(
      jpegBytes: photo,
      quality: CaptureQuality.reviewRequired,
      sharpness: 100,
      estimatedWeightKg: 390,
    );

    Widget reviewFor(int elapsed) => MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: Scaffold(
          body: CaptureReview(
            review: VisionCaptureViewData(capture: capture, inferenceMilliseconds: elapsed),
            getAnimalOptions: GetVisionAnimalOptions(_AnimalRepository()),
            calibration: false,
          ),
        ),
      ),
    );

    await tester.pumpWidget(reviewFor(3001));
    expect(find.text(VisionWeighingStrings.slowInference), findsOneWidget);
    expect(find.textContaining('ms'), findsNothing);
    await tester.pumpWidget(reviewFor(3000));
    expect(find.text(VisionWeighingStrings.slowInference), findsNothing);
  });

  testWidgets('calibración exige peso y los tres controles manuales', (tester) async {
    final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 640, height: 360)));
    final cubit = _createCubit(_WeightRepository());
    addTearDown(cubit.close);
    await cubit.process(photo);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: BlocBuilder<VisionCaptureCubit, ResultState<VisionCaptureViewData>>(
              builder: (context, state) => CaptureReview(
                review: (state as Data<VisionCaptureViewData>).data,
                getAnimalOptions: GetVisionAnimalOptions(_AnimalRepository()),
                calibration: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is RotatedBox && widget.quarterTurns == 0,
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
    expect((cubit.state as Data<VisionCaptureViewData>).data.reviewedCapture?.calibrationWeightKg, 410.25);
    expect(find.text(VisionWeighingStrings.animalSectionTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _CameraRepository implements VisionCameraRepository {
  int disposals = 0;

  @override
  Stream<VisionDeviceOrientation> get orientationChanges => const Stream.empty();

  @override
  Future<Uint8List> capturePhoto({required VisionDeviceOrientation orientation}) async => Uint8List(0);

  @override
  Future<void> dispose() async => disposals++;

  @override
  Future<VisionCameraInfo> initialize() async => const VisionCameraInfo(aspectRatio: 1);
}

class _PhotoPicker implements VisionPhotoPickerRepository {
  _PhotoPicker(this.photo);

  final Uint8List photo;

  @override
  Future<Uint8List> pickPhoto() async => photo;
}
