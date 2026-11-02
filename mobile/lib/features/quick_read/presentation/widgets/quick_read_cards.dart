import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/strings/quick_read_strings.dart';

/// "dd/mm" de un pesaje.
String _shortDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

/// Peso sin decimales innecesarios.
String formatQuickReadWeight(double kg) => kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);

/// Raza y categoría juntas.
String breedAndCategory(QuickReadAnimal animal) =>
    [animal.animal.breed, animal.animal.categoryName].where((part) => part.isNotEmpty).join(' · ');

/// Espera de la primera lectura (`LectorEsperando`).
class QuickReadWaiting extends StatelessWidget {
  /// Crea la espera.
  const QuickReadWaiting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        SizedBox.square(
          dimension: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final (size, alpha) in const [(150.0, 0.06), (118.0, 0.1), (88.0, 0.16)])
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: alpha),
                  ),
                ),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                child: const Icon(Icons.contactless_outlined, size: 32, color: AppColors.onPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          QuickReadStrings.waitingTitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            QuickReadStrings.waitingBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta del animal leído (`LectorUna`).
class QuickReadAnimalCard extends StatelessWidget {
  /// Crea la tarjeta.
  const QuickReadAnimalCard({required this.animal, super.key});

  /// Animal leído.
  final QuickReadAnimal animal;

  @override
  Widget build(BuildContext context) {
    final weight = animal.lastWeightKg;
    final date = animal.lastWeighingDate;
    final details = [
      if (animal.animal.lotName.isNotEmpty) animal.animal.lotName,
      if (weight != null) '${formatQuickReadWeight(weight)} kg${date == null ? '' : ' (${_shortDate(date)})'}',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            animal.animal.visualTag,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          if (breedAndCategory(animal).isNotEmpty) Text(breedAndCategory(animal), style: AppTypography.mediumEmphasis),
          const SizedBox(height: AppSpacing.xxs),
          Text(animal.animal.rfidTagNumber, style: AppTypography.monoValue.copyWith(fontSize: 12)),
          if (details.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(details, style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint)),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de la caravana sin registrar (`LectorUnaNueva`).
class QuickReadUnregisteredCard extends StatelessWidget {
  /// Crea la tarjeta.
  const QuickReadUnregisteredCard({required this.rfidTagNumber, required this.establishmentName, super.key});

  /// RFID leído.
  final String rfidTagNumber;

  /// Campo de la sesión (vacío si no se eligió).
  final String establishmentName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.syncPendingContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.help_outline, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  QuickReadStrings.unregisteredTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.syncPending),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(rfidTagNumber, style: AppTypography.monoValueEmphasis),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  QuickReadStrings.notInEstablishment(establishmentName),
                  style: AppTypography.smallEmphasis.copyWith(color: AppColors.syncPending),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de la lista de caravanas leídas.
class QuickReadItemRow extends StatelessWidget {
  /// Crea la fila.
  const QuickReadItemRow({required this.item, super.key, this.onRemove, this.onOpen});

  /// Caravana leída.
  final QuickReadItem item;

  /// Quitarla de la lista (solo con la lista abierta).
  final VoidCallback? onRemove;

  /// Abrir la ficha (solo registradas).
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, registered) = switch (item) {
      RegisteredRead(:final animal) => (
        animal.animal.visualTag,
        [breedAndCategory(animal), animal.animal.lotName].where((part) => part.isNotEmpty).join(' · '),
        true,
      ),
      UnregisteredRead(:final rfidTagNumber) => (rfidTagNumber, QuickReadStrings.unregisteredTitle, false),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: onOpen,
      leading: Icon(
        registered ? Icons.check_circle : Icons.error_outline,
        color: registered ? AppColors.primary : AppColors.warning,
      ),
      title: Text(
        title,
        style: registered
            ? const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
            : AppTypography.monoValueEmphasis,
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              style: AppTypography.smallEmphasis.copyWith(
                color: registered ? AppColors.textHint : AppColors.syncPending,
              ),
            ),
      trailing: onRemove == null
          ? null
          : IconButton(
              tooltip: QuickReadStrings.remove,
              icon: const Icon(Icons.close, size: 18, color: AppColors.textHint),
              onPressed: onRemove,
            ),
    );
  }
}
