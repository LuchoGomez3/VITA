import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_header.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_header_clipper.dart';

/// Cabecera que pasa del perfil completo a una identidad compacta al desplazar.
class ProfileSliverHeader extends StatelessWidget {
  /// Crea el encabezado fijo con los datos de la sesión.
  const ProfileSliverHeader({
    required this.firstName,
    required this.lastName,
    super.key,
  });

  /// Nombre de la cuenta.
  final String firstName;

  /// Apellido de la cuenta.
  final String lastName;

  @override
  Widget build(BuildContext context) {
    final fullName = [firstName.trim(), lastName.trim()].where((name) => name.isNotEmpty).join(' ');
    final displayName = fullName.isEmpty ? ProfileStrings.usernameLabel : fullName;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        // Medimos los textos con el ancho y la escala reales para que los nombres
        // largos y la accesibilidad aumenten la altura, sin cortar el contenido.
        final width = constraints.crossAxisExtent - AppSpacing.lg * 2;
        final topInset = MediaQuery.paddingOf(context).top;
        final titleHeight = _textHeight(context, ProfileStrings.title, AppTypography.appBarTitle, width);
        final nameHeight = _textHeight(context, displayName, AppTypography.bigTitle, width);
        final subtitleHeight = _textHeight(
          context,
          ProfileStrings.accountSubtitle,
          AppTypography.formFieldValue,
          width,
        );
        final compactNameHeight = _textHeight(context, displayName, AppTypography.formFieldValueEmphasis, width);

        return SliverPersistentHeader(
          pinned: true,
          delegate: _ProfileHeaderDelegate(
            firstName: firstName,
            lastName: lastName,
            displayName: displayName,
            topInset: topInset,
            titleHeight: titleHeight,
            minExtent: topInset + AppSpacing.lg + AppSpacing.md + titleHeight + AppSpacing.xxs + compactNameHeight,
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
  double _textHeight(BuildContext context, String text, TextStyle style, double width) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.merge(style)),
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
    required this.displayName,
    required this.topInset,
    required this.titleHeight,
    required this.minExtent,
    required this.maxExtent,
  });

  final String firstName;
  final String lastName;
  final String displayName;
  final double topInset;
  final double titleHeight;

  @override
  final double minExtent;

  @override
  final double maxExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final collapseDistance = maxExtent - minExtent;
    final displacement = shrinkOffset.clamp(0.0, collapseDistance);
    final progress = displacement / collapseDistance;
    // La identidad se desplaza hasta el 80 % del recorrido. Solo en
    // el último tramo se transforma suavemente en la identidad compacta.
    final compactOpacity = const Interval(0.8, 1, curve: Curves.easeInOut).transform(progress);
    // El color cambia después de comprimir: esperamos 16 píxeles adicionales
    // y lo mezclamos durante los siguientes 64. Al subir se revierte igual.
    final colorProgress = Curves.easeInOut.transform(
      ((shrinkOffset - collapseDistance - AppSpacing.md) / (AppSpacing.xl * 2)).clamp(0.0, 1.0),
    );
    final foreground = Color.lerp(AppColors.onPrimary, AppColors.textPrimary, colorProgress);

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
                      Color.lerp(AppColors.primary, AppColors.backgroundTertiary, colorProgress)!,
                      Color.lerp(AppColors.passwordStrengthVeryStrong, AppColors.backgroundTertiary, colorProgress)!,
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
                          child: ProfileHeader(firstName: firstName, lastName: lastName, showTitle: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              ignoring: compactOpacity < 0.5,
              child: ExcludeSemantics(
                excluding: compactOpacity < 0.5,
                child: Opacity(
                  opacity: compactOpacity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      titleBottom + AppSpacing.xxs,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        displayName,
                        style: AppTypography.formFieldValueEmphasis.copyWith(color: foreground),
                      ),
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileHeaderDelegate oldDelegate) =>
      firstName != oldDelegate.firstName ||
      lastName != oldDelegate.lastName ||
      topInset != oldDelegate.topInset ||
      titleHeight != oldDelegate.titleHeight ||
      minExtent != oldDelegate.minExtent ||
      maxExtent != oldDelegate.maxExtent;
}
