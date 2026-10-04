import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/formatters/scaled_decimal_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/bloc/livestock_sale_bloc.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/utils/livestock_sale_form_amounts.dart';

/// Tercer paso del flujo: presenta todos los datos antes de confirmar la venta.
class LivestockSaleReviewStep extends StatefulWidget {
  /// Crea el resumen conectado al borrador compartido del flujo.
  const LivestockSaleReviewStep({super.key});

  @override
  State<LivestockSaleReviewStep> createState() => _LivestockSaleReviewStepState();
}

class _LivestockSaleReviewStepState extends State<LivestockSaleReviewStep> {
  static const _initialAnimalLimit = 10;
  bool _showAllAnimals = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivestockSaleBloc, LivestockSaleState>(
      buildWhen: (previous, current) {
        return previous.form != current.form || previous.selection != current.selection;
      },
      builder: (context, state) {
        final form = state.form;
        final animals = state.selection.animals;
        final totalCents = LivestockSaleFormAmounts.totalCents(form) ?? 0;

        // El resumen consume el mismo borrador que los pasos anteriores. No
        // genera datos nuevos ni consulta red para poder renderizarse offline.
        return ListView(
          key: const Key('livestockSaleReviewStep'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            // Bloque 1: identifica al comprador y la documentacion comercial.
            _BuyerSummary(form: form),
            const SizedBox(height: AppSpacing.lg),
            // Bloque 2: permite auditar que la tropa seleccionada sea correcta.
            _AnimalsSummary(
              animals: animals,
              showAll: _showAllAnimals,
              initialLimit: _initialAnimalLimit,
              onToggle: () {
                setState(() => _showAllAnimals = !_showAllAnimals);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Bloque 3: resume la modalidad y los importes de la operacion.
            _TotalsSummary(
              form: form,
              animalCount: animals.length,
              totalCents: totalCents,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Bloque 4: adapta el detalle a la condicion de cobro elegida.
            _PaymentSummary(form: form, totalCents: totalCents),
          ],
        );
      },
    );
  }
}

/// Presenta identidad, tipo y documento del comprador.
///
/// Persona y empresa comparten la tarjeta, pero la primera concatena nombre y
/// apellido mientras la segunda conserva la razon social completa.
class _BuyerSummary extends StatelessWidget {
  const _BuyerSummary({required this.form});

  final LivestockSaleFormDraft form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SummarySectionTitle(
          label: LivestockSaleStrings.summaryBuyerSection,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _buyerDisplayName(form),
                      key: const Key('livestockSaleReviewBuyerName'),
                      style: AppTypography.formFieldValueEmphasis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xxs,
                    runSpacing: AppSpacing.xxs,
                    alignment: WrapAlignment.end,
                    children: [
                      _SummaryChip(label: _buyerTypeLabel(form.buyerType)),
                      _SummaryChip(
                        label: form.isCompany ? LivestockSaleStrings.company : LivestockSaleStrings.person,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${LivestockSaleStrings.summaryDte} ${form.dteNumber}',
                style: AppTypography.monoValueEmphasis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                DateDisplayFormatter.shortDate(form.operationDate),
                style: AppTypography.formFieldHelper,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lista la tropa vendida sin reconstruir datos que no fueron leidos.
///
/// Se muestran diez animales inicialmente para mantener compacto el resumen.
/// El productor puede desplegar el resto antes de confirmar.
class _AnimalsSummary extends StatelessWidget {
  const _AnimalsSummary({
    required this.animals,
    required this.showAll,
    required this.initialLimit,
    required this.onToggle,
  });

  final List<LivestockSaleAnimal> animals;
  final bool showAll;
  final int initialLimit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    // `take` solo limita la presentacion; no modifica la seleccion del BLoC.
    final hasHiddenAnimals = animals.length > initialLimit;
    final visibleAnimals = showAll || !hasHiddenAnimals ? animals : animals.take(initialLimit).toList(growable: false);
    final remainingCount = animals.length - initialLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _SummarySectionTitle(
                label: LivestockSaleStrings.summaryAnimalsSection,
              ),
            ),
            _AnimalCountBadge(count: animals.length),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          padding: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, animal) in visibleAnimals.indexed) ...[
                _ReviewAnimalRow(animal: animal),
                if (index < visibleAnimals.length - 1) const Divider(height: 1, color: AppColors.border),
              ],
              if (hasHiddenAnimals) ...[
                if (visibleAnimals.isNotEmpty) const Divider(height: 1, color: AppColors.border),
                TextButton(
                  key: const Key('livestockSaleToggleAnimals'),
                  onPressed: onToggle,
                  child: Text(
                    showAll
                        ? LivestockSaleStrings.showFewerAnimals
                        : LivestockSaleStrings.showRemainingAnimals(
                            remainingCount,
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila compacta de un animal seleccionado.
///
/// No muestra peso ni importe individual porque la venta conoce unicamente el
/// peso comercial total ingresado por el usuario.
class _ReviewAnimalRow extends StatelessWidget {
  const _ReviewAnimalRow({required this.animal});

  final LivestockSaleAnimal animal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('livestockSaleReviewAnimal-${animal.id}'),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 52),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '#${_animalTag(animal)}',
              textAlign: TextAlign.center,
              style: AppTypography.smallEmphasis.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _animalCategory(animal),
                  style: AppTypography.formFieldValueEmphasis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  LivestockSaleStrings.animalRfid(animal.rfidTagNumber),
                  style: AppTypography.formFieldHelper,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Resume cantidades y forma de calcular el monto de la venta.
class _TotalsSummary extends StatelessWidget {
  const _TotalsSummary({
    required this.form,
    required this.animalCount,
    required this.totalCents,
  });

  final LivestockSaleFormDraft form;
  final int animalCount;
  final int totalCents;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SummarySectionTitle(
          label: LivestockSaleStrings.summaryTotalsSection,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          padding: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _SummaryRow(
                label: LivestockSaleStrings.animals,
                value: LivestockSaleStrings.headCount(animalCount),
              ),
              const Divider(height: 1, color: AppColors.border),
              _SummaryRow(
                label: LivestockSaleStrings.summarySaleType,
                value: _saleTypeLabel(form.saleType),
              ),
              // Peso y precio son exclusivos de la modalidad por kilo. Una
              // venta al bulto no debe recuperar valores descartados.
              if (form.saleType == LivestockSaleType.perKilogram) ...[
                const Divider(height: 1, color: AppColors.border),
                _SummaryRow(
                  label: LivestockSaleStrings.summaryTotalWeight,
                  value: '${_localizedDecimal(form.totalWeight)} kg',
                ),
                const Divider(height: 1, color: AppColors.border),
                _SummaryRow(
                  label: LivestockSaleStrings.summaryPricePerKilogram,
                  value:
                      r'$'
                      '${_localizedDecimal(form.pricePerKg)}/kg',
                ),
              ],
              const Divider(height: 1, color: AppColors.border),
              _TotalAmountRow(totalCents: totalCents),
            ],
          ),
        ),
      ],
    );
  }
}

/// Expone el efecto economico inmediato de la condicion de cobro.
///
/// Este bloque es de solo lectura. Para corregirlo se vuelve al formulario,
/// cuyo borrador sigue conservado por el BLoC.
class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.form, required this.totalCents});

