import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_header.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

/// Pantalla segura usada cuando se intenta abrir una ruta financiera sin rol.
class FinancialAccessDeniedPage extends StatelessWidget {
  /// Crea el estado de acceso denegado.
  const FinancialAccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: OperatingExpenseStrings.historyTitle),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Semantics(
            liveRegion: true,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, color: AppColors.error, size: 48),
                SizedBox(height: AppSpacing.md),
                Text(
                  OperatingExpenseStrings.accessDenied,
                  textAlign: TextAlign.center,
                  style: AppTypography.errorTitle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
