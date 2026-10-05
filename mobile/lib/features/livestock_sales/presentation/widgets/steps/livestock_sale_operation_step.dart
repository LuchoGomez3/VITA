import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/formatters/name_input_formatter.dart';
import 'package:frontend_mayoral/core/formatters/scaled_decimal_input_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/bloc/livestock_sale_bloc.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/formatters/dte_input_formatter.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/utils/livestock_sale_form_amounts.dart';

/// Segundo paso del registro: comprador, precio y condiciones de cobro.
class LivestockSaleOperationStep extends StatefulWidget {
  /// Crea el formulario conectado al borrador compartido del flujo.
  const LivestockSaleOperationStep({super.key});

  @override
  State<LivestockSaleOperationStep> createState() => _LivestockSaleOperationStepState();
}

class _LivestockSaleOperationStepState extends State<LivestockSaleOperationStep> {
  // Los controladores viven durante todo el wizard porque IndexedStack conserva
  // este paso al avanzar al resumen y permite volver sin perder lo ingresado.
  late final TextEditingController _buyerNameController;
  late final TextEditingController _buyerLastNameController;
  late final TextEditingController _dteNumberController;
  late final TextEditingController _bulkTotalController;
  late final TextEditingController _totalWeightController;
  late final TextEditingController _pricePerKilogramController;
  late final TextEditingController _amountToCollectController;
  late final ScrollController _scrollController;
  late final FocusNode _buyerNameFocusNode;
  late final FocusNode _buyerLastNameFocusNode;
  late final FocusNode _dteFocusNode;
  late final FocusNode _bulkTotalFocusNode;
  late final FocusNode _totalWeightFocusNode;
  late final FocusNode _pricePerKilogramFocusNode;
  late final FocusNode _amountToCollectFocusNode;
  bool _showDteValidation = false;

