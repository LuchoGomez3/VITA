import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

/// Sección de ajustes: título + card con filas separadas por línea.
class SettingsSectionCard extends StatelessWidget {
  /// Crea la sección a partir de sus [rows].
  const SettingsSectionCard({required this.title, required this.rows, super.key});

  /// Título de la sección.
  final String title;

  /// Filas mostradas dentro de la card, ya construidas (típicamente
  /// [SettingsRow]).
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