  final LivestockSaleFormDraft form;
  final int totalCents;

  @override
  Widget build(BuildContext context) {
    // Total cobra todo, parcial usa el importe ingresado y pendiente no crea un
    // movimiento inicial.
    final initialPaymentCents = _initialPaymentCents(form, totalCents);
    final pendingCents = totalCents - initialPaymentCents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SummarySectionTitle(
          label: LivestockSaleStrings.summaryPaymentSection,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          padding: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _SummaryRow(
                label: LivestockSaleStrings.paymentStatus,
                value: _paymentConditionLabel(form.paymentCondition),
              ),
              if (form.paymentCondition != LivestockSalePaymentCondition.pending) ...[
                // El medio solo existe cuando se registra un cobro real.
                const Divider(height: 1, color: AppColors.border),
                _SummaryRow(
                  label: LivestockSaleStrings.paymentMethod,
                  value: _paymentMethodLabel(form.paymentMethod),
                ),
                const Divider(height: 1, color: AppColors.border),
                _HighlightedAmountRow(
                  key: const Key('livestockSaleReviewCollectedNow'),
                  label: LivestockSaleStrings.collectedNow,
                  amountCents: initialPaymentCents,
                  backgroundColor: AppColors.backgroundSecondaryLight,
                  foregroundColor: AppColors.primary,
                ),
              ],
              if (form.paymentCondition == LivestockSalePaymentCondition.partial) ...[
                // El saldo parcial resta el cobro inicial al monto total.
                const Divider(height: 1, color: AppColors.border),
                _HighlightedAmountRow(
                  key: const Key('livestockSaleReviewPendingBalance'),
                  label: LivestockSaleStrings.pendingBalance,
                  amountCents: pendingCents,
                  backgroundColor: AppColors.syncPendingContainer,
                  foregroundColor: AppColors.syncPending,
                ),
              ],
              if (form.paymentCondition == LivestockSalePaymentCondition.pending) ...[
                // Sin cobro inicial, todo el monto permanece pendiente.
                const Divider(height: 1, color: AppColors.border),
                _HighlightedAmountRow(
                  key: const Key('livestockSaleReviewPendingBalance'),
                  label: LivestockSaleStrings.pendingBalance,
                  amountCents: totalCents,
                  backgroundColor: AppColors.syncPendingContainer,
                  foregroundColor: AppColors.syncPending,
                ),
                const Divider(height: 1, color: AppColors.border),
                _HighlightedAmountRow(
                  label: LivestockSaleStrings.totalToCollect,
                  amountCents: totalCents,
                  backgroundColor: AppColors.syncPendingContainer,
                  foregroundColor: AppColors.syncPending,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Encabezado visual compartido por las secciones del resumen.
class _SummarySectionTitle extends StatelessWidget {
  const _SummarySectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.smallEmphasis);
  }
}

/// Etiqueta compacta para clasificaciones del comprador.
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: const ShapeDecoration(
        color: AppColors.termsBackground,
        shape: StadiumBorder(),
      ),
      child: Text(label, style: AppTypography.smallEmphasis),
    );
  }
}

