import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/formatters/scaled_decimal_formatter.dart';
import 'package:frontend_mayoral/core/formatters/scaled_decimal_input_formatter.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_detail_cubit.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_detail_strings.dart';

/// Factory del estado local del detalle de venta.
typedef LivestockSaleDetailCubitFactory = LivestockSaleDetailCubit Function();

/// Consulta de solo lectura de una venta guardada en el dispositivo.
class LivestockSaleDetailPage extends StatelessWidget {
  /// Crea la pantalla y conserva la navegacion fuera de presentacion.
  const LivestockSaleDetailPage({
    required this.createCubit,
    required this.onBackPressed,
    super.key,
  });

  /// Construye el Cubit con el establecimiento y UUID autorizados.
  final LivestockSaleDetailCubitFactory createCubit;

  /// Regresa al historial conservado en la pila.
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..load(),
      child: Scaffold(
        appBar: AppHeader(
          title: LivestockSaleDetailStrings.title,
          onBackPressed: onBackPressed,
        ),
        body: BlocBuilder<LivestockSaleDetailCubit, LivestockSaleDetailState>(
          builder: (context, state) {
            return switch (state) {
              Data<LivestockSaleDetailData>(:final data) => _SaleDetail(data: data),
              ResultError<LivestockSaleDetailData>() => const _DetailError(),
              _ => const Center(child: CircularProgressIndicator()),
            };
          },
        ),
      ),
    );
  }
}

class _SaleDetail extends StatelessWidget {
  const _SaleDetail({required this.data});

  final LivestockSaleDetailData data;

