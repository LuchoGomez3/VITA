import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/presentation/mock/paddock_mock.dart';

/// Réplica visual estática del establecimiento: un mosaico de potreros
/// coloreados por densidad de carga, sin SDK de mapas ni GPS real (mismo
/// criterio que el paso de superficie de "registrar establecimiento").
class FieldPaddockMosaic extends StatelessWidget {
  /// Crea el mosaico a partir de la lista de potreros mock.
  const FieldPaddockMosaic({required this.paddocks, super.key, this.rowSize = 3});

  /// Potreros a representar, en el orden en que se agrupan por fila.
  final List<Paddock> paddocks;

  /// Cantidad de potreros por fila del mosaico.
  final int rowSize;

  @override
  Widget build(BuildContext context) {
    final rows = <List<Paddock>>[
      for (var i = 0; i < paddocks.length; i += rowSize)
        paddocks.sublist(i, i + rowSize > paddocks.length ? paddocks.length : i + rowSize),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        children: [
          for (final row in rows)
            Expanded(
              child: Row(
                children: [
                  for (final paddock in row)
                    Expanded(
                      flex: paddock.hectares.round(),
                      child: _PaddockTile(paddock: paddock),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PaddockTile extends StatelessWidget {
  const _PaddockTile({required this.paddock});

  final Paddock paddock;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(color: paddock.density.color),
      padding: const EdgeInsets.all(AppSpacing.xs),
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paddock.name,
            style: AppTypography.smallEmphasis.copyWith(color: AppColors.onPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            paddock.isEmpty ? 'libre' : '${paddock.headCount} cab',
            style: AppTypography.smallEmphasis.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
