import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';

/// Resultado final mostrado despues de persistir la venta en SQLite.
class LivestockSaleSuccessView extends StatelessWidget {
  /// Crea la pantalla con la venta guardada y sus acciones de salida.
  const LivestockSaleSuccessView({
    required this.sale,
    required this.onRegisterAnotherSale,
    required this.onBackHome,
    super.key,
  });

  /// Venta confirmada localmente por el caso de uso.
  final LivestockSale sale;

  /// Inicia un flujo vacio para el mismo establecimiento.
  final VoidCallback onRegisterAnotherSale;

  /// Regresa a la pantalla principal.
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Spacer(),
            // Confirmacion visual principal. Reutiliza colores semanticos del
            // tema para no introducir una variante exclusiva de esta feature.
            const _SuccessIndicator(),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              LivestockSaleStrings.successTitle,
              key: Key('livestockSaleSuccessTitle'),
              style: AppTypography.successTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              LivestockSaleStrings.soldAnimalCount(sale.animalIds.length),
              key: const Key('livestockSaleSuccessAnimalCount'),
              style: AppTypography.successSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            // La confirmacion es local y definitiva para la experiencia del
            // usuario; la sincronizacion remota continuara desde la cola Brick.
            const Text(
              LivestockSaleStrings.successOfflineMessage,
              style: AppTypography.formFieldHelper,
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 2),
            // Las acciones se mantienen separadas: una reinicia todo el flujo
            // y la otra abandona la feature sin volver al resumen confirmado.
            AppFilledButton(
              key: const Key('livestockSaleRegisterAnotherButton'),
              label: LivestockSaleStrings.registerAnotherSale,
              icon: const Icon(Icons.add),
              onPressed: onRegisterAnotherSale,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppOutlinedButton(
              key: const Key('livestockSaleBackHomeButton'),
              label: LivestockSaleStrings.backHome,
              icon: const Icon(Icons.home_outlined),
              onPressed: onBackHome,
            ),
          ],
        ),
      ),
    );
  }
}

/// Circulo de confirmacion construido con tokens existentes del tema.
class _SuccessIndicator extends StatelessWidget {
  const _SuccessIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondaryLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_outline,
        color: AppColors.primary,
        size: 56,
      ),
    );
  }
}
