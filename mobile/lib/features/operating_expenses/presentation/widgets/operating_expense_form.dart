import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/add_operating_expense_category_dialog.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_establishment_card.dart';

/// Formulario completo de alta local de un egreso operativo.
///
/// Este widget es propietario de los controladores y nodos de foco. El Cubit
/// conserva exclusivamente el estado de negocio y la coordinación del guardado.
class OperatingExpenseForm extends StatefulWidget {
  /// Crea el formulario para el establecimiento seleccionado.
  const OperatingExpenseForm({
    required this.establishmentName,
    super.key,
  });

  /// Nombre visible del establecimiento activo.
  final String establishmentName;

  @override
  State<OperatingExpenseForm> createState() => _OperatingExpenseFormState();
}

class _OperatingExpenseFormState extends State<OperatingExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _supplyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _receiptController = TextEditingController();
  final _amountFocus = FocusNode();
  final _categoryFocus = FocusNode();
  final _supplyFocus = FocusNode();

  @override
  void dispose() {
    _amountController.dispose();
    _supplyController.dispose();
    _descriptionController.dispose();
    _receiptController.dispose();
    _amountFocus.dispose();
    _categoryFocus.dispose();
    _supplyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OperatingExpenseCubit, OperatingExpenseState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    OperatingExpenseEstablishmentCard(
                      establishmentName: widget.establishmentName,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AmountField(
                      controller: _amountController,
                      focusNode: _amountFocus,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SupplyField(
                      controller: _supplyController,
                      focusNode: _supplyFocus,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ExpenseClassificationCard(
                      state: state,
                      focusNode: _categoryFocus,
                      onAddCategory: _showAddCategory,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ExpenseDetailsCard(
                      date: state.date,
                      descriptionController: _descriptionController,
                      receiptController: _receiptController,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
              _SaveExpenseFooter(
                isLoading: state.saveState is Loading<void>,
                onSave: _save,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _focusFirstInvalidField();
      return;
    }
    final saved = await context.read<OperatingExpenseCubit>().save(
      amountCents: parseArgentineCurrencyToCents(_amountController.text),
      supply: _supplyController.text,
      description: _descriptionController.text,
      receiptNumber: _receiptController.text,
    );
    if (!mounted || !saved) {
      return;
    }
  }

  void _focusFirstInvalidField() {
    if (parseArgentineCurrencyToCents(_amountController.text) <= 0) {
      _amountFocus.requestFocus();
      return;
    }
    if (_supplyController.text.trim().isEmpty) {
      _supplyFocus.requestFocus();
      return;
    }
    if (context.read<OperatingExpenseCubit>().state.selectedCategory == null) {
      _categoryFocus.requestFocus();
    }
  }

  Future<void> _showAddCategory() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const AddOperatingExpenseCategoryDialog(),
    );
    if (name == null || !mounted) {
      return;
    }
    await context.read<OperatingExpenseCubit>().addCategory(name);
  }
}

class _ExpenseClassificationCard extends StatelessWidget {
  const _ExpenseClassificationCard({
    required this.state,
    required this.focusNode,
    required this.onAddCategory,
  });

  final OperatingExpenseState state;
  final FocusNode focusNode;
  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _ExpenseTypeField(type: state.type),
          const SizedBox(height: AppSpacing.md),
          _CategoryField(
            state: state,
            focusNode: focusNode,
            onAddCategory: onAddCategory,
          ),
        ],
      ),
    );
  }
}

class _ExpenseDetailsCard extends StatelessWidget {
  const _ExpenseDetailsCard({
    required this.date,
    required this.descriptionController,
    required this.receiptController,
  });

  final DateTime date;
  final TextEditingController descriptionController;
  final TextEditingController receiptController;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _ExpenseDateField(date: date),
          const SizedBox(height: AppSpacing.md),
          _OptionalExpenseFields(
            descriptionController: descriptionController,
            receiptController: receiptController,
          ),
        ],
      ),
    );
  }
}

class _SaveExpenseFooter extends StatelessWidget {
  const _SaveExpenseFooter({
    required this.isLoading,
    required this.onSave,
  });

