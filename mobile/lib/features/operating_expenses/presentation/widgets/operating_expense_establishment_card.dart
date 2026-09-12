import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

/// Identifica el establecimiento al que quedará asociado el nuevo egreso.
class OperatingExpenseEstablishmentCard extends StatelessWidget {
  /// Crea la tarjeta informativa del establecimiento activo.
  const OperatingExpenseEstablishmentCard({
    required this.establishmentName,
    super.key,
  });

  /// Nombre visible del establecimiento activo.
  final String establishmentName;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined),
        title: const Text(OperatingExpenseStrings.establishment),
        subtitle: Text(establishmentName),
      ),
    );
  }
}