  @override
  void initState() {
    super.initState();
    // El BLoC es la fuente de verdad; por eso los campos se hidratan desde su
    // borrador y no desde valores locales independientes.
    final form = context.read<LivestockSaleBloc>().state.form;
    _buyerNameController = TextEditingController(text: form.buyerName);
    _buyerLastNameController = TextEditingController(text: form.buyerLastName);
    _dteNumberController = TextEditingController(text: form.dteNumber);
    _bulkTotalController = TextEditingController(text: form.bulkTotalAmount);
    _totalWeightController = TextEditingController(text: form.totalWeight);
    _pricePerKilogramController = TextEditingController(text: form.pricePerKg);
    _amountToCollectController = TextEditingController(text: form.amountToCollect);
    _scrollController = ScrollController();
    _buyerNameFocusNode = FocusNode();
    _buyerLastNameFocusNode = FocusNode();
    _dteFocusNode = FocusNode()..addListener(_handleDteFocusChange);
    _bulkTotalFocusNode = FocusNode();
    _totalWeightFocusNode = FocusNode();
    _pricePerKilogramFocusNode = FocusNode();
    _amountToCollectFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _buyerNameController.dispose();
    _buyerLastNameController.dispose();
    _dteNumberController.dispose();
    _bulkTotalController.dispose();
    _totalWeightController.dispose();
    _pricePerKilogramController.dispose();
    _amountToCollectController.dispose();
    _scrollController.dispose();
    _buyerNameFocusNode.dispose();
    _buyerLastNameFocusNode.dispose();
    _dteFocusNode
      ..removeListener(_handleDteFocusChange)
      ..dispose();
    _bulkTotalFocusNode.dispose();
    _totalWeightFocusNode.dispose();
    _pricePerKilogramFocusNode.dispose();
    _amountToCollectFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LivestockSaleBloc, LivestockSaleState>(
      listenWhen: (previous, current) =>
          previous.stepError != current.stepError &&
          current.stepError != null &&
          current.currentStep == LivestockSaleStep.operation,
      listener: (context, state) {
        unawaited(_focusInvalidField(state.stepError?.reason));
      },
      child: BlocBuilder<LivestockSaleBloc, LivestockSaleState>(
        buildWhen: (previous, current) => previous.form != current.form || previous.stepError != current.stepError,
        builder: (context, state) {
          final form = state.form;
          final totalCents = LivestockSaleFormAmounts.totalCents(form);
          final isRequiredDteError = state.stepError?.reason == LivestockSaleFormField.dteNumber;
          final hasDteError =
              _showDteValidation ||
              isRequiredDteError ||
              state.stepError?.reason == LivestockSaleError.invalidDteNumber;
          return ListView(
            key: const Key('livestockSaleOperationStep'),
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Datos del comprador y del documento comercial asociado.
              const _SectionTitle(label: LivestockSaleStrings.buyerSection),
              const SizedBox(height: AppSpacing.sm),
              AppSegmentedFormField<LivestockSaleBuyerType>(
                title: LivestockSaleStrings.buyerType,
                value: form.buyerType,
                options: const [
                  AppSegmentedOption(
                    value: LivestockSaleBuyerType.slaughterhouse,
                    label: LivestockSaleStrings.slaughterhouse,
                  ),
                  AppSegmentedOption(
                    value: LivestockSaleBuyerType.auction,
                    label: LivestockSaleStrings.auction,
                  ),
                  AppSegmentedOption(
                    value: LivestockSaleBuyerType.privateBuyer,
                    label: LivestockSaleStrings.privateBuyer,
                  ),
                ],
                onChanged: (value) => _changeForm(
                  (current) => current.copyWith(buyerType: value),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSegmentedFormField<bool>(
                key: const Key('livestockSaleBuyerKind'),
                title: LivestockSaleStrings.buyerKind,
                value: form.isCompany,
                options: const [
                  AppSegmentedOption(
                    value: false,
                    label: LivestockSaleStrings.person,
                  ),
                  AppSegmentedOption(
                    value: true,
                    label: LivestockSaleStrings.company,
                  ),
                ],
                onChanged: _changeBuyerKind,
              ),
              const SizedBox(height: AppSpacing.md),
              if (form.isCompany)
                AppTextFormField(
                  key: const Key('livestockSaleBusinessName'),
                  controller: _buyerNameController,
                  focusNode: _buyerNameFocusNode,
                  title: LivestockSaleStrings.businessName,
                  hintText: LivestockSaleStrings.businessNameHint,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => _changeForm(
                    (current) => current.copyWith(buyerName: value),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        key: const Key('livestockSaleBuyerName'),
                        controller: _buyerNameController,
                        focusNode: _buyerNameFocusNode,
                        title: LivestockSaleStrings.buyerName,
                        hintText: LivestockSaleStrings.buyerNameHint,
                        inputFormatters: [NameInputFormatter()],
                        textInputAction: TextInputAction.next,
                        onChanged: (value) => _changeForm(
                          (current) => current.copyWith(buyerName: value),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppTextFormField(
                        key: const Key('livestockSaleBuyerLastName'),
                        controller: _buyerLastNameController,
                        focusNode: _buyerLastNameFocusNode,
                        title: LivestockSaleStrings.buyerLastName,
                        hintText: LivestockSaleStrings.buyerLastNameHint,
                        inputFormatters: [NameInputFormatter()],
                        textInputAction: TextInputAction.next,
                        onChanged: (value) => _changeForm(
                          (current) => current.copyWith(buyerLastName: value),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              AppTextFormField(
                key: const Key('livestockSaleDteNumber'),
                controller: _dteNumberController,
                focusNode: _dteFocusNode,
                title: LivestockSaleStrings.dteNumber,
                hintText: LivestockSaleStrings.dteNumberHint,
                validation: hasDteError ? AppFieldValidation.invalid : AppFieldValidation.neutral,
                validationMessage: hasDteError
                    ? isRequiredDteError
                          ? LivestockSaleStrings.missingRequiredFields
                          : LivestockSaleStrings.invalidDteNumberFormat
                    : null,
                keyboardType: TextInputType.text,
                inputFormatters: const [DteInputFormatter()],
                textInputAction: TextInputAction.next,
                onChanged: _changeDteNumber,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Fecha y modalidad que determinan que campos de precio se usan.
              const _SectionTitle(label: LivestockSaleStrings.operationSection),
              const SizedBox(height: AppSpacing.sm),
              AppDateFormField(
                value: form.operationDate,
                title: LivestockSaleStrings.operationDate,
                hintText: LivestockSaleStrings.dateHint,
                lastDate: DateUtils.dateOnly(DateTime.now()),
                onChanged: (value) => _changeForm(
                  (current) => current.copyWith(operationDate: value),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSegmentedFormField<LivestockSaleType>(
                key: const Key('livestockSaleType'),
                title: LivestockSaleStrings.saleType,
                value: form.saleType,
                options: const [
                  AppSegmentedOption(
                    value: LivestockSaleType.bulk,
                    label: LivestockSaleStrings.bulkSale,
                  ),
                  AppSegmentedOption(
                    value: LivestockSaleType.perKilogram,
                    label: LivestockSaleStrings.perKilogramSale,
                  ),
                ],
                onChanged: _changeSaleType,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Al bulto toma un total manual. Por kilo conserva peso y precio
              // exactos para calcular el total sin usar double.
              const _SectionTitle(label: LivestockSaleStrings.priceSection),
              const SizedBox(height: AppSpacing.sm),
              if (form.saleType == LivestockSaleType.bulk)
                AppTextFormField(
                  key: const Key('livestockSaleBulkTotal'),
                  controller: _bulkTotalController,
                  focusNode: _bulkTotalFocusNode,
                  title: LivestockSaleStrings.totalAmount,
                  prefixIcon: const _CurrencyPrefix(),
                  suffixIcon: const _InputUnit(LivestockSaleStrings.currency),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [ScaledDecimalInputFormatter(scale: 2)],
                  onChanged: (value) => _changeForm(
                    (current) => current.copyWith(bulkTotalAmount: value),
                  ),
                )
              else ...[
                AppTextFormField(
                  key: const Key('livestockSaleTotalWeight'),
                  controller: _totalWeightController,
                  focusNode: _totalWeightFocusNode,
                  title: LivestockSaleStrings.totalWeight,
                  suffixIcon: const _InputUnit(LivestockSaleStrings.kilograms),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [ScaledDecimalInputFormatter(scale: 3)],
                  onChanged: (value) => _changeForm(
                    (current) => current.copyWith(totalWeight: value),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextFormField(
                  key: const Key('livestockSalePricePerKilogram'),
                  controller: _pricePerKilogramController,
                  focusNode: _pricePerKilogramFocusNode,
                  title: LivestockSaleStrings.pricePerKilogram,
                  prefixIcon: const _CurrencyPrefix(),
                  suffixIcon: const _InputUnit(
                    LivestockSaleStrings.currencyPerKilogram,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [ScaledDecimalInputFormatter(scale: 6)],
                  onChanged: (value) => _changeForm(
                    (current) => current.copyWith(pricePerKg: value),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _CalculatedTotalCard(
                  totalCents: totalCents,
                  weight: form.totalWeight,
                  pricePerKilogram: form.pricePerKg,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              // La condicion define si nace un cobro inicial y si queda saldo.
              const _SectionTitle(
                label: LivestockSaleStrings.paymentStatusSection,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PaymentConditionSelector(
                value: form.paymentCondition,
                onChanged: _changePaymentCondition,
              ),
              if (form.paymentCondition == LivestockSalePaymentCondition.partial) ...[
                const SizedBox(height: AppSpacing.md),
                AppTextFormField(
                  key: const Key('livestockSaleAmountToCollect'),
                  controller: _amountToCollectController,
                  focusNode: _amountToCollectFocusNode,
                  title: LivestockSaleStrings.amountToCollectNow,
                  prefixIcon: const _CurrencyPrefix(),
                  suffixIcon: const _InputUnit(LivestockSaleStrings.currency),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [ScaledDecimalInputFormatter(scale: 2)],
                  onChanged: (value) => _changeForm(
                    (current) => current.copyWith(amountToCollect: value),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PendingBalanceCard(
                  pendingCents: LivestockSaleFormAmounts.pendingCents(
                    totalCents: totalCents,
                    amountToCollect: form.amountToCollect,
                  ),
                ),
              ],
              if (form.paymentCondition != LivestockSalePaymentCondition.pending) ...[
                // Una venta pendiente no registra medio de cobro hasta que exista
                // un movimiento de dinero real.
                const SizedBox(height: AppSpacing.lg),
                const _SectionTitle(
                  label: LivestockSaleStrings.paymentMethodSection,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PaymentMethodSelector(
                  value: form.paymentMethod,
                  onChanged: (value) => _changeForm(
                    (current) => current.copyWith(paymentMethod: value),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }

  void _changeForm(
    LivestockSaleFormDraft Function(LivestockSaleFormDraft current) update,
  ) {
    // Cada cambio reemplaza el borrador inmutable completo. Asi el BLoC puede
    // normalizar combinaciones incompatibles antes de emitir el nuevo estado.
    final bloc = context.read<LivestockSaleBloc>();
    bloc.add(LivestockSaleEvent.formChanged(update(bloc.state.form)));
  }

  void _changeBuyerKind(bool isCompany) {
    // El backend modela empresa con razon social y sin apellido.
    if (isCompany) {
      _buyerLastNameController.clear();
    }
    _changeForm(
      (current) => current.copyWith(
        isCompany: isCompany,
        buyerLastName: isCompany ? '' : current.buyerLastName,
      ),
    );
  }

  void _handleDteFocusChange() {
    if (_dteFocusNode.hasFocus || _dteNumberController.text.isEmpty) return;
    final isInvalid = !DteInputFormatter.isValid(_dteNumberController.text);
    if (isInvalid != _showDteValidation) {
      setState(() => _showDteValidation = isInvalid);
    }
  }

  void _changeDteNumber(String value) {
    // Una vez informado el error, se actualiza en vivo para retirarlo apenas
    // el productor completa correctamente el numero y su verificador.
    final bloc = context.read<LivestockSaleBloc>();
    final wasReported = _showDteValidation || bloc.state.stepError?.reason == LivestockSaleError.invalidDteNumber;
    final shouldShow = wasReported && !DteInputFormatter.isValid(value);
    if (shouldShow != _showDteValidation) {
      setState(() => _showDteValidation = shouldShow);
    }
    _changeForm((current) => current.copyWith(dteNumber: value));
  }

  Future<void> _focusInvalidField(Object? reason) async {
    final field = _fieldForReason(reason);
    if (field == null || !_scrollController.hasClients) return;
    final focusNode = _focusNodeFor(field);

    // Los primeros campos pueden haber sido desmontados por el ListView al
    // llegar al pie del formulario. Primero se aproxima su zona y luego se
    // centra el campo real cuando vuelve a estar disponible.
    if (focusNode.context == null) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final targetOffset = switch (field) {
        LivestockSaleFormField.buyerName ||
        LivestockSaleFormField.buyerLastName ||
        LivestockSaleFormField.dteNumber => 0.0,
        LivestockSaleFormField.bulkTotalAmount ||
        LivestockSaleFormField.totalWeight ||
        LivestockSaleFormField.pricePerKilogram => maxExtent * 0.5,
        LivestockSaleFormField.amountToCollect => maxExtent,
      };
      await _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted) return;
    focusNode.requestFocus();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final fieldContext = focusNode.context;
    if (fieldContext != null && fieldContext.mounted) {
      await Scrollable.ensureVisible(
        fieldContext,
        alignment: 0.25,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  LivestockSaleFormField? _fieldForReason(Object? reason) {
    if (reason is LivestockSaleFormField) return reason;
    return switch (reason) {
      LivestockSaleError.requiredBuyerName || LivestockSaleError.invalidBuyerName => LivestockSaleFormField.buyerName,
      LivestockSaleError.requiredBuyerLastName ||
      LivestockSaleError.invalidBuyerLastName => LivestockSaleFormField.buyerLastName,
      LivestockSaleError.invalidDteNumber => LivestockSaleFormField.dteNumber,
      LivestockSaleError.invalidTotalAmount =>
        context.read<LivestockSaleBloc>().state.form.saleType == LivestockSaleType.bulk
            ? LivestockSaleFormField.bulkTotalAmount
            : LivestockSaleFormField.pricePerKilogram,
      LivestockSaleError.invalidTotalWeight => LivestockSaleFormField.totalWeight,
      LivestockSaleError.invalidPricePerKg => LivestockSaleFormField.pricePerKilogram,
      LivestockSaleError.requiredInitialPayment ||
      LivestockSaleError.invalidInitialPaymentAmount ||
      LivestockSaleError.nonPositiveInitialPaymentAmount ||
      LivestockSaleError.initialPaymentNotLessThanTotal => LivestockSaleFormField.amountToCollect,
      _ => null,
    };
  }

  FocusNode _focusNodeFor(LivestockSaleFormField field) {
    return switch (field) {
      LivestockSaleFormField.buyerName => _buyerNameFocusNode,
      LivestockSaleFormField.buyerLastName => _buyerLastNameFocusNode,
      LivestockSaleFormField.dteNumber => _dteFocusNode,
      LivestockSaleFormField.bulkTotalAmount => _bulkTotalFocusNode,
      LivestockSaleFormField.totalWeight => _totalWeightFocusNode,
      LivestockSaleFormField.pricePerKilogram => _pricePerKilogramFocusNode,
      LivestockSaleFormField.amountToCollect => _amountToCollectFocusNode,
    };
  }

  void _changeSaleType(LivestockSaleType saleType) {
    // Limpiar los controladores evita que queden visibles valores que el BLoC
    // descarta al cambiar entre al bulto y por kilo.
    if (saleType == LivestockSaleType.bulk) {
      _totalWeightController.clear();
      _pricePerKilogramController.clear();
    } else {
      _bulkTotalController.clear();
    }
    _changeForm((current) => current.copyWith(saleType: saleType));
  }

  void _changePaymentCondition(LivestockSalePaymentCondition condition) {
    // Solo el cobro parcial requiere que el usuario informe un monto inicial.
    if (condition != LivestockSalePaymentCondition.partial) {
      _amountToCollectController.clear();
    }
    _changeForm(
      (current) => current.copyWith(paymentCondition: condition),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.smallEmphasis);
  }
}

class _InputUnit extends StatelessWidget {
  const _InputUnit(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: Text(label, style: AppTypography.formFieldHelper),
      ),
    );
  }
}

class _CurrencyPrefix extends StatelessWidget {
  const _CurrencyPrefix();

  @override
  Widget build(BuildContext context) {
    return const Center(
      widthFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(left: AppSpacing.sm),
        child: Text(
          LivestockSaleStrings.currencySymbol,
          style: AppTypography.formFieldHelper,
        ),
      ),
    );
  }
}

class _CalculatedTotalCard extends StatelessWidget {
  const _CalculatedTotalCard({
    required this.totalCents,
    required this.weight,
    required this.pricePerKilogram,
  });

  final int? totalCents;
  final String weight;
  final String pricePerKilogram;

  @override
  Widget build(BuildContext context) {
    final hasCalculation = totalCents != null;
    return AppSurfaceCard(
      key: const Key('livestockSaleCalculatedTotal'),
      color: AppColors.backgroundSecondaryLight,
      elevation: 0,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            LivestockSaleStrings.calculatedTotal,
            style: AppTypography.smallEmphasis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            hasCalculation
                ? ArgentineCurrencyInputFormatter.formatCents(totalCents!)
                : ArgentineCurrencyInputFormatter.formatCents(0),
            style: AppTypography.successTitle.copyWith(
              color: AppColors.primary,
            ),
          ),
          if (hasCalculation) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              LivestockSaleStrings.amountCalculation(
                weight,
                pricePerKilogram,
              ),
              style: AppTypography.formFieldHelper,
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentConditionSelector extends StatelessWidget {
  const _PaymentConditionSelector({
    required this.value,
    required this.onChanged,
  });

  final LivestockSalePaymentCondition value;
  final ValueChanged<LivestockSalePaymentCondition> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaymentConditionCard(
          value: LivestockSalePaymentCondition.total,
          groupValue: value,
          title: LivestockSaleStrings.totalPayment,
          subtitle: LivestockSaleStrings.totalPaymentDescription,
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpacing.xs),
        _PaymentConditionCard(
          value: LivestockSalePaymentCondition.partial,
          groupValue: value,
          title: LivestockSaleStrings.partialPayment,
          subtitle: LivestockSaleStrings.partialPaymentDescription,
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpacing.xs),
        _PaymentConditionCard(
          value: LivestockSalePaymentCondition.pending,
          groupValue: value,
          title: LivestockSaleStrings.pendingPayment,
          subtitle: LivestockSaleStrings.pendingPaymentDescription,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PaymentConditionCard extends StatelessWidget {
  const _PaymentConditionCard({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final LivestockSalePaymentCondition value;
  final LivestockSalePaymentCondition groupValue;
  final String title;
  final String subtitle;
  final ValueChanged<LivestockSalePaymentCondition> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      key: ValueKey('livestockSalePaymentCondition-${value.name}'),
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.backgroundSecondaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.border,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.formFieldValueEmphasis.copyWith(
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: AppTypography.formFieldHelper),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingBalanceCard extends StatelessWidget {
  const _PendingBalanceCard({required this.pendingCents});

  final int? pendingCents;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('livestockSalePendingBalance'),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.syncPendingContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.syncPending),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LivestockSaleStrings.pendingBalance,
            style: AppTypography.formFieldHelper.copyWith(
              color: AppColors.syncPending,
            ),
          ),
          Text(
            ArgentineCurrencyInputFormatter.formatCents(pendingCents ?? 0),
            style: AppTypography.formFieldValueEmphasis.copyWith(
              color: AppColors.syncPending,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({
    required this.value,
    required this.onChanged,
  });

  final LivestockSalePaymentMethod value;
  final ValueChanged<LivestockSalePaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.xs,
      crossAxisSpacing: AppSpacing.xs,
      childAspectRatio: 2.3,
      children: [
        _PaymentMethodCard(
          method: LivestockSalePaymentMethod.cash,
          selectedMethod: value,
          icon: Icons.payments_outlined,
          label: LivestockSaleStrings.cash,
          onChanged: onChanged,
        ),
        _PaymentMethodCard(
          method: LivestockSalePaymentMethod.bankTransfer,
          selectedMethod: value,
          icon: Icons.account_balance_outlined,
          label: LivestockSaleStrings.bankTransfer,
          onChanged: onChanged,
        ),
        _PaymentMethodCard(
          method: LivestockSalePaymentMethod.check,
          selectedMethod: value,
          icon: Icons.credit_score_outlined,
          label: LivestockSaleStrings.check,
          onChanged: onChanged,
        ),
        _PaymentMethodCard(
          method: LivestockSalePaymentMethod.card,
          selectedMethod: value,
          icon: Icons.credit_card_outlined,
          label: LivestockSaleStrings.card,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.selectedMethod,
    required this.icon,
    required this.label,
    required this.onChanged,
  });

  final LivestockSalePaymentMethod method;
  final LivestockSalePaymentMethod selectedMethod;
  final IconData icon;
  final String label;
  final ValueChanged<LivestockSalePaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = method == selectedMethod;
    return InkWell(
      key: ValueKey('livestockSalePaymentMethod-${method.name}'),
      onTap: () => onChanged(method),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.onPrimary : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.smallEmphasis.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
