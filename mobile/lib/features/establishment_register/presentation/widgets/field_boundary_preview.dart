import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
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

/// Mapa decorativo con el polígono mock del establecimiento superpuesto.
///
/// Se usa en el paso "Delimitar superficie" (con vértices numerados) y en la
/// tarjeta de revisión (como miniatura, sin vértices).
class FieldBoundaryPreview extends StatelessWidget {
  /// Crea la vista de mapa con el polígono superpuesto.
  const FieldBoundaryPreview({
    super.key,
    this.height = 200,
    this.showVertexLabels = true,
  });

  /// Alto de la vista previa.
  final double height;

  /// Si se muestran los círculos numerados de cada vértice.
  final bool showVertexLabels;

  @override
  Widget build(BuildContext context) {
    return StaticMapPreview(
      height: height,
      child: CustomPaint(
        painter: _FieldBoundaryPainter(showVertexLabels: showVertexLabels),
        size: Size.infinite,
      ),
    );
  }
}

class _FieldBoundaryPainter extends CustomPainter {
  const _FieldBoundaryPainter({required this.showVertexLabels});

  final bool showVertexLabels;

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

    if (!showVertexLabels) {
      return;
    }

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
  bool shouldRepaint(covariant _FieldBoundaryPainter oldDelegate) {
    return oldDelegate.showVertexLabels != showVertexLabels;
  }
}
