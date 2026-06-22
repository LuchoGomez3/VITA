import 'package:frontend_mayoral/core/errors/domain_exception.dart';

/// Temporary mock context for the animal registration flow.
///
/// This keeps establishment, lot, category, and genealogy mappings out of
/// presentation while the real auth/catalog flows are still under development.
// TODO(agustin): Replace these hardcoded business identifiers with real
// session/catalog sources before reusing this pattern in other features.
class AnimalRegistrationMockContext {
  const AnimalRegistrationMockContext();

  static const _defaultEstablishmentId = '8b75eb38-8b0f-44dc-979f-89ce2817b63d';
  static const _defaultLotId = '62af91d7-307d-4a07-b2bd-b2d8976ec91a';
  static const _defaultLotName = 'La Cumbre';

  static const _categoryIdsByName = <String, String>{
    'Ternera': 'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8',
    'Ternero': 'b9a6e57b-20ae-49b1-a7bb-17c71af546f3',
    'Vaquillona': 'b6d6440c-88c6-48cc-9003-0ad2cc05f3d5',
    'Vaca': 'ef69117b-c979-4665-b13f-2b26ff0f19b3',
    'Novillo': '41da4271-bd25-4ba0-ba34-24dc6586f0f2',
    'Toro': 'b5e8ea91-9789-4f7e-9dad-10262f1920f4',
  };

  static const _motherIdsBySelection = <String, String>{
    'mother-003-0421': '56fb8531-13f7-41c6-a1e1-85ea9b7094fa',
  };

  static const _fatherIdsBySelection = <String, String>{
    'father-003-0820': 'cd3928bd-1748-42ea-93e0-9fa798ea0ec3',
    'father-003-0612': '9634f0a4-fc46-4f04-b209-d8bf0d15a5e1',
    'father-002-0118': '92df2f3d-2cd0-4699-b4e2-5dc236e6c718',
  };

  static const _destinationLotIdsBySelection = <String, String>{
    'destination-la-cumbre': _defaultLotId,
  };

  /// ID of the establishment used while the session flow is still mocked.
  String get establishmentId => _defaultEstablishmentId;

  /// Human-readable lot name used in the success summary.
  String get defaultLotName => _defaultLotName;

  /// Resolves the lot destination selected in the flow.
  String resolveLotId(String destinationSelectionId) {
    final lotId = _destinationLotIdsBySelection[destinationSelectionId];
    if (lotId == null) {
      throw DomainException(
        message: 'Seleccioná un destino válido antes de guardar.',
        code: DomainErrorCode.validation,
      );
    }

    return lotId;
  }

  /// Resolves the current lot display name.
  String resolveLotName(String destinationSelectionId) {
    final lotId = resolveLotId(destinationSelectionId);
    if (lotId == _defaultLotId) {
      return _defaultLotName;
    }

    throw DomainException(
      message: 'No se pudo resolver el nombre del destino seleccionado.',
      code: DomainErrorCode.validation,
    );
  }

  /// Resolves the backend-ready category identifier from the UI label.
  String resolveCategoryId(String categoryName) {
    final categoryId = _categoryIdsByName[categoryName];
    if (categoryId == null) {
      throw DomainException(
        message: 'La categoría seleccionada no está disponible.',
        code: DomainErrorCode.validation,
      );
    }

    return categoryId;
  }

  /// Resolves the mother ID from the selected option key.
  String? resolveMotherId(String? motherSelectionId) {
    if (motherSelectionId == null) {
      return null;
    }

    return _motherIdsBySelection[motherSelectionId];
  }

  /// Resolves the father ID from the selected option key.
  String? resolveFatherId(String? fatherSelectionId) {
    if (fatherSelectionId == null) {
      return null;
    }

    return _fatherIdsBySelection[fatherSelectionId];
  }
}
