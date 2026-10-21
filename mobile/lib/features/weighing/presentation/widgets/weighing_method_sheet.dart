import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/weighing/presentation/mock/weighing_mock.dart';
import 'package:frontend_mayoral/features/weighing/presentation/pages/weighing_page.dart';
import 'package:frontend_mayoral/features/weighing/presentation/strings/weighing_strings.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_tab_selector.dart';
import 'package:go_router/go_router.dart';

/// Animal que se va a pesar.
typedef WeighingSubject = ({
  String animalId,
  String establishmentId,
  String visualTag,
  String rfidTagNumber,
  String breedAndCategory,
  int currentWeightKg,
});

enum _WeighingMethod {
  bluetooth(WeighingStrings.methodBluetooth, Icons.bluetooth),
  manual(WeighingStrings.methodManual, Icons.dialpad),
  photo(WeighingStrings.methodPhoto, Icons.photo_camera_outlined);

  const _WeighingMethod(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Pregunta cómo pesar a [subject] (balanza, manual o foto) y abre el pesaje.
///
/// La usan la ficha del animal y el lector de caravanas. Devuelve `true` si se
/// guardó un pesaje, para que quien la abrió recargue el último peso.
Future<bool> startWeighing(BuildContext context, WeighingSubject subject) async {
  final method = await showModalBottomSheet<_WeighingMethod>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
            child: Text(WeighingStrings.methodSheetTitle, style: AppTypography.pageTitle),
          ),
          for (final method in _WeighingMethod.values)
            ListTile(
              leading: Icon(method.icon, color: AppColors.primary),
              title: Text(method.label, style: AppTypography.mediumEmphasis),
              onTap: () => Navigator.of(sheetContext).pop(method),
            ),
        ],
      ),
    ),
  );
  if (method == null || !context.mounted) {
    return false;
  }

  switch (method) {
    case _WeighingMethod.bluetooth || _WeighingMethod.manual:
      final saved = await context.push<bool>(
        AppRoutes.weighing,
        extra: WeighingRequest(
          animalId: subject.animalId,
          establishmentId: subject.establishmentId,
          animal: WeighingAnimalMock(
            visualTag: subject.visualTag,
            rfid: subject.rfidTagNumber,
            breedAndCategory: subject.breedAndCategory,
            weightKg: subject.currentWeightKg,
          ),
          initialTab: method == _WeighingMethod.bluetooth ? WeighingCaptureTab.bluetooth : WeighingCaptureTab.manual,
        ),
      );
      return saved ?? false;
    case _WeighingMethod.photo:
      // El Pesaje IA (modelo de visión) está en la rama jornada-poster: cuando
      // entre a develop, acá se abre AppRoutes.visionWeighing con el animalId.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text(WeighingStrings.photoComingSoon)));
      return false;
  }
}
