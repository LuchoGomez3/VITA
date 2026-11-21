import 'package:frontend_mayoral/core/constants/health_registration_strings.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';

/// Indica qué dato del formulario necesita revisión.
String? healthRejectionPrompt({String? animalLabel, HealthRejectionField? field}) {
  final label = switch (field) {
    HealthRejectionField.practice => HealthRegistrationStrings.practice,
    HealthRejectionField.product => HealthRegistrationStrings.product,
    HealthRejectionField.dose => HealthRegistrationStrings.dose,
    HealthRejectionField.unit => HealthRegistrationStrings.unit,
    HealthRejectionField.route => HealthRegistrationStrings.route,
    HealthRejectionField.batch => HealthRegistrationStrings.recordedBatch,
    HealthRejectionField.expiration => HealthRegistrationStrings.recordedExpiration,
    HealthRejectionField.description => HealthRegistrationStrings.description,
    HealthRejectionField.sampleType => HealthRegistrationStrings.sampleType,
    HealthRejectionField.sampleReference => HealthRegistrationStrings.sampleReference,
    HealthRejectionField.responsible => HealthRegistrationStrings.responsible,
    HealthRejectionField.date => HealthRegistrationStrings.date,
    HealthRejectionField.result => HealthRegistrationStrings.result,
    HealthRejectionField.resultDate => HealthRegistrationStrings.resultDate,
    null => null,
  };
  return switch ((animalLabel, label)) {
    (final animal?, final name?) => 'Revisá el campo «$name» para la caravana $animal.',
    (final animal?, null) => 'Revisá la caravana $animal.',
    (null, final name?) => 'Revisá el campo «$name».',
    (null, null) => null,
  };
}
