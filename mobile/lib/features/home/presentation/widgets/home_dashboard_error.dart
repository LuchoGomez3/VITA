import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_asset_icon.dart';

/// Informa un fallo al calcular el tablero y permite volver a intentarlo.
class HomeDashboardError extends StatelessWidget {
  /// Crea el estado de error con el mensaje recibido desde el cubit.
  const HomeDashboardError({required this.message, super.key});

  /// Descripción legible del problema ocurrido.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HomeAssetIcon(
              assetPath: 'assets/icons/error.svg',
              color: AppColors.error,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            AppFilledButton(
              label: HomeStrings.retry,
              onPressed: context.read<HomeDashboardCubit>().load,
            ),
          ],
        ),
      ),
    );
  }
}
