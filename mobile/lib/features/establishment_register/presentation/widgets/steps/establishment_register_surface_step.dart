import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/static_map_preview.dart';

/// Vértices fijos del polígono decorativo, como fracción del tamaño disponible.
///
/// Réplica visual estática por decisión de producto (ver
/// .claude/specs/registrar-establecimiento.md): no hay dibujo interactivo de
/// polígono, los vértices son siempre estos mismos puntos.
const _mockPolygonVertices = [
  Offset(0.145, 0.120),
  Offset(0.737, 0.083),
  Offset(0.868, 0.326),
  Offset(0.842, 0.652),
  Offset(0.513, 0.783),
  Offset(0.184, 0.674),
  Offset(0.100, 0.391),
];

/// Paso 4 · Delimitar superficie del establecimiento (réplica visual estática).
class EstablishmentRegisterSurfaceStep extends StatelessWidget {
  /// Crea el paso de delimitación de superficie del establecimiento.
  const EstablishmentRegisterSurfaceStep({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = context.select(
      (RegisterEstablishmentBloc bloc) => bloc.state.draft,
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.backgroundSecondary,
          child: const Row(
            children: [
              Icon(Icons.layers_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  EstablishmentRegisterStrings.stepFourBannerText,
                  style: AppTypography.smallEmphasis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              StaticMapPreview(
                height: double.infinity,
                child: CustomPaint(
                  painter: _FieldBoundaryPainter(),
                  size: Size.infinite,
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _SurfaceStatsChip(
                  superficieHectareas: draft.superficieHectareas,
                  cantidadVertices: draft.cantidadVertices,
                ),
              ),
              const Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Column(
                  children: [
                    _ToolButton(
                      icon: Icons.undo,
                      tooltip: EstablishmentRegisterStrings.stepFourUndoTooltip,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _ToolButton(
                      icon: Icons.close,
                      tooltip: EstablishmentRegisterStrings.stepFourClearTooltip,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _ToolButton(
                      icon: Icons.layers_outlined,
                      tooltip: EstablishmentRegisterStrings.stepFourLayerTooltip,
                    ),
                  ],
                ),
              ),
              const Positioned(
                bottom: AppSpacing.md,
                left: 0,
                right: 0,
                child: _HintPill(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurfaceStatsChip extends StatelessWidget {
  const _SurfaceStatsChip({
    required this.superficieHectareas,
    required this.cantidadVertices,
  });

  final double superficieHectareas;
  final int cantidadVertices;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _SurfaceStat(
            label: EstablishmentRegisterStrings.stepFourSurfaceLabel,
            value: '${superficieHectareas.toStringAsFixed(0)} ha',
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: AppSpacing.sm),
          _SurfaceStat(
            label: EstablishmentRegisterStrings.stepFourVerticesLabel,
            value: '$cantidadVertices',
          ),
        ],
      ),
    );
  }
}

class _SurfaceStat extends StatelessWidget {
  const _SurfaceStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.formFieldHelper),
        Text(value, style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary)),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Text(
          EstablishmentRegisterStrings.stepFourHintText,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}

class _FieldBoundaryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = _mockPolygonVertices
        .map((fraction) => Offset(fraction.dx * size.width, fraction.dy * size.height))
        .toList();

    final path = Path()..addPolygon(points, true);

    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, strokePaint);

    for (var i = 0; i < points.length; i++) {
      canvas
        ..drawCircle(points[i], 9, Paint()..color = AppColors.onPrimary)
        ..drawCircle(
          points[i],
          9,
          Paint()
            ..color = AppColors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        points[i] - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
