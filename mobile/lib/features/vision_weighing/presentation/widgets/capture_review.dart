import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/get_vision_animal_options.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/parse_calibration_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_cubit.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_view_data.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/capture_photo_preview.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/manual_capture_review_card.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/vision_animal_selector.dart';

/// Revisión visual y formulario de peso real, sin prometer guardado de dataset.
class CaptureReview extends StatefulWidget {
  /// Muestra exactamente la imagen normalizada que recibió el control local.
  const CaptureReview({
    required this.review,
    required this.getAnimalOptions,
    required this.calibration,
    required this.captureOrientation,
    super.key,
  });

  /// Captura y estado visual coordinados por el Cubit.
  final VisionCaptureViewData review;

  /// Obtiene animales y establecimientos locales para la asociación.
  final GetVisionAnimalOptions getAnimalOptions;

  /// Solicita kilos de balanza si se activó la calibración antes de capturar.
  final bool calibration;

  /// Sentido en que se sostuvo el teléfono al realizar la captura.
  final VisionDeviceOrientation captureOrientation;

  @override
  State<CaptureReview> createState() => _CaptureReviewState();
}

class _CaptureReviewState extends State<CaptureReview> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  VisionAnimal? _selectedAnimal;
  bool _sharpnessConfirmed = false;
  bool _completeAnimalConfirmed = false;
  bool _lateralConfirmed = false;
  bool _saving = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _confirmCapture() {
    if (!_formKey.currentState!.validate()) return;
    context.read<VisionCaptureCubit>().confirm(
      sharpnessConfirmed: _sharpnessConfirmed,
      completeAnimalConfirmed: _completeAnimalConfirmed,
      lateralConfirmed: _lateralConfirmed,
      calibrationWeightKg: widget.calibration ? parseCalibrationWeight(_weightController.text) : null,
    );
  }

  Future<void> _saveWeight() async {
    if (_saving) return;
    final selectedAnimal = _selectedAnimal;
    if (selectedAnimal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(VisionWeighingStrings.selectAnimalBeforeSave)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<VisionCaptureCubit>().save(selectedAnimal.id);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(VisionWeighingStrings.saveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final capture = widget.review.capture;
    final confirmed = widget.review.confirmed;
    final qualityWarning = _qualityWarningFor(capture.quality);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CapturePhotoPreview(
              capture: capture,
              orientation: widget.captureOrientation,
            ),
            if (qualityWarning != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(qualityWarning, style: AppTypography.formFieldHelper),
            ],
            if (widget.calibration) ...[
              const SizedBox(height: AppSpacing.sm),
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
            if (widget.review.inferenceMilliseconds case final elapsed when elapsed > 3000) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                VisionWeighingStrings.slowInference,
                style: AppTypography.smallEmphasis.copyWith(color: AppColors.warning),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            if (!confirmed)
              FormField<bool>(
                initialValue: false,
                validator: (_) => _manualReviewCompleted ? null : VisionWeighingStrings.confirmManualReview,
                builder: (field) => ManualCaptureReviewCard(
                  sharpnessConfirmed: _sharpnessConfirmed,
                  completeAnimalConfirmed: _completeAnimalConfirmed,
                  lateralConfirmed: _lateralConfirmed,
                  errorText: field.errorText,
                  onSharpnessChanged: (value) {
                    setState(() => _sharpnessConfirmed = value ?? false);
                    field.didChange(_manualReviewCompleted);
                  },
                  onCompleteAnimalChanged: (value) {
                    setState(() => _completeAnimalConfirmed = value ?? false);
                    field.didChange(_manualReviewCompleted);
                  },
                  onLateralChanged: (value) {
                    setState(() => _lateralConfirmed = value ?? false);
                    field.didChange(_manualReviewCompleted);
                  },
                ),
              )
            else if (capture.estimatedWeightKg != null)
              AbsorbPointer(
                absorbing: _saving || widget.review.saved,
                child: VisionAnimalSelector(
                  getAnimalOptions: widget.getAnimalOptions,
                  selectedAnimal: _selectedAnimal,
                  onSelected: (animal) => setState(() => _selectedAnimal = animal),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            if (widget.review.saved)
              const Text(VisionWeighingStrings.saved, style: AppTypography.formFieldSuccess)
            else if (confirmed && capture.estimatedWeightKg == null)
              const Text(VisionWeighingStrings.draftReady, style: AppTypography.formFieldHelper)
            else
              AppFilledButton(
                onPressed: _saving
                    ? null
                    : confirmed
                    ? _saveWeight
                    : _confirmCapture,
                label: confirmed ? VisionWeighingStrings.saveEstimate : VisionWeighingStrings.confirm,
              ),
            const SizedBox(height: AppSpacing.xs),
            AppOutlinedButton(
              onPressed: _saving ? null : context.read<VisionCaptureCubit>().retry,
              label: VisionWeighingStrings.retry,
            ),
          ],
        ),
      ),
    );
  }

  bool get _manualReviewCompleted => _sharpnessConfirmed && _completeAnimalConfirmed && _lateralConfirmed;
}

String? _qualityWarningFor(CaptureQuality quality) {
  return switch (quality) {
    CaptureQuality.blurry => VisionWeighingStrings.sharpnessWarning,
    CaptureQuality.poorlyFramed => VisionWeighingStrings.framingWarning,
    CaptureQuality.badExposure => VisionWeighingStrings.exposureWarning,
    CaptureQuality.reviewRequired || CaptureQuality.insufficientResolution => null,
  };
}
