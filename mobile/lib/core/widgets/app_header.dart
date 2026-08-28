import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Encabezado visual compartido por las secciones principales de la app.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Crea un encabezado redondeado con un titulo y una linea destacada opcional.
  const AppHeader({
    required this.title,
    super.key,
    this.headline,
    this.actions,
    this.titleWidget,
  });

  /// Titulo que identifica la seccion actual.
  final String title;

  /// Texto destacado opcional, utilizado por Inicio para mostrar el saludo.
  final String? headline;

  /// Acciones opcionales ubicadas en el extremo derecho.
  final List<Widget>? actions;

  /// Contenido opcional que reemplaza la presentación estándar del título.
  final Widget? titleWidget;

  @override
  Size get preferredSize => Size.fromHeight(headline == null ? 70 : 86);

  @override
  Widget build(BuildContext context) {
    final visibleHeadline = headline;

    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: AppColors.backgroundTertiary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.lg),
        ),
      ),
      title:
          titleWidget ??
          (visibleHeadline == null
              ? Text(title, style: AppTypography.appBarTitle)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visibleHeadline, style: AppTypography.appBarTitle),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(title, style: AppTypography.smallEmphasis),
                  ],
                )),
      actions: actions,
    );
  }
}
