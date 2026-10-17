import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/widgets/app_header.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_form.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_success_view.dart';

/// Factory inyectable del estado de egresos.
typedef OperatingExpenseCubitFactory = OperatingExpenseCubit Function();

/// Pantalla de registro de egresos para el establecimiento activo.
class OperatingExpensesPage extends StatelessWidget {
  /// Crea la pantalla y asigna al provider el ciclo de vida del cubit.
  const OperatingExpensesPage({
    required this.createCubit,
    required this.establishmentName,
    super.key,
  });

  /// Construye el cubit con las dependencias resueltas por composition.
  final OperatingExpenseCubitFactory createCubit;

  /// Nombre del establecimiento seleccionado en el panel.
  final String establishmentName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..load(),
      child: _OperatingExpensesView(
        establishmentName: establishmentName,
      ),
    );
  }
}

class _OperatingExpensesView extends StatelessWidget {
  const _OperatingExpensesView({required this.establishmentName});

  final String establishmentName;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperatingExpenseCubit, OperatingExpenseState>(
      listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final savedExpense = state.savedExpense;
        final isSaving = state.saveState is Loading<void>;
        return Scaffold(
          appBar: savedExpense == null && !isSaving ? const AppHeader(title: OperatingExpenseStrings.title) : null,
          body: isSaving || savedExpense != null
              ? OperatingExpenseSubmissionView(
                  expense: savedExpense,
                  establishmentName: establishmentName,
                  onAddAnotherExpense: context.read<OperatingExpenseCubit>().startAnotherExpense,
                )
              : OperatingExpenseForm(establishmentName: establishmentName),
        );
      },
    );
  }
}
