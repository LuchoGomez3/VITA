import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Apariencia del aviso según el resultado de la operación.
enum AppToastTone {
  /// Algo falló o requiere atención.
  error,

  /// Información contextual.
  info,

  /// Confirmación de una acción.
  success,
}

/// Anfitrión de avisos transitorios por encima de las rutas de la app.
class AppToastHost extends StatefulWidget {
  /// Envuelve el navegador para conservar los avisos al cambiar de pantalla.
  const AppToastHost({required this.child, super.key});

  /// Contenido de la app.
  final Widget child;

  /// Muestra [message] y reemplaza el aviso anterior, si lo hay.
  static void show(BuildContext context, String message, {AppToastTone tone = AppToastTone.error}) {
    context.findAncestorStateOfType<_AppToastHostState>()?._show(message, tone);
  }

  @override
  State<AppToastHost> createState() => _AppToastHostState();
}

class _AppToastHostState extends State<AppToastHost> with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -0.35),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_animation);

  ({String message, AppToastTone tone})? _toast;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    )..addStatusListener(_onAnimationStatus);
  }

  void _show(String message, AppToastTone tone) {
    _timer?.cancel();
    _dismissing = false;
    setState(() => _toast = (message: message, tone: tone));
    _animation.forward(from: 0);
    _timer = Timer(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() {
    if (_toast == null || _dismissing) return;
    _timer?.cancel();
    _dismissing = true;
    _animation.reverse();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (_dismissing && status == AnimationStatus.dismissed) {
      setState(() => _toast = null);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toast = _toast;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (toast != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: Align(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: SlideTransition(
                      position: _slide,
                      child: FadeTransition(
                        opacity: _animation,
                        child: _ToastCard(message: toast.message, tone: toast.tone, onDismiss: _dismiss),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.message, required this.tone, required this.onDismiss});

  final String message;
  final AppToastTone tone;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final (accent, background, icon) = switch (tone) {
      AppToastTone.error => (AppColors.error, AppColors.errorContainer, Icons.error_outline_rounded),
      AppToastTone.info => (AppColors.textPrimary, AppColors.earTagBlue, Icons.info_outline_rounded),
      AppToastTone.success => (AppColors.primary, AppColors.backgroundSecondaryLight, Icons.check_circle_outline),
    };
    return Semantics(
      liveRegion: true,
      child: Material(
        color: background,
        elevation: 6,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onDismiss,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surface,
                  foregroundColor: accent,
                  child: Icon(icon, size: 19),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.4),
                    child: SingleChildScrollView(
                      child: Text(message, style: AppTypography.formFieldValue),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
