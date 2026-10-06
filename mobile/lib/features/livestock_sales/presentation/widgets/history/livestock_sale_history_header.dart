import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_header.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';

/// Encabezado que compacta el resumen al desplazar el listado de ventas.
class LivestockSaleHistoryHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Conserva visibles establecimiento, total y cantidad al ocultar el resumen.
  const LivestockSaleHistoryHeader({
    required this.compact,
    required this.establishmentName,
    required this.totalCents,
    required this.recordCount,
    super.key,
  });

  /// Activa el resumen compacto cuando la tarjeta superior sale de vista.
  final bool compact;

  /// Establecimiento autorizado que identifica el historial.
  final String establishmentName;

  /// Total comercial mostrado también en la tarjeta de resumen.
  final int totalCents;

  /// Cantidad de ventas presentes en el listado.
  final int recordCount;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) => AppHeader(
    title: LivestockSaleHistoryStrings.title,
    titleWidget: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(LivestockSaleHistoryStrings.title, style: AppTypography.appBarTitle),
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
          builder: (context, progress, child) => ClipRect(
            child: Align(
              alignment: Alignment.topLeft,
              heightFactor: progress,
              child: Opacity(opacity: progress, child: child),
            ),
          ),
        ),
      ],
    ),
    actions: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: compact ? const _SalesBadge() : const SizedBox.shrink(),
      ),
    ],
  );
}

class _CompactSummary extends StatelessWidget {
  const _CompactSummary({required this.establishmentName, required this.totalCents, required this.recordCount});

  final String establishmentName;
  final int totalCents;
  final int recordCount;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('compact-sales-summary'),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
    decoration: const ShapeDecoration(color: AppColors.surface, shape: StadiumBorder()),
    child: Text(
      '$establishmentName · ${ArgentineCurrencyInputFormatter.formatCents(totalCents)} · '
      '${LivestockSaleHistoryStrings.recordCount(recordCount)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.smallEmphasis,
    ),
  );
}

class _SalesBadge extends StatelessWidget {
  const _SalesBadge();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: const ShapeDecoration(color: AppColors.primary, shape: StadiumBorder()),
      child: const Text(
        LivestockSaleHistoryStrings.sales,
        style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
