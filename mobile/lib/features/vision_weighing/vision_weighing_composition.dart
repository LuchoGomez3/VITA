import 'package:frontend_mayoral/features/vision_weighing/data/repositories/local_vision_capture_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_cubit.dart';

/// Ensambla la feature manteniendo codecs e isolates fuera de presentación.
VisionCaptureCubit createVisionCaptureCubit() => VisionCaptureCubit(
  const PrepareVisionCapture(LocalVisionCaptureRepository()),
);
