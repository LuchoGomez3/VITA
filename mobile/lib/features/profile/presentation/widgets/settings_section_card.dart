import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

/// Sección de ajustes: título + card con filas separadas por línea.
class SettingsSectionCard extends StatelessWidget {
  /// Crea la sección a partir de sus [rows].
  const SettingsSectionCard({
    required this.rows,
    super.key,
    this.title,
  });

  /// Título de la sección; sin título la card va sola (por ejemplo, debajo
  /// de una sección que ya tiene el suyo).
  final String? title;

  /// Filas mostradas dentro de la card, ya construidas (típicamente
  /// `SettingsRow`).
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final heading = title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heading != null) ...[
          // Mismo estilo que "Información personal" y "Establecimientos".
          Text(heading, style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.sm),
        ],
        AppSurfaceCard(
          // Las filas llevan su propio padding: así el divisor y el efecto
          // al tocar ocupan todo el ancho, como en el diseño.
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
