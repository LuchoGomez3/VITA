import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/confirm_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/process_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/save_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_view_data.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';

/// Coordina el control local y conserva solamente capturas aptas para revisión.
class VisionCaptureCubit extends Cubit<ResultState<VisionCaptureViewData>> {
  /// La página crea y cierra esta instancia mediante BlocProvider.
  VisionCaptureCubit(this._process, this._confirm, this._save) : super(const ResultState.initial());

  final ProcessVisionCapture _process;
  final ConfirmVisionCapture _confirm;
  final SaveVisionWeight _save;

  bool _saving = false;
  // Invalida resultados tardíos al reintentar o abandonar la página.
  int _generation = 0;

  /// Bloquea capturas duplicadas y transforma rechazos en alertas de UI.
  Future<void> process(Uint8List bytes, {Stopwatch? captureTimer}) async {
    if (state is Loading<VisionCaptureViewData>) return;
    final generation = ++_generation;
    emit(const ResultState.loading());
    // En cámara comienza con el disparador; en galería empieza al procesar.
    final timer = captureTimer ?? (Stopwatch()..start());
    try {
      final capture = await _process(bytes);
      if (isClosed || generation != _generation) return;
      emit(
        ResultState.data(
          VisionCaptureViewData(
            capture: capture,
            inferenceMilliseconds: timer.elapsedMilliseconds,
          ),
        ),
      );
    } on VisionCaptureRejectedException catch (error) {
      if (!isClosed && generation == _generation) {
        emit(
          ResultState.error(
            DomainException(
              message: VisionWeighingStrings.resolution,
              code: DomainErrorCode.validation,
              reason: error,
            ),
          ),
        );
      }
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
    if (state case Data<VisionCaptureViewData>(:final data)) {
      try {
        final reviewed = _confirm(
          capture: data.capture,
          sharpnessConfirmed: sharpnessConfirmed,
          completeAnimalConfirmed: completeAnimalConfirmed,
          lateralConfirmed: lateralConfirmed,
          calibrationWeightKg: calibrationWeightKg,
        );
        emit(ResultState.data(data.copyWith(reviewedCapture: reviewed)));
      } on InvalidVisionCaptureReviewException {
        return;
      }
    }
  }

  /// Guarda una sola vez el resultado IA tras los controles manuales.
  /// Un fallo de SQLite mantiene la foto visible para poder reintentar.
  Future<void> save(String animalId) async {
    if (_saving) return;
    if (state case Data<VisionCaptureViewData>(:final data)) {
      final reviewed = data.reviewedCapture;
      if (reviewed == null || data.saved) return;
      _saving = true;
      try {
        await _save(animalId: animalId, reviewedCapture: reviewed);
        if (!isClosed && state is Data<VisionCaptureViewData>) {
          emit(ResultState.data(data.copyWith(saved: true)));
        }
      } on Exception catch (error, stack) {
        developer.log('No se pudo guardar el pesaje IA', name: 'vision_weighing', error: error, stackTrace: stack);
        if (!isClosed) {
          emit(ResultState.data(data));
          throw VisionDeviceException(cause: error);
        }
      } finally {
        _saving = false;
      }
    }
  }

  /// Descarta la foto de la sesión y permite una nueva captura.
  void retry() {
    _generation++;
    emit(const ResultState.initial());
  }
}
