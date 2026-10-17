import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_header.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_header_clipper.dart';

/// Cabecera que pasa del perfil completo a una barra compacta con el título al
/// desplazar.
class ProfileSliverHeader extends StatelessWidget {
  /// Crea el encabezado fijo con los datos de la sesión.
  const ProfileSliverHeader({
    required this.firstName,
    required this.lastName,
    super.key,
    this.headerColor,
    this.avatar,
    this.onEdit,
  });

  /// Color elegido por el usuario; `null` es el verde original.
  final Color? headerColor;

  /// Foto del usuario; sin foto se muestran las iniciales.
  final ImageProvider? avatar;

  /// Abre la edición de la foto y el color (el lápiz de arriba a la derecha).
  final VoidCallback? onEdit;

  /// Nombre de la cuenta.
  final String firstName;

  /// Apellido de la cuenta.
  final String lastName;

  @override
  Widget build(BuildContext context) {
    final fullName = [
      firstName.trim(),
      lastName.trim(),
    ].where((name) => name.isNotEmpty).join(' ');
    final displayName = fullName.isEmpty ? ProfileStrings.usernameLabel : fullName;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        // Medimos los textos con el ancho y la escala reales para que los nombres
        // largos y la accesibilidad aumenten la altura, sin cortar el contenido.
        final width = constraints.crossAxisExtent - AppSpacing.lg * 2;
        final topInset = MediaQuery.paddingOf(context).top;
        final titleHeight = _textHeight(
          context,
          ProfileStrings.title,
          AppTypography.appBarTitle,
          width,
        );
        final nameHeight = _textHeight(
          context,
          displayName,
          AppTypography.bigTitle,
          width,
        );
        final subtitleHeight = _textHeight(
          context,
          ProfileStrings.accountSubtitle,
          AppTypography.formFieldValue,
          width,
        );

        return SliverPersistentHeader(
          pinned: true,
          delegate: _ProfileHeaderDelegate(
            firstName: firstName,
            lastName: lastName,
            headerColor: headerColor,
            avatar: avatar,
            onEdit: onEdit,
            topInset: topInset,
            titleHeight: titleHeight,
            // Compacta queda solo "Perfil": el nombre ya está en la cabecera
            // grande y repetirlo al scrollear le quitaba lugar al contenido.
            minExtent: topInset + AppSpacing.lg + titleHeight + AppSpacing.md,
            maxExtent:
                topInset +
                AppSpacing.lg * 3 +
                72 +
                AppSpacing.md +
                AppSpacing.xs +
                titleHeight +
                nameHeight +
                subtitleHeight,
          ),
        );
      },
    );
  }

  /// Usa las mismas reglas de salto de línea que los textos del encabezado.
  double _textHeight(
    BuildContext context,
    String text,
    TextStyle style,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }
}

