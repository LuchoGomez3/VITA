import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/establishment_checklist_item.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/establishment_empty_state_header.dart';
import 'package:go_router/go_router.dart';

/// Pantalla mostrada a un Owner sin establecimientos registrados.
class EstablishmentEmptyStatePage extends StatelessWidget {
  /// Crea la pantalla de estado vacío del registro de establecimiento.
  const EstablishmentEmptyStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              EstablishmentEmptyStateHeader(onSignOut: () => _signOut(context)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: 132,
                        height: 132,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border, width: 1.5),
                        ),
                        child: const Icon(Icons.layers_outlined, size: 56, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        EstablishmentRegisterStrings.emptyStateTitle,
                        style: AppTypography.bigTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        EstablishmentRegisterStrings.emptyStateDescription,
                        style: AppTypography.pageBodyTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const EstablishmentChecklistItem(
                        order: 1,
                        label: EstablishmentRegisterStrings.emptyStateChecklistItem1Label,
                        subtitle: EstablishmentRegisterStrings.emptyStateChecklistItem1Sub,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const EstablishmentChecklistItem(
                        order: 2,
                        label: EstablishmentRegisterStrings.emptyStateChecklistItem2Label,
                        subtitle: EstablishmentRegisterStrings.emptyStateChecklistItem2Sub,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const EstablishmentChecklistItem(
                        order: 3,
                        label: EstablishmentRegisterStrings.emptyStateChecklistItem3Label,
                        subtitle: EstablishmentRegisterStrings.emptyStateChecklistItem3Sub,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const EstablishmentChecklistItem(
                        order: 4,
                        label: EstablishmentRegisterStrings.emptyStateChecklistItem4Label,
                        subtitle: EstablishmentRegisterStrings.emptyStateChecklistItem4Sub,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppFilledButton(
                label: EstablishmentRegisterStrings.emptyStateRegisterButton,
                icon: const Icon(Icons.add),
                onPressed: () => context.push(AppRoutes.establishmentRegisterStep1),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppOutlinedButton(
                label: EstablishmentRegisterStrings.emptyStateJoinExistingButton,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signOut(BuildContext context) {
    context.read<AuthSessionCubit>().signOut();
    context.go(AppRoutes.login);
  }
}
