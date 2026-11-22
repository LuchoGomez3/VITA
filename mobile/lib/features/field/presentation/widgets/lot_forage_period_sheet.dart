import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/catalogs/forage_resource_catalog.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Lo que el usuario decidió en la hoja del recurso.
sealed class LotForagePeriodSheetResult {
  const LotForagePeriodSheetResult();
}

/// Guardar un período nuevo o corregido.
class LotForagePeriodSaved extends LotForagePeriodSheetResult {
  /// Crea el resultado con los datos del formulario.
  const LotForagePeriodSaved({
    required this.resourceCode,
    required this.startDate,
    this.endDate,
    this.description,
  });

  /// Código del catálogo elegido.
  final String resourceCode;

  /// Primer día del recurso.
  final DateTime startDate;

  /// Corte explícito, si el potrero quedó sin este recurso.
  final DateTime? endDate;

  /// Detalle libre.
  final String? description;
}

/// Borrar el período del historial.
class LotForagePeriodDeleted extends LotForagePeriodSheetResult {
  /// Crea el resultado de borrado.
  const LotForagePeriodDeleted();
}

/// Abre la hoja para cargar un recurso nuevo o corregir [existing].
Future<LotForagePeriodSheetResult?> showLotForagePeriodSheet(
  BuildContext context, {
  LotForagePeriod? existing,
}) => showModalBottomSheet<LotForagePeriodSheetResult>(
  context: context,
  useRootNavigator: true,
  showDragHandle: true,
  isScrollControlled: true,
  backgroundColor: AppColors.background,
  builder: (_) => _LotForagePeriodSheet(existing: existing),
);

class _LotForagePeriodSheet extends StatefulWidget {
  const _LotForagePeriodSheet({this.existing});

  final LotForagePeriod? existing;

  @override
  State<_LotForagePeriodSheet> createState() => _LotForagePeriodSheetState();
}

class _LotForagePeriodSheetState extends State<_LotForagePeriodSheet> {
  late String? _resourceCode = widget.existing?.resourceCode;
  late DateTime _startDate = widget.existing?.startDate ?? DateUtils.dateOnly(DateTime.now());
  late bool _hasEnd = widget.existing?.endDate != null;
  late DateTime? _endDate = widget.existing?.endDate;
  late final _descriptionController = TextEditingController(text: widget.existing?.description);
  String? _resourceError;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final today = DateUtils.dateOnly(DateTime.now());
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? FieldStrings.editForageTitle : FieldStrings.newForageTitle,
                style: AppTypography.pageTitle,
              ),
              if (!isEditing) ...[
                const SizedBox(height: AppSpacing.xxs),
                const Text(FieldStrings.newForageHelper, style: AppTypography.formFieldHelper),
              ],
              const SizedBox(height: AppSpacing.md),
              AppDropdownFormField<String>(
                title: FieldStrings.forageResourceFieldLabel,
                hintText: FieldStrings.forageResourceRequiredHint,
                initialValue: _resourceCode,
                errorText: _resourceError,
                icon: const Icon(Icons.grass_outlined, color: AppColors.primary),
                options: [
                  for (final option in ForageResourceCatalog.values)
                    AppDropdownOption(value: option.code, label: option.displayName),
                ],
                onChanged: (value) => setState(() {
                  _resourceCode = value;
                  _resourceError = null;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextFormField(
                controller: _descriptionController,
                title: FieldStrings.forageDescriptionLabel,
                hintText: FieldStrings.forageDescriptionHint,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.md),
              AppDateFormField(
                title: FieldStrings.forageStartLabel,
                hintText: FieldStrings.forageDateHint,
                value: _startDate,
                lastDate: today,
                onChanged: (date) => setState(() {
                  _startDate = DateUtils.dateOnly(date);
                  if (_endDate case final end? when end.isBefore(_startDate)) _endDate = _startDate;
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                value: _hasEnd,
                title: const Text(FieldStrings.forageHasEndLabel, style: AppTypography.mediumEmphasis),
                onChanged: (value) => setState(() {
                  _hasEnd = value ?? false;
                  _endDate = _hasEnd ? (_endDate ?? today) : null;
                }),
              ),
              if (_hasEnd)
                AppDateFormField(
                  title: FieldStrings.forageEndLabel,
                  hintText: FieldStrings.forageDateHint,
                  value: _endDate,
                  firstDate: _startDate,
                  lastDate: today.isBefore(_startDate) ? _startDate : today,
                  onChanged: (date) => setState(() => _endDate = DateUtils.dateOnly(date)),
                ),
              const SizedBox(height: AppSpacing.lg),
              AppFilledButton(label: FieldStrings.saveForageCta, onPressed: _submit),
              if (isEditing) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () => Navigator.pop(context, const LotForagePeriodDeleted()),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(FieldStrings.deleteForageCta),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final resourceCode = _resourceCode;
    if (resourceCode == null) {
      setState(() => _resourceError = FieldStrings.forageRequiredError);
      return;
    }
    Navigator.pop(
      context,
      LotForagePeriodSaved(
        resourceCode: resourceCode,
        startDate: _startDate,
        endDate: _hasEnd ? _endDate : null,
        description: _descriptionController.text,
      ),
    );
  }
}
