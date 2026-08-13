import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';

/// Tarjeta de confirmacion rapida para un animal encontrado por RFID.
class IdentifiedAnimalCard extends StatelessWidget {
  /// Crea la tarjeta con la informacion local del [animal].
  const IdentifiedAnimalCard({
    required this.animal,
    super.key,
  });

  /// Animal encontrado en la copia SQLite del dispositivo.
  final IdentifiedAnimal animal;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.backgroundSecondary,
                foregroundColor: AppColors.primary,
                child: Icon(Icons.check),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(RfidScanStrings.foundTitle, style: AppTypography.secondaryEmphasis)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: _InfoRow(label: RfidScanStrings.rfidLabel, value: animal.rfidTagNumber, compact: true),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: RfidScanStrings.visualTagLabel, value: animal.visualTag),
          _InfoRow(label: RfidScanStrings.breedLabel, value: animal.breed),
          _InfoRow(label: RfidScanStrings.sexLabel, value: _sexLabel),
          _InfoRow(label: RfidScanStrings.categoryLabel, value: _displayValue(animal.categoryName)),
          _InfoRow(label: RfidScanStrings.lotLabel, value: _displayValue(animal.lotName)),
        ],
      ),
    );
  }

  String get _sexLabel => switch (animal.sex) {
    IdentifiedAnimalSex.male => RfidScanStrings.male,
    IdentifiedAnimalSex.female => RfidScanStrings.female,
  };

  String _displayValue(String value) => value.isEmpty ? RfidScanStrings.unavailableValue : value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0 : AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.smallEmphasis)),
          Expanded(child: Text(value, style: AppTypography.formFieldValueEmphasis)),
        ],
      ),
    );
  }
}