/// Interpola la presentación según el desplazamiento y conserva el área segura.
class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ProfileHeaderDelegate({
    required this.firstName,
    required this.lastName,
    required this.headerColor,
    required this.avatar,
    required this.onEdit,
    required this.topInset,
    required this.titleHeight,
    required this.minExtent,
    required this.maxExtent,
  });

  final String firstName;
  final String lastName;
  final Color? headerColor;
  final ImageProvider? avatar;
  final VoidCallback? onEdit;
  final double topInset;
  final double titleHeight;

  @override
  final double minExtent;

  @override
  final double maxExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final collapseDistance = maxExtent - minExtent;
    final displacement = shrinkOffset.clamp(0.0, collapseDistance);
    final progress = displacement / collapseDistance;
    // La identidad se desplaza hasta el 80 % del recorrido. Solo en
    // el último tramo se transforma suavemente en la identidad compacta.
    final compactOpacity = const Interval(
      0.8,
      1,
      curve: Curves.easeInOut,
    ).transform(progress);
    // El color cambia después de comprimir: esperamos 16 píxeles adicionales
    // y lo mezclamos durante los siguientes 64. Al subir se revierte igual.
    // El encabezado solo sigue recibiendo desplazamiento hasta `maxExtent`:
    // con la barra compacta baja (sin área segura arriba) no quedan 80
    // píxeles, así que la mezcla se acorta para terminar siempre.
    final colorDelay = math.min(AppSpacing.md, minExtent / 4);
    final colorDistance = math.min(AppSpacing.xl * 2, minExtent - colorDelay);
    final colorProgress = Curves.easeInOut.transform(
      ((shrinkOffset - collapseDistance - colorDelay) / colorDistance).clamp(0.0, 1.0),
    );
    final background = headerColor ?? AppColors.primary;
    final backgroundEnd = headerColor == null ? AppColors.primaryDark : _darker(background);
    // Sobre un color claro el texto blanco no se lee: pasa a oscuro.
    final expandedForeground = background.computeLuminance() > 0.45 ? AppColors.textPrimary : AppColors.onPrimary;
    final foreground = Color.lerp(
      expandedForeground,
      AppColors.textPrimary,
      colorProgress,
    );
    // El lápiz solo está con la cabecera arriba de todo: se apaga en cuanto
    // el usuario empieza a scrollear.
    final editOpacity = 1 - (displacement / AppSpacing.lg).clamp(0.0, 1.0);

    final titleBottom = topInset + AppSpacing.lg + titleHeight;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.lg * compactOpacity),
      ),
      child: ClipPath(
        clipper: ProfileHeaderClipper(transition: compactOpacity),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // El fondo conserva sus dimensiones y posición al comprimir.
            // Solo la segunda etapa mezcla el degradado con el beige común.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: maxExtent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        background,
                        AppColors.backgroundTertiary,
                        colorProgress,
                      )!,
                      Color.lerp(
                        backgroundEnd,
                        AppColors.backgroundTertiary,
                        colorProgress,
                      )!,
                    ],
                  ),
                ),
              ),
            ),
            // Recortamos únicamente el contenido móvil debajo del título.
            // Así no hace falta una franja opaca para ocultarlo al subir.
            Positioned.fill(
              top: titleBottom,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      top: -displacement - titleBottom,
                      left: 0,
                      right: 0,
                      height: maxExtent,
                      child: ExcludeSemantics(
                        excluding: compactOpacity >= 0.5,
                        child: Opacity(
                          opacity: 1 - compactOpacity,
                          child: ProfileHeader(
                            firstName: firstName,
                            lastName: lastName,
                            showTitle: false,
                            foreground: expandedForeground,
                            avatar: avatar,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: topInset + AppSpacing.lg,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Text(
                ProfileStrings.title,
                style: AppTypography.appBarTitle.copyWith(color: foreground),
              ),
            ),
            if (onEdit != null && editOpacity > 0)
              Positioned(
                // Centrado verticalmente con el título "Perfil".
                top: topInset + AppSpacing.lg + titleHeight / 2 - _editButtonSize / 2,
                right: AppSpacing.md,
                child: IgnorePointer(
                  ignoring: editOpacity < 1,
                  child: Opacity(
                    opacity: editOpacity,
                    child: _EditButton(color: expandedForeground, onPressed: onEdit!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const _editButtonSize = 40.0;

  /// Final del degradado: el mismo tono un poco más oscuro, como el verde
  /// original pasa de `primary` a `primaryDark`.
  static Color _darker(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRebuild(_ProfileHeaderDelegate oldDelegate) =>
      headerColor != oldDelegate.headerColor ||
      avatar != oldDelegate.avatar ||
      onEdit != oldDelegate.onEdit ||
      firstName != oldDelegate.firstName ||
      lastName != oldDelegate.lastName ||
      topInset != oldDelegate.topInset ||
      titleHeight != oldDelegate.titleHeight ||
      minExtent != oldDelegate.minExtent ||
      maxExtent != oldDelegate.maxExtent;
}

/// Lápiz redondo para editar la foto y el color.
class _EditButton extends StatelessWidget {
  const _EditButton({required this.color, required this.onPressed});

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: ProfileStrings.editAppearanceTooltip,
        constraints: const BoxConstraints.tightFor(
          width: _ProfileHeaderDelegate._editButtonSize,
          height: _ProfileHeaderDelegate._editButtonSize,
        ),
        padding: EdgeInsets.zero,
        iconSize: 20,
        color: color,
        icon: const Icon(Icons.edit_outlined),
        onPressed: onPressed,
      ),
    );
  }
}
