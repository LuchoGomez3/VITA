import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/app/layout/main_layout_strings.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Cascaron principal que mantiene visibles y aisladas las ramas de navegacion.
///
/// [StatefulNavigationShell] conserva un `Navigator` independiente por pestaña,
/// por lo que cada rama mantiene su historial y su posicion de scroll.
class MainLayoutPage extends StatefulWidget {
  /// Crea el layout que envuelve las cuatro ramas principales de la app.
  const MainLayoutPage({
    required this.navigationShell,
    super.key,
  });

  /// Controlador y contenido de las ramas creado por `StatefulShellRoute`.
  final StatefulNavigationShell navigationShell;

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> with SingleTickerProviderStateMixin {
  // Altura exterior de la barra; modificar este valor cambia su grosor real.
  static const double _navigationBarHeight = 65;

  final _imagePicker = ImagePicker();
  late final AnimationController _indicatorController;
  late int _indicatorFromIndex;
  late int _indicatorToIndex;

  @override
  void initState() {
    super.initState();
    _indicatorFromIndex = widget.navigationShell.currentIndex;
    _indicatorToIndex = widget.navigationShell.currentIndex;
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant MainLayoutPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentIndex = widget.navigationShell.currentIndex;

    if (currentIndex == _indicatorToIndex) {
      return;
    }

    _indicatorFromIndex = _indicatorToIndex;
    _indicatorToIndex = currentIndex;
    _indicatorController.forward(from: 0);
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      floatingActionButton: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.33),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: FloatingActionButton(
          tooltip: MainLayoutStrings.openCamera,
          onPressed: _openCamera,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          shape: const CircleBorder(),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.22),
              blurRadius: 18,
              spreadRadius: -2,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: BottomAppBar(
          height: _navigationBarHeight,
          color: AppColors.surface.withValues(alpha: 0.88),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: const CircularNotchedRectangle(),
          notchMargin: AppSpacing.xs,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: _navigationBarHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NavigationIndicatorPainter(
                        animation: _indicatorController,
                        fromIndex: _indicatorFromIndex,
                        toIndex: _indicatorToIndex,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _NavigationDestinationButton(
                        assetPath: 'assets/icons/home.svg',
                        label: MainLayoutStrings.dashboard,
                        selected: widget.navigationShell.currentIndex == 0,
                        onTap: () => _selectDestination(0),
                      ),
                      _NavigationDestinationButton(
                        assetPath: 'assets/icons/cow.svg',
                        label: MainLayoutStrings.livestock,
                        selected: widget.navigationShell.currentIndex == 1,
                        onTap: () => _selectDestination(1),
                      ),
                      const SizedBox(
                        width: 76,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Text(
                              MainLayoutStrings.artificialIntelligenceWeighing,
                              style: AppTypography.mediumEmphasis,
                            ),
                          ),
                        ),
                      ),
                      _NavigationDestinationButton(
                        assetPath: 'assets/icons/draft.svg',
                        label: MainLayoutStrings.procedures,
                        selected: widget.navigationShell.currentIndex == 2,
                        onTap: () => _selectDestination(2),
                      ),
                      _NavigationDestinationButton(
                        assetPath: 'assets/icons/person.svg',
                        label: MainLayoutStrings.profile,
                        selected: widget.navigationShell.currentIndex == 3,
                        onTap: () => _selectDestination(3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectDestination(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Future<void> _openCamera() async {
    try {
      await _imagePicker.pickImage(
        source: ImageSource.camera,
        requestFullMetadata: false,
      );
    } on PlatformException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(MainLayoutStrings.cameraError)),
        );
    }
  }
}

class _NavigationDestinationButton extends StatelessWidget {
  const _NavigationDestinationButton({
    required this.assetPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textHint;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assetPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.mediumEmphasis.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationIndicatorPainter extends CustomPainter {
  _NavigationIndicatorPainter({
    required Animation<double> animation,
    required this.fromIndex,
    required this.toIndex,
  }) : _animation = animation,
       super(repaint: animation);

  static const double _centerSpace = 76;
  static const double _notchRadius = 36;
  static const double _indicatorLength = 28;

  final Animation<double> _animation;
  final int fromIndex;
  final int toIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final route = _buildRoute(size);
    final metric = route.computeMetrics().first;
    final progress = Curves.easeInOutCubic.transform(_animation.value);
    final startDistance = _distanceForIndex(fromIndex, size.width);
    final endDistance = _distanceForIndex(toIndex, size.width);
    final centerDistance = startDistance + ((endDistance - startDistance) * progress);
    final indicatorStart = math.max(0, centerDistance - (_indicatorLength / 2)).toDouble();
    final indicatorEnd = math.min(metric.length, centerDistance + (_indicatorLength / 2));
    final indicator = metric.extractPath(indicatorStart, indicatorEnd);
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(indicator, paint);
  }

  Path _buildRoute(Size size) {
    final center = size.width / 2;

    return Path()
      ..moveTo(0, 0)
      ..lineTo(center - _notchRadius, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset(center, 0), radius: _notchRadius),
        math.pi,
        -math.pi,
        false,
      )
      ..lineTo(size.width, 0);
  }

  double _distanceForIndex(int index, double width) {
    final itemWidth = (width - _centerSpace) / 4;
    final itemCenter = switch (index) {
      0 => itemWidth / 2,
      1 => itemWidth * 1.5,
      2 => (itemWidth * 2.5) + _centerSpace,
      _ => (itemWidth * 3.5) + _centerSpace,
    };
    const notchExtraDistance = (math.pi * _notchRadius) - (_notchRadius * 2);

    return index < 2 ? itemCenter : itemCenter + notchExtraDistance;
  }

  @override
  bool shouldRepaint(covariant _NavigationIndicatorPainter oldDelegate) {
    return oldDelegate.fromIndex != fromIndex || oldDelegate.toIndex != toIndex;
  }
}
