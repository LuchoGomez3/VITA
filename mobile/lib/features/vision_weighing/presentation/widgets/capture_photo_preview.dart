import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';

/// Presenta la captura y su resultado como una unidad visual reutilizable.
class CapturePhotoPreview extends StatelessWidget {
  /// Muestra el mismo JPEG normalizado que se infiere y se guarda.
  const CapturePhotoPreview({required this.capture, super.key});

  /// Captura procesada que aporta la fotografía y el peso estimado.
  final VisionCapture capture;

  Future<void> _showExpandedPhoto(BuildContext context) async {
    await showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (_) => _ExpandedPhotoDialog(
        bytes: capture.jpegBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewHeight = (constraints.maxWidth * 9 / 16).clamp(0, 240).toDouble();
        final estimatedWeight = capture.estimatedWeightKg;
        final badgeBottomSpace = estimatedWeight == null ? 0.0 : AppSpacing.xl + AppSpacing.lg;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              // Este espacio reserva la parte de la etiqueta que sobresale de
              // la fotografía para que no cubra el contenido siguiente.
              padding: EdgeInsets.only(bottom: badgeBottomSpace),
              child: Semantics(
                button: true,
                label: VisionWeighingStrings.expandPhoto,
                child: AppImagePreview(
                  bytes: capture.jpegBytes,
                  height: previewHeight,
                  fillHeight: true,
                  zoomEnabled: false,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () => _showExpandedPhoto(context),
                ),
              ),
            ),
            if (estimatedWeight != null)
              Positioned(
                left: AppSpacing.sm,
                bottom: 0,
                child: _WeightEstimateBadge(capture: capture, weight: estimatedWeight),
              ),
          ],
        );
      },
    );
  }
}

class _ExpandedPhotoDialog extends StatelessWidget {
  const _ExpandedPhotoDialog({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => AppImagePreview(
                bytes: bytes,
                height: constraints.maxHeight,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: IconButton(
                  tooltip: VisionWeighingStrings.closeExpandedPhoto,
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppColors.onPrimary,
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightEstimateBadge extends StatelessWidget {
  const _WeightEstimateBadge({required this.capture, required this.weight});

  final VisionCapture capture;
  final double weight;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      color: AppColors.backgroundSecondaryLight,
      elevation: 0,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${weight.toStringAsFixed(1)} kg', style: AppTypography.bigTitle.copyWith(color: AppColors.primary)),
          const Text(VisionWeighingStrings.estimatedWeight, style: AppTypography.mediumEmphasis),
          _PredictionInterval(capture: capture),
        ],
      ),
    );
  }
}

class _PredictionInterval extends StatelessWidget {
  const _PredictionInterval({required this.capture});

  final VisionCapture capture;

  @override
  Widget build(BuildContext context) {
    final lower = capture.estimatedWeightLowerKg;
    final upper = capture.estimatedWeightUpperKg;
    if (lower == null || upper == null) {
      return const Text(VisionWeighingStrings.intervalUnavailable, style: AppTypography.formFieldHelper);
    }
    return Text(
      VisionWeighingStrings.weightRange(lower, upper),
      style: AppTypography.formFieldValueEmphasis,
    );
  }
}
