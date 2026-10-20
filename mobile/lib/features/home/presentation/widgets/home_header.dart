import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_establishment_select.dart';

/// Encabezado de Inicio con el saludo y el selector de establecimiento.
class HomeHeader extends StatelessWidget {
  /// Crea el encabezado con sus callbacks.
  const HomeHeader({
    required this.greeting,
    required this.establishmentMenuController,
    required this.onSelected,
    required this.onCreateEstablishment,
    required this.onIdentifyAnimal,
    super.key,
  });

  /// Saludo mostrado como título principal.
  final String greeting;

  /// Controla el menú del selector para abrirlo desde el dashboard.
  final MenuController establishmentMenuController;

  /// Informa el establecimiento elegido; `null` representa todos.
  final ValueChanged<String?> onSelected;

  /// Abre el alta de un establecimiento nuevo.
  ///
  /// Es la única entrada al wizard después del registro de la cuenta: sin ella,
  /// quien sale del alta antes de terminar queda sin forma de crear uno.
  final VoidCallback onCreateEstablishment;

  /// Abre el flujo de identificacion RFID para el establecimiento activo.
  final VoidCallback onIdentifyAnimal;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundTertiary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: AppTypography.appBarTitle),
                    const SizedBox(height: AppSpacing.xxs),
                    BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
                      buildWhen: (previous, current) =>
                          previous.establishments != current.establishments ||
                          previous.selectedEstablishmentId != current.selectedEstablishmentId,
                      builder: (context, state) => HomeEstablishmentSelect(
                        controller: establishmentMenuController,
                        establishments: state.establishments,
                        selectedEstablishmentId: state.selectedEstablishmentId,
                        onSelected: onSelected,
                        onCreateEstablishment: onCreateEstablishment,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: HomeStrings.identifyAnimalTooltip,
                onPressed: onIdentifyAnimal,
                icon: const Icon(Icons.bluetooth),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
