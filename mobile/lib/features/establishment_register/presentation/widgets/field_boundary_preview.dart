import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/static_map_preview.dart';

/// Miniatura del polígono dibujado en el paso 4, para la revisión.
///
/// Se pinta sin mapa ni tiles (funciona sin conexión): proyecta los vértices
/// a un plano local y los encuadra conservando la proporción del campo.
class FieldBoundaryPreview extends StatelessWidget {
  /// Crea la miniatura del polígono [points].
  const FieldBoundaryPreview({
    required this.points,
    super.key,
    this.height = 200,
  });

  /// Vértices del campo en orden de recorrido.
  final List<BoundaryPoint> points;

  /// Alto de la vista previa.
  final double height;

  @override
  Widget build(BuildContext context) {
    return StaticMapPreview(
      height: height,
      child: CustomPaint(
        painter: _FieldBoundaryPainter(points: points),
        size: Size.infinite,
      ),
    );
  }
}

class _FieldBoundaryPainter extends CustomPainter {
  const _FieldBoundaryPainter({required this.points});

  static const _padding = 16.0;

  final List<BoundaryPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 3) {
      return;
    }

    final projected = _project(points);
    final minX = projected.map((point) => point.dx).reduce(math.min);
    final maxX = projected.map((point) => point.dx).reduce(math.max);
    final minY = projected.map((point) => point.dy).reduce(math.min);
    final maxY = projected.map((point) => point.dy).reduce(math.max);
    final width = math.max(maxX - minX, double.minPositive);
    final height = math.max(maxY - minY, double.minPositive);

    final scale = math.min(
      (size.width - 2 * _padding) / width,
      (size.height - 2 * _padding) / height,
    );
    final offset = Offset(
      (size.width - width * scale) / 2,
      (size.height - height * scale) / 2,
    );
    final screenPoints = [
      for (final point in projected) Offset((point.dx - minX) * scale, (point.dy - minY) * scale) + offset,
    ];

    final path = Path()..addPolygon(screenPoints, true);
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        path,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
  }

  /// Proyección equirectangular local: corrige la longitud por el coseno de
  /// la latitud media y da vuelta el eje Y (el norte queda arriba).
  static List<Offset> _project(List<BoundaryPoint> points) {
    final meanLatitude = points.map((point) => point.latitud).reduce((a, b) => a + b) / points.length;
    final longitudeScale = math.cos(meanLatitude * math.pi / 180);
    return [
      for (final point in points) Offset(point.longitud * longitudeScale, -point.latitud),
    ];
  }

  @override
  bool shouldRepaint(covariant _FieldBoundaryPainter oldDelegate) => oldDelegate.points != points;
}
