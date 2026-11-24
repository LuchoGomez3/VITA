import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';

/// Encabezado que resume las ventas al desplazar el historial.
class LivestockSaleHistoryHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Crea el encabezado con el resumen y el conteo local pendiente.
  const LivestockSaleHistoryHeader({
    required this.compact,
    required this.establishmentName,
    required this.totalCents,
    required this.recordCount,
    required this.pendingCount,
    super.key,
  });

  /// Activa el resumen compacto cuando la tarjeta superior sale de vista.
  final bool compact;

  /// Nombre del establecimiento asociado al historial.
  final String establishmentName;

  /// Total de las ventas disponibles localmente.
  final int totalCents;

  /// Cantidad de ventas disponibles localmente.
  final int recordCount;

  /// Cantidad de ventas que todavia no tienen confirmacion remota.
  final int pendingCount;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      title: LivestockSaleHistoryStrings.title,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            LivestockSaleHistoryStrings.title,
            style: AppTypography.appBarTitle,
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: compact ? 1 : 0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: _CompactSummary(
                establishmentName: establishmentName,
                totalCents: totalCents,
                recordCount: recordCount,
              ),
            ),
            builder: (context, progress, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  heightFactor: progress,
                  child: Opacity(opacity: progress, child: child),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        if (pendingCount > 0) AppSyncBadge(pendingCount: pendingCount),
      ],
    );
  }
}

class _CompactSummary extends StatelessWidget {
  const _CompactSummary({
    required this.establishmentName,
    required this.totalCents,
    required this.recordCount,
  });

  final String establishmentName;
  final int totalCents;
  final int recordCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('compact-sales-summary'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: const ShapeDecoration(
        color: AppColors.surface,
        shape: StadiumBorder(),
      ),
      child: Text(
        '$establishmentName · '
        '${ArgentineCurrencyInputFormatter.formatCents(totalCents)} · '
        '${LivestockSaleHistoryStrings.recordCount(recordCount)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.smallEmphasis,
      ),
    );
  }
}
