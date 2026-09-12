import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_cubit.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';

/// Revisión visual y formulario de peso real, sin prometer guardado de dataset.
class CaptureReview extends StatefulWidget {
  /// Muestra exactamente la imagen normalizada que recibió el control local.
  const CaptureReview({
    required this.capture,
    required this.calibration,
    required this.captureOrientation,
    super.key,
  });

  /// Fotografía que superó los controles técnicos.
  final VisionCapture capture;

  /// Solicita kilos de balanza si se activó la calibración antes de capturar.
  final bool calibration;

  /// Sentido en que se sostuvo el teléfono al realizar la captura.
  final DeviceOrientation captureOrientation;

  @override
  State<CaptureReview> createState() => _CaptureReviewState();
}

class _CaptureReviewState extends State<CaptureReview> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  bool _sharpnessConfirmed = false;
  bool _completeAnimalConfirmed = false;
  bool _lateralConfirmed = false;
  bool _interactingWithImage = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    context.read<VisionCaptureCubit>().confirm(
      sharpnessConfirmed: _sharpnessConfirmed,
      completeAnimalConfirmed: _completeAnimalConfirmed,
      lateralConfirmed: _lateralConfirmed,
      calibrationWeightKg: widget.calibration ? parseCalibrationWeight(_weightController.text) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmed = widget.capture.lateralConfirmed;
    final qualityWarning = _qualityWarningFor(widget.capture.quality);
    return SingleChildScrollView(
      // El visor conserva los gestos desde el primer contacto, incluso si el
      // segundo dedo del zoom llega después de empezar a mover el primero.
      physics: _interactingWithImage ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppImagePreview(
              bytes: widget.capture.jpegBytes,
              height: 310,
              quarterTurns: _quarterTurnsFor(widget.captureOrientation),
              onInteractionChanged: (interacting) {
                setState(() => _interactingWithImage = interacting);
              },
            ),
            if (qualityWarning != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(qualityWarning, style: AppTypography.formFieldHelper),
            ],
            if (widget.calibration) ...[
              const SizedBox(height: AppSpacing.md),
              AppTextFormField(
                controller: _weightController,
                enabled: !confirmed,
                title: VisionWeighingStrings.weight,
                hintText: VisionWeighingStrings.weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    parseCalibrationWeight(value ?? '') == null ? VisionWeighingStrings.invalidWeight : null,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              color: AppColors.surface,
              elevation: AppElevation.card,
              shadowColor: AppColors.textPrimary,
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    VisionWeighingStrings.manualReviewTitle,
                    style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary),
                  ),
                  FormField<bool>(
                    initialValue: false,
                    validator: (_) => _manualReviewCompleted ? null : VisionWeighingStrings.confirmManualReview,
                    builder: (field) => _ManualReviewChecklist(
                      confirmed: confirmed,
                      sharpnessConfirmed: _sharpnessConfirmed,
                      completeAnimalConfirmed: _completeAnimalConfirmed,
                      lateralConfirmed: _lateralConfirmed,
                      errorText: field.errorText,
                      onSharpnessChanged: (value) {
                        setState(
                          () => _sharpnessConfirmed = value ?? false,
                        );
                        field.didChange(_manualReviewCompleted);
                      },
                      onCompleteAnimalChanged: (value) {
                        setState(
                          () => _completeAnimalConfirmed = value ?? false,
                        );
                        field.didChange(_manualReviewCompleted);
                      },
                      onLateralChanged: (value) {
                        setState(() => _lateralConfirmed = value ?? false);
                        field.didChange(_manualReviewCompleted);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (confirmed)
              const Text(VisionWeighingStrings.draftReady, style: AppTypography.formFieldHelper)
            else
              AppFilledButton(onPressed: _confirm, label: VisionWeighingStrings.confirm),
            const SizedBox(height: AppSpacing.xs),
            AppOutlinedButton(
              onPressed: context.read<VisionCaptureCubit>().retry,
              label: VisionWeighingStrings.retry,
            ),
          ],
        ),
      ),
    );
  }

  bool get _manualReviewCompleted => _sharpnessConfirmed && _completeAnimalConfirmed && _lateralConfirmed;
}

class _ManualReviewChecklist extends StatelessWidget {
  const _ManualReviewChecklist({
    required this.confirmed,
    required this.sharpnessConfirmed,
    required this.completeAnimalConfirmed,
    required this.lateralConfirmed,
    required this.errorText,
    required this.onSharpnessChanged,
    required this.onCompleteAnimalChanged,
    required this.onLateralChanged,
  });

  final bool confirmed;
  final bool sharpnessConfirmed;
  final bool completeAnimalConfirmed;
  final bool lateralConfirmed;
  final String? errorText;
  final ValueChanged<bool?> onSharpnessChanged;
  final ValueChanged<bool?> onCompleteAnimalChanged;
  final ValueChanged<bool?> onLateralChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(VisionWeighingStrings.sharpnessConfirmation),
          value: sharpnessConfirmed,
          onChanged: confirmed ? null : onSharpnessChanged,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            VisionWeighingStrings.completeAnimalConfirmation,
          ),
          value: completeAnimalConfirmed,
          onChanged: confirmed ? null : onCompleteAnimalChanged,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(VisionWeighingStrings.lateralConfirmation),
          value: lateralConfirmed,
          onChanged: confirmed ? null : onLateralChanged,
        ),
        if (errorText case final String error)
          Text(
            error,
            style: AppTypography.formFieldError,
          ),
      ],
    );
  }
}

int _quarterTurnsFor(DeviceOrientation orientation) {
  return switch (orientation) {
    DeviceOrientation.portraitUp => 0,
    DeviceOrientation.landscapeRight => 3,
    DeviceOrientation.portraitDown => 2,
    DeviceOrientation.landscapeLeft => 1,
  };
}

String? _qualityWarningFor(CaptureQuality quality) {
  return switch (quality) {
    CaptureQuality.blurry => VisionWeighingStrings.sharpnessWarning,
    CaptureQuality.poorlyFramed => VisionWeighingStrings.framingWarning,
    CaptureQuality.badExposure => VisionWeighingStrings.exposureWarning,
    CaptureQuality.reviewRequired || CaptureQuality.insufficientResolution => null,
  };
}