/// Contador alineado con el encabezado de la tropa.
class _AnimalCountBadge extends StatelessWidget {
  const _AnimalCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: const ShapeDecoration(
        color: AppColors.primary,
        shape: StadiumBorder(),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: AppTypography.mapBadge,
      ),
    );
  }
}

/// Fila generica de etiqueta y valor usada en totales y cobro.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: AppTypography.formFieldHelper),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.formFieldValueEmphasis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Destaca el monto final respecto de las filas informativas anteriores.
class _TotalAmountRow extends StatelessWidget {
  const _TotalAmountRow({required this.totalCents});

  final int totalCents;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('livestockSaleReviewTotal'),
      color: AppColors.termsBackground,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              LivestockSaleStrings.summaryTotalAmount,
              style: AppTypography.formFieldValueEmphasis,
            ),
          ),
          Text(
            ArgentineCurrencyInputFormatter.formatCents(totalCents),
            style: AppTypography.successSubtitle.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Resalta importes cobrados o pendientes con colores semanticos existentes.
class _HighlightedAmountRow extends StatelessWidget {
  const _HighlightedAmountRow({
    required this.label,
    required this.amountCents,
    required this.backgroundColor,
    required this.foregroundColor,
    super.key,
  });

  final String label;
  final int amountCents;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.formFieldValueEmphasis.copyWith(
                color: foregroundColor,
              ),
            ),
          ),
          Text(
            ArgentineCurrencyInputFormatter.formatCents(amountCents),
            style: AppTypography.formFieldValueEmphasis.copyWith(
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Construye el nombre visible respetando persona o razon social.
String _buyerDisplayName(LivestockSaleFormDraft form) {
  if (form.isCompany) return form.buyerName;
  return '${form.buyerName} ${form.buyerLastName}'.trim();
}

/// Traduce el canal comercial estable al texto visible.
String _buyerTypeLabel(LivestockSaleBuyerType type) => switch (type) {
  LivestockSaleBuyerType.slaughterhouse => LivestockSaleStrings.slaughterhouse,
  LivestockSaleBuyerType.auction => LivestockSaleStrings.auction,
  LivestockSaleBuyerType.privateBuyer => LivestockSaleStrings.privateBuyer,
};

/// Traduce la modalidad comercial para la fila de totales.
String _saleTypeLabel(LivestockSaleType type) => switch (type) {
  LivestockSaleType.bulk => LivestockSaleStrings.bulkSale,
  LivestockSaleType.perKilogram => LivestockSaleStrings.perKilogramSale,
};

/// Describe la condicion de cobro con lenguaje orientado al resumen.
String _paymentConditionLabel(LivestockSalePaymentCondition condition) {
  return switch (condition) {
    LivestockSalePaymentCondition.total => LivestockSaleStrings.totalPaymentSummary,
    LivestockSalePaymentCondition.partial => LivestockSaleStrings.partialPaymentSummary,
    LivestockSalePaymentCondition.pending => LivestockSaleStrings.pendingPaymentSummary,
  };
}

/// Traduce el instrumento usado por el cobro inicial.
String _paymentMethodLabel(LivestockSalePaymentMethod method) {
  return switch (method) {
    LivestockSalePaymentMethod.cash => LivestockSaleStrings.cash,
    LivestockSalePaymentMethod.bankTransfer => LivestockSaleStrings.bankTransfer,
    LivestockSalePaymentMethod.check => LivestockSaleStrings.check,
    LivestockSalePaymentMethod.card => LivestockSaleStrings.card,
  };
}

/// Obtiene el monto efectivamente cobrado al confirmar la operacion.
int _initialPaymentCents(LivestockSaleFormDraft form, int totalCents) {
  return switch (form.paymentCondition) {
    LivestockSalePaymentCondition.total => totalCents,
    LivestockSalePaymentCondition.partial => ScaledDecimalFormatter.parse(form.amountToCollect, 2),
    LivestockSalePaymentCondition.pending => 0,
  };
}

/// Aplica el texto alternativo cuando SQLite no tiene categoria local.
String _animalCategory(LivestockSaleAnimal animal) {
  return animal.categoryName.trim().isEmpty ? LivestockSaleStrings.unavailableCategory : animal.categoryName;
}

/// Prioriza la caravana visual y usa un sufijo RFID como respaldo compacto.
String _animalTag(LivestockSaleAnimal animal) {
  final visualTag = animal.visualTag.trim();
  if (visualTag.isNotEmpty) return visualTag;
  final rfid = animal.rfidTagNumber;
  return rfid.length <= 4 ? rfid : rfid.substring(rfid.length - 4);
}

/// Localiza solo el separador visible sin alterar el valor guardado.
String _localizedDecimal(String value) => value.replaceAll('.', ',');