  final bool isLoading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.iconButtonBackground,
            offset: Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: AppFilledButton(
        label: OperatingExpenseStrings.save,
        isLoading: isLoading,
        onPressed: onSave,
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: const InputDecoration(
        labelText: OperatingExpenseStrings.amount,
        prefixText: r'$ ',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: const [ArgentineCurrencyInputFormatter()],
      validator: (value) =>
          parseArgentineCurrencyToCents(value ?? '') <= 0 ? OperatingExpenseValidationMessages.invalidAmount : null,
    );
  }
}

class _ExpenseTypeField extends StatelessWidget {
  const _ExpenseTypeField({required this.type});

  final OperatingExpenseType type;

  @override
  Widget build(BuildContext context) {
    return AppDropdownFormField<OperatingExpenseType>(
      title: OperatingExpenseStrings.type,
      hintText: OperatingExpenseStrings.type,
      initialValue: type,
      options: OperatingExpenseType.values.map((item) => AppDropdownOption(value: item, label: item.label)).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<OperatingExpenseCubit>().selectType(value);
        }
      },
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.state,
    required this.focusNode,
    required this.onAddCategory,
  });

  final OperatingExpenseState state;
  final FocusNode focusNode;
  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Focus(
          focusNode: focusNode,
          child: AppDropdownFormField<String>(
            key: ValueKey('${state.type.value}-${state.selectedCategory}'),
            title: OperatingExpenseStrings.category,
            hintText: OperatingExpenseStrings.category,
            initialValue: state.selectedCategory,
            options: state.categories
                .map(
                  (item) => AppDropdownOption(
                    value: item.value,
                    label: item.label,
                  ),
                )
                .toList(),
            validator: (value) =>
                value == null || value.isEmpty ? OperatingExpenseValidationMessages.requiredCategory : null,
            onChanged: context.read<OperatingExpenseCubit>().selectCategory,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onAddCategory,
            icon: const Icon(Icons.add),
            label: const Text(OperatingExpenseStrings.addCategory),
          ),
        ),
      ],
    );
  }
}

class _SupplyField extends StatelessWidget {
  const _SupplyField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: const InputDecoration(
        labelText: OperatingExpenseStrings.supply,
      ),
      textInputAction: TextInputAction.next,
      validator: (value) =>
          value == null || value.trim().isEmpty ? OperatingExpenseValidationMessages.requiredSupply : null,
    );
  }
}

class _ExpenseDateField extends StatelessWidget {
  const _ExpenseDateField({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return AppDateFormField(
      title: OperatingExpenseStrings.date,
      hintText: OperatingExpenseStrings.date,
      value: date,
      lastDate: DateUtils.dateOnly(DateTime.now()),
      onChanged: context.read<OperatingExpenseCubit>().selectDate,
      validator: (value) => value != null && DateUtils.dateOnly(value).isAfter(DateUtils.dateOnly(DateTime.now()))
          ? OperatingExpenseValidationMessages.futureDate
          : null,
    );
  }
}

class _OptionalExpenseFields extends StatelessWidget {
  const _OptionalExpenseFields({
    required this.descriptionController,
    required this.receiptController,
  });

  final TextEditingController descriptionController;
  final TextEditingController receiptController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: OperatingExpenseStrings.description,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: receiptController,
          decoration: const InputDecoration(
            labelText: OperatingExpenseStrings.receipt,
          ),
        ),
      ],
    );
  }
}

/// Convierte un importe argentino formateado a centavos enteros.
@visibleForTesting
int parseArgentineCurrencyToCents(String input) {
  final cleaned = input.trim().replaceAll(RegExp(r'\s'), '');
  if (cleaned.isEmpty) {
    return 0;
  }
  final comma = cleaned.lastIndexOf(',');
  final whole = (comma < 0 ? cleaned : cleaned.substring(0, comma)).replaceAll(RegExp('[^0-9]'), '');
  final fraction = comma < 0 ? '' : cleaned.substring(comma + 1).replaceAll(RegExp('[^0-9]'), '');
  final cents = fraction.padRight(2, '0').substring(0, 2);
  return (int.tryParse(whole) ?? 0) * 100 + (int.tryParse(cents) ?? 0);
}
