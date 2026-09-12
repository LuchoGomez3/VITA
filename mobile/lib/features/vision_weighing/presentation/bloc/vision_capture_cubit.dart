import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';

/// Coordina el control local y conserva solamente capturas aptas para revisión.
class VisionCaptureCubit extends Cubit<ResultState<VisionCapture>> {
  /// La página crea y cierra esta instancia mediante BlocProvider.
  VisionCaptureCubit(this._prepare) : super(const ResultState.initial());

  final PrepareVisionCapture _prepare;
  // Invalida resultados tardíos al reintentar o abandonar la página.
  int _generation = 0;

  /// Bloquea capturas duplicadas y transforma rechazos en alertas de UI.
  Future<void> process(Uint8List bytes) async {
    if (state is Loading<VisionCapture>) return;
    final generation = ++_generation;
    emit(const ResultState.loading());
    try {
      final capture = await _prepare(bytes);
      if (isClosed || generation != _generation) return;
      final message = switch (capture.quality) {
        CaptureQuality.insufficientResolution => VisionWeighingStrings.resolution,
        // Estos diagnósticos se muestran como advertencias en la revisión
        // manual hasta contar con capturas reales para calibrarlos.
        CaptureQuality.blurry ||
        CaptureQuality.poorlyFramed ||
        CaptureQuality.badExposure ||
        CaptureQuality.reviewRequired => null,
      };
      emit(
        message == null
            ? ResultState.data(capture)
            : ResultState.error(
                DomainException(message: message, code: DomainErrorCode.validation),
              ),
      );
    } on Exception catch (error, stack) {
      developer.log('Falló el preprocesamiento de captura', name: 'vision_weighing', error: error, stackTrace: stack);
      if (!isClosed && generation == _generation) {
        emit(const ResultState.error(DomainException(message: VisionWeighingStrings.processingError)));
      }
    }
  }

  /// Asocia el peso sólo cuando el operario completó la revisión visual.
  void confirm({
    required bool sharpnessConfirmed,
    required bool completeAnimalConfirmed,
    required bool lateralConfirmed,
    double? calibrationWeightKg,
  }) {
    if (state case Data<VisionCapture>(:final data)) {
      if (!sharpnessConfirmed ||
          !completeAnimalConfirmed ||
          !lateralConfirmed ||
          (calibrationWeightKg != null && (!calibrationWeightKg.isFinite || calibrationWeightKg <= 0))) {
        return;
      }
      emit(ResultState.data(data.copyWith(lateralConfirmed: true, calibrationWeightKg: calibrationWeightKg)));
    }
  }

  /// Descarta la foto de la sesión y permite una nueva captura.
  void retry() {
    _generation++;
    emit(const ResultState.initial());
  }
}