  @override
  Widget build(BuildContext context) {
    final sale = data.sale;
    final collectedCents = sale.collectedAmountCents ?? sale.initialPayment?.amountCents ?? 0;
    final pendingCents = sale.pendingAmountCents ?? sale.totalAmountCents - collectedCents;
    final buyerName = '${sale.buyerName} ${sale.buyerLastName ?? ''}'.trim();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _DetailSection(
          title: LivestockSaleDetailStrings.operation,
          children: [
            _DetailRow(
              label: LivestockSaleDetailStrings.operationDate,
              value: DateDisplayFormatter.shortDate(sale.operationDate),
            ),
            _DetailRow(
              label: LivestockSaleDetailStrings.buyerType,
              value: _buyerTypeLabel(sale.buyerType),
            ),
            _DetailRow(
              label: LivestockSaleDetailStrings.buyer,
              value: buyerName,
            ),
            _DetailRow(
              label: LivestockSaleDetailStrings.dte,
              value: sale.dteNumber,
            ),
            _DetailRow(
              label: LivestockSaleDetailStrings.saleType,
              value: _saleTypeLabel(sale.saleType),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _DetailSection(
          title: LivestockSaleDetailStrings.traceability,
          children: [
            _DetailRow(
              label: LivestockSaleDetailStrings.registeredAt,
              value: DateDisplayFormatter.shortDateTime(
                sale.createdAt.toLocal(),
              ),
            ),
            _DetailRow(
              label: LivestockSaleDetailStrings.registeredBy,
              value: _registeredBy(sale),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _DetailSection(
          title: LivestockSaleDetailStrings.amounts,
          children: [
            _DetailRow(
              label: LivestockSaleDetailStrings.total,
              value: ArgentineCurrencyInputFormatter.formatCents(
                sale.totalAmountCents,
              ),
              emphasize: true,
            ),
            if (sale.saleType == LivestockSaleType.perKilogram) ...[
              _DetailRow(
                label: LivestockSaleDetailStrings.totalWeight,
                value: '${_localizedScaled(sale.totalWeightGrams!, 3)} kg',
              ),
              _DetailRow(
                label: LivestockSaleDetailStrings.pricePerKilogram,
                value:
                    r'$ '
                    '${_localizedScaled(sale.pricePerKgMicros!, 6)}/kg',
              ),
            ],
            _DetailRow(
              label: LivestockSaleDetailStrings.paymentStatus,
              value: _paymentLabel(sale.paymentCondition),
            ),
            _DetailRow(
              label: LivestockSaleDetailStrings.collected,
              value: ArgentineCurrencyInputFormatter.formatCents(
                collectedCents,
              ),
            ),
            _DetailRow(
              label: LivestockSaleDetailStrings.pending,
              value: ArgentineCurrencyInputFormatter.formatCents(
                pendingCents,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                LivestockSaleDetailStrings.informationalAmountsNotice,
                style: AppTypography.formFieldHelper,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _DetailSection(
          title: LivestockSaleDetailStrings.animals,
          children: [
            _DetailRow(
              label: LivestockSaleDetailStrings.animals,
              value: LivestockSaleDetailStrings.animalCount(
                sale.animalIds.length,
              ),
            ),
            for (var index = 0; index < data.animals.length; index++) ...[
              const Divider(height: AppSpacing.lg),
              _AnimalRow(animal: data.animals[index]),
            ],
            if (data.unavailableAnimalCount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              _UnavailableAnimalsNotice(
                count: data.unavailableAnimalCount,
                readFailed: data.animalsReadFailed,
              ),
            ],
          ],
        ),
        if (sale.observations case final observations? when observations.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _DetailSection(
            title: LivestockSaleDetailStrings.observations,
            children: [Text(observations)],
          ),
        ],
      ],
    );
  }

  String _buyerTypeLabel(LivestockSaleBuyerType type) {
    return switch (type) {
      LivestockSaleBuyerType.slaughterhouse => LivestockSaleDetailStrings.slaughterhouse,
      LivestockSaleBuyerType.auction => LivestockSaleDetailStrings.auction,
      LivestockSaleBuyerType.privateBuyer => LivestockSaleDetailStrings.privateBuyer,
    };
  }

  String _saleTypeLabel(LivestockSaleType type) {
    return switch (type) {
      LivestockSaleType.bulk => LivestockSaleDetailStrings.bulkSale,
      LivestockSaleType.perKilogram => LivestockSaleDetailStrings.perKilogramSale,
    };
  }

  String _paymentLabel(LivestockSalePaymentCondition condition) {
    return switch (condition) {
      LivestockSalePaymentCondition.pending => LivestockSaleDetailStrings.paymentPending,
      LivestockSalePaymentCondition.partial => LivestockSaleDetailStrings.paymentPartial,
      LivestockSalePaymentCondition.total => LivestockSaleDetailStrings.paymentTotal,
    };
  }

  String _registeredBy(LivestockSale sale) {
    final name = sale.registeredByName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final id = sale.registeredById?.trim();
    return id == null || id.isEmpty ? LivestockSaleDetailStrings.unavailableRegisteredBy : id;
  }

  String _localizedScaled(int value, int scale) {
    final canonical = ScaledDecimalFormatter.format(
      value,
      scale,
    ).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return ScaledDecimalInputFormatter.formatGroupedCanonical(
      canonical,
      scale: scale,
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: AppTypography.formFieldHelper),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: emphasize ? AppTypography.successTitle : AppTypography.mediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalRow extends StatelessWidget {
  const _AnimalRow({required this.animal});

  final LivestockSaleAnimal animal;

  @override
  Widget build(BuildContext context) {
    final category = animal.categoryName.trim().isEmpty
        ? LivestockSaleDetailStrings.unavailableCategory
        : animal.categoryName;
    final lot = animal.lotName.trim().isEmpty ? LivestockSaleDetailStrings.unavailableLot : animal.lotName;
    final visualTag = animal.visualTag.trim().isEmpty
        ? LivestockSaleDetailStrings.unavailableVisualTag
        : animal.visualTag;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppEarTagBadge(visualTag: visualTag),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category, style: AppTypography.mediumEmphasis),
              const SizedBox(height: AppSpacing.xxxs),
              Text(
                '${LivestockSaleDetailStrings.rfid}: '
                '${animal.rfidTagNumber}',
                style: AppTypography.monoValue,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xxxs),
                  Expanded(
                    child: Text(lot, style: AppTypography.formFieldHelper),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnavailableAnimalsNotice extends StatelessWidget {
  const _UnavailableAnimalsNotice({
    required this.count,
    required this.readFailed,
  });

  final int count;
  final bool readFailed;

  @override
  Widget build(BuildContext context) {
    return Text(
      readFailed ? LivestockSaleDetailStrings.animalsReadFailure : LivestockSaleDetailStrings.unavailableAnimals(count),
      style: AppTypography.formFieldHelper.copyWith(color: AppColors.warning),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              LivestockSaleDetailStrings.notFound,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: context.read<LivestockSaleDetailCubit>().load,
              icon: const Icon(Icons.refresh),
              label: const Text(LivestockSaleDetailStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
