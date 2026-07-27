import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Punto usado por [AppLineChart].
class AppLineChartPoint {
  /// Crea un punto para graficos de linea.
  const AppLineChartPoint({
    required this.x,
    required this.y,
  });

  /// Valor del eje horizontal.
  final double x;

  /// Valor del eje vertical.
  final double y;
}

/// Grafico de linea liviano para metricas de solo lectura.
class AppLineChart extends StatelessWidget {
  /// Crea un grafico de linea de solo lectura.
  const AppLineChart({
    required this.points,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.xLabels,
    required this.yLabelBuilder,
    super.key,
    this.height = 200,
    this.yInterval = 50,
  });

  /// Puntos renderizados en orden.
  final List<AppLineChartPoint> points;

  /// Valor minimo del eje horizontal.
  final double minX;

  /// Valor maximo del eje horizontal.
  final double maxX;

  /// Valor minimo del eje vertical.
  final double minY;

  /// Valor maximo del eje vertical.
  final double maxY;

  /// Etiquetas mapeadas por valor entero del eje X.
  final Map<int, String> xLabels;

  /// Construye la etiqueta visible del eje Y.
  final String Function(double value) yLabelBuilder;

  /// Alto del grafico.
  final double height;

  /// Intervalo de la grilla del eje Y.
  final double yInterval;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _AppLineChartPainter(
          points: points,
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          xLabels: xLabels,
          yLabelBuilder: yLabelBuilder,
          yInterval: yInterval,
        ),
      ),
    );
  }
}

class _AppLineChartPainter extends CustomPainter {
  const _AppLineChartPainter({
    required this.points,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.xLabels,
    required this.yLabelBuilder,
    required this.yInterval,
  });

  static const _leftAxisWidth = 48.0;
  static const _bottomAxisHeight = 28.0;
  static const _topPadding = 8.0;
  static const _rightPadding = 8.0;

  final List<AppLineChartPoint> points;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final Map<int, String> xLabels;
  final String Function(double value) yLabelBuilder;
  final double yInterval;

  @override
  void paint(Canvas canvas, Size size) {
    final chartRect = Rect.fromLTWH(
      _leftAxisWidth,
      _topPadding,
      size.width - _leftAxisWidth - _rightPadding,
      size.height - _topPadding - _bottomAxisHeight,
    );

    _drawGrid(canvas, chartRect);
    _drawAxisLabels(canvas, chartRect);
    _drawLine(canvas, chartRect);
  }

  void _drawGrid(Canvas canvas, Rect chartRect) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    for (var yValue = minY; yValue <= maxY; yValue += yInterval) {
      final y = _yForValue(yValue, chartRect);
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), paint);
    }
  }

  void _drawAxisLabels(Canvas canvas, Rect chartRect) {
    for (var yValue = minY; yValue <= maxY; yValue += yInterval) {
      _paintText(
        canvas,
        yLabelBuilder(yValue),
        Offset(0, _yForValue(yValue, chartRect) - 8),
        AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
      );
    }

    for (final entry in xLabels.entries) {
      final x = _xForValue(entry.key.toDouble(), chartRect);
      _paintText(
        canvas,
        entry.value,
        Offset(x - 10, chartRect.bottom + 8),
        AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
      );
    }
  }

  void _drawLine(Canvas canvas, Rect chartRect) {
    final offsets = points
        .map((point) => Offset(_xForValue(point.x, chartRect), _yForValue(point.y, chartRect)))
        .toList();

    if (offsets.isEmpty) {
      return;
    }

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final point in offsets.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(offsets.last.dx, chartRect.bottom)
      ..lineTo(offsets.first.dx, chartRect.bottom)
      ..close();

    canvas
      ..drawPath(
        fillPath,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.1)
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        linePath,
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

    final dotPaint = Paint()..color = AppColors.onPrimary;
    final dotBorderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final point in offsets) {
      canvas
        ..drawCircle(point, 4, dotPaint)
        ..drawCircle(point, 4, dotBorderPaint);
    }
  }

  double _xForValue(double value, Rect chartRect) {
    final range = maxX - minX;
    return chartRect.left + ((value - minX) / range) * chartRect.width;
  }

  double _yForValue(double value, Rect chartRect) {
    final range = maxY - minY;
    return chartRect.bottom - ((value - minY) / range) * chartRect.height;
  }

  void _paintText(Canvas canvas, String text, Offset offset, TextStyle style) {
    TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _AppLineChartPainter oldDelegate) {
    return points != oldDelegate.points ||
        minX != oldDelegate.minX ||
        maxX != oldDelegate.maxX ||
        minY != oldDelegate.minY ||
        maxY != oldDelegate.maxY ||
        xLabels != oldDelegate.xLabels ||
        yInterval != oldDelegate.yInterval;
  }
}
