import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Fila de un registro en la pantalla de sincronización: ícono de estado,
/// tipo de registro, hora y una línea de detalle.
///
/// La comparten la cola, los rechazados y los enviados para que las tres
/// secciones se lean igual.
class SyncRecordTile extends StatelessWidget {
  /// Crea la fila.
  const SyncRecordTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.detail,
    this.detailColor = AppColors.textHint,
    this.borderColor = AppColors.border,
    super.key,
  });

  /// Ícono del estado.
  final IconData icon;

  /// Fondo del círculo del ícono.
  final Color iconBackground;

  /// Color del ícono.
  final Color iconColor;

  /// Tipo de registro.
  final String title;

  /// Momento que se muestra a la derecha.
  final DateTime time;

  /// Estado o motivo.
  final String detail;

  /// Color del detalle.
  final Color detailColor;

  /// Color del borde de la fila.
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxs),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: AppTypography.mediumEmphasis)),
                      Text(formatTime(time), style: AppTypography.monoValue.copyWith(color: AppColors.textHint)),
                    ],
                  ),
                  Text(detail, style: AppTypography.smallEmphasis.copyWith(color: detailColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `HH:mm` si es de hoy; `dd/MM HH:mm` si quedó de otro día.
  static String formatTime(DateTime value, {DateTime? now}) {
    final local = value.toLocal();
    final today = now ?? DateTime.now();
    String two(int number) => number.toString().padLeft(2, '0');
    final time = '${two(local.hour)}:${two(local.minute)}';
    final isToday = local.year == today.year && local.month == today.month && local.day == today.day;
    return isToday ? time : '${two(local.day)}/${two(local.month)} $time';
  }
}
