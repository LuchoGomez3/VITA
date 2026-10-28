import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/app_colors.dart';
import 'package:frontend_mayoral/core/theme/app_navigation_dimensions.dart';
import 'package:go_router/go_router.dart';

/// Página transparente que permite revelar la cámara sobre la pantalla anterior.
class CameraRevealPage extends CustomTransitionPage<void> {
  /// Crea la transición desde la posición compartida por ambos botones.
  CameraRevealPage({
    required GoRouterState state,
    required super.child,
  }) : super(
         key: state.pageKey,
         opaque: false,
         transitionDuration: Duration.zero,
         reverseTransitionDuration: Duration.zero,
         transitionsBuilder: _buildTransition,
       );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// Revela la cámara acelerando el círculo negro que esperaba al sensor.
class CameraOpeningReveal extends StatelessWidget {
  /// Crea el recorte que muestra progresivamente la vista real de cámara.
  const CameraOpeningReveal({
    required this.progress,
    required this.initialProgress,
    required this.visible,
    required this.child,
    super.key,
  });

  /// Avance rápido desde el tamaño alcanzado hasta cubrir la pantalla.
  final double progress;

  /// Avance que había alcanzado la espera lenta cuando terminó la carga.
  final double initialProgress;

  /// Evita mostrar la cámara mientras el círculo negro continúa esperando.
  final bool visible;

  /// Interfaz de cámara que se mantiene construida detrás del recorte.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = _buttonCenter(context, size);
        final boundedProgress = progress.clamp(0.0, 1.0);
        final curvedProgress = Curves.easeInCubic.transform(boundedProgress);
        final initialRadius = _loadingRadiusFor(
          initialProgress,
          size,
          center,
        );
        final radius = initialRadius + (_fullRadius(size, center) - initialRadius) * curvedProgress;

        return ClipPath(
          clipper: _CircularRevealClipper(
            center: center,
            radius: radius,
            visible: visible,
          ),
          child: child,
        );
      },
    );
  }
}

/// Círculo negro que crece lentamente mientras se inicializa el sensor.
class CameraLoadingReveal extends StatelessWidget {
  /// Crea la superficie de espera centrada sobre el botón de la navbar.
  const CameraLoadingReveal({required this.progress, super.key});

  /// Avance lento disponible hasta que la cámara informa que está lista.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = _buttonCenter(context, size);
        final radius = _loadingRadiusFor(progress, size, center);

        return IgnorePointer(
          child: CustomPaint(
            painter: _BlackRevealPainter(center: center, radius: radius),
          ),
        );
      },
    );
  }
}

/// Mantiene visible el botón de la navbar por encima de la apertura circular.
class CameraRevealButtonOverlay extends StatelessWidget {
  /// Crea una copia visual no interactiva del acceso central a la cámara.
  const CameraRevealButtonOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = _buttonCenter(context, constraints.biggest);
        const buttonSize = AppNavigationDimensions.centerButtonSize;

        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                left: center.dx - buttonSize / 2,
                top: center.dy - buttonSize / 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .33),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: SizedBox.square(
                    dimension: buttonSize,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/camera.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          AppColors.onPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Superficie verde que cubre la cámara antes de cerrar la ruta.
///
/// [progress] vale cero con el tamaño del botón y uno al cubrir la pantalla.
class CameraRevealSurface extends StatelessWidget {
  /// Dibuja la expansión en la misma posición que el botón central.
  const CameraRevealSurface({required this.progress, super.key});

  /// Progreso acotado visualmente al intervalo entre botón y pantalla completa.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = _buttonCenter(context, size);
        final radius = _radiusFor(progress, size, center);

        return IgnorePointer(
          child: CustomPaint(
            painter: _GreenRevealPainter(center: center, radius: radius),
          ),
        );
      },
    );
  }

  static double _radiusFor(double progress, Size size, Offset center) {
    const initialRadius = AppNavigationDimensions.centerButtonSize / 2;
    final boundedProgress = progress.clamp(0.0, 1.0);
    final fullRadius = _fullRadius(size, center);

    final curvedProgress = Curves.easeInOutCubic.transform(boundedProgress);
    return initialRadius + (fullRadius - initialRadius) * curvedProgress;
  }
}

Offset _buttonCenter(BuildContext context, Size size) {
  final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
  return Offset(
    size.width / 2,
    size.height - safeBottom - AppNavigationDimensions.bottomBarHeight,
  );
}

double _fullRadius(Size size, Offset center) {
  final horizontalDistance = math.max(center.dx, size.width - center.dx);
  final verticalDistance = math.max(center.dy, size.height - center.dy);
  return math.sqrt(
        horizontalDistance * horizontalDistance + verticalDistance * verticalDistance,
      ) +
      1;
}

double _loadingRadiusFor(double progress, Size size, Offset center) {
  const initialRadius = AppNavigationDimensions.centerButtonSize / 2;
  final waitingRadius = math.min(
    size.width * .8,
    _fullRadius(size, center) * .48,
  );
  final boundedProgress = progress.clamp(0.0, 1.0);
  return initialRadius + (waitingRadius - initialRadius) * boundedProgress;
}

class _CircularRevealClipper extends CustomClipper<Path> {
  const _CircularRevealClipper({
    required this.center,
    required this.radius,
    required this.visible,
  });

  final Offset center;
  final double radius;
  final bool visible;

  @override
  Path getClip(Size size) {
    if (!visible) return Path();
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircularRevealClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius || oldClipper.visible != visible;
  }
}

class _BlackRevealPainter extends CustomPainter {
  const _BlackRevealPainter({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(center, radius, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(_BlackRevealPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.radius != radius;
  }
}

class _GreenRevealPainter extends CustomPainter {
  const _GreenRevealPainter({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(center, radius, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_GreenRevealPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.radius != radius;
  }
}
