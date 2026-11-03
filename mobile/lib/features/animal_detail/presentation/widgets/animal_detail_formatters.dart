import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Texto y tono del estado productivo (activo, vendido, muerto, baja).
extension AnimalProductiveStatusLabel on AnimalProductiveStatus {
  /// Texto del chip.
  String get label => switch (this) {
    AnimalProductiveStatus.active => AnimalDetailStrings.productiveStatusActive,
    AnimalProductiveStatus.sold => AnimalDetailStrings.productiveStatusSold,
    AnimalProductiveStatus.dead => AnimalDetailStrings.productiveStatusDead,
    AnimalProductiveStatus.removed => AnimalDetailStrings.productiveStatusRemoved,
    AnimalProductiveStatus.unknown => AnimalDetailStrings.productiveStatusUnknown,
  };

  /// Tono del chip: verde si está en el rodeo, rojo si murió.
  AppStatusChipTone get tone => switch (this) {
    AnimalProductiveStatus.active => AppStatusChipTone.success,
    AnimalProductiveStatus.sold || AnimalProductiveStatus.removed => AppStatusChipTone.warning,
    AnimalProductiveStatus.dead => AppStatusChipTone.error,
    AnimalProductiveStatus.unknown => AppStatusChipTone.neutral,
  };
}

/// Texto visible del sexo del animal.
extension AnimalSexLabel on AnimalSex {
  /// "Macho" o "Hembra".
  String get label => switch (this) {
    AnimalSex.male => AnimalDetailStrings.sexMale,
    AnimalSex.female => AnimalDetailStrings.sexFemale,
  };
}

/// Texto visible del método de pesaje.
extension AnimalWeighingMethodLabel on AnimalWeighingMethod {
  /// "Manual", "Balanza Bluetooth" o "Estimación por IA".
  String get label => switch (this) {
    AnimalWeighingMethod.manual => AnimalDetailStrings.manualWeighingMethod,
    AnimalWeighingMethod.bluetoothScale => AnimalDetailStrings.bluetoothWeighingMethod,
    AnimalWeighingMethod.artificialIntelligence => AnimalDetailStrings.aiWeighingMethod,
  };
}

/// Edad calculada a partir de la fecha de nacimiento.
extension AnimalAgeLabel on DateTime {
  /// Por ejemplo "4 años 2 meses" o "6 meses".
  String ageLabel({DateTime? now}) {
    final today = now ?? DateTime.now();
    var months = (today.year - year) * 12 + today.month - month;
    if (today.day < day) {
      months -= 1;
    }
    if (months < 0) {
      return AnimalDetailStrings.noDataValue;
    }
    if (months < 12) {
      return '$months ${AnimalDetailStrings.monthsSuffix}';
    }
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (remainingMonths == 0) {
      return '$years ${AnimalDetailStrings.yearsSuffix}';
    }
    return '$years ${AnimalDetailStrings.yearsSuffix} $remainingMonths ${AnimalDetailStrings.monthsSuffix}';
  }
}

/// Peso sin decimales si es entero (`442`), con uno si no (`442.5`).
extension AnimalWeightLabel on double {
  /// Peso para mostrar, sin la unidad.
  String get displayWeight => toStringAsFixed(truncateToDouble() == this ? 0 : 1);
}

/// `982000412884712` → `982 000412 884 712`, como en la caravana impresa.
String groupRfid(String rfid) {
  if (rfid.length != 15) {
    return rfid;
  }
  return '${rfid.substring(0, 3)} ${rfid.substring(3, 9)} ${rfid.substring(9, 12)} ${rfid.substring(12)}';
}
