import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_context.dart';

/// Resuelve establecimiento y lotes reales desde datos disponibles offline.
///
/// Genealogia conserva temporalmente el catalogo existente hasta que la feature
/// exponga una fuente local equivalente.
class AnimalRegistrationOfflineContext implements AnimalRegistrationContext {
  /// Crea el contexto con almacenamiento y store inyectables.
  AnimalRegistrationOfflineContext({
    required EstablishmentCatalog establishmentCatalog,
    required LotBrickStore lotStore,
  }) : _establishmentCatalog = establishmentCatalog,
       _lotStore = lotStore;

  final EstablishmentCatalog _establishmentCatalog;
  final LotBrickStore _lotStore;
  final Map<String, AnimalRegistrationDestination> _destinations = {};

  // TODO(agusf): consultar en BrickAnimalStore las madres elegibles del
  // establecimiento y eliminar las claves temporales de seleccion.
  static const _motherIdsBySelection = <String, String>{
    'mother-003-0421': '56fb8531-13f7-41c6-a1e1-85ea9b7094fa',
  };

  // TODO(agusf): consultar en BrickAnimalStore los padres elegibles del
  // establecimiento y eliminar las claves temporales de seleccion.
  static const _fatherIdsBySelection = <String, String>{
    'father-003-0820': 'cd3928bd-1748-42ea-93e0-9fa798ea0ec3',
    'father-003-0612': '9634f0a4-fc46-4f04-b209-d8bf0d15a5e1',
    'father-002-0118': '92df2f3d-2cd0-4699-b4e2-5dc236e6c718',
  };

  @override
  Future<List<AnimalRegistrationEstablishment>> loadEstablishments() async {
    final memberships = await _establishmentCatalog.getMemberships();
    return memberships
        .map(
          (membership) => AnimalRegistrationEstablishment(
            id: membership.id,
            name: membership.name,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<AnimalRegistrationDestination>> loadDestinations(
    String establishmentId,
  ) async {
    final lots = await _lotStore.getLocalLots(establishmentId);
    _destinations
      ..clear()
      ..addEntries(
        lots
            .where((lot) => lot.statusCode == 'active')
            .map(
              (lot) => MapEntry(
                lot.localId,
                AnimalRegistrationDestination(
                  id: lot.localId,
                  name: lot.name,
                  details: '${(lot.surfaceTenths / 10).toStringAsFixed(1)} ha',
                ),
              ),
            ),
      );
    return _destinations.values.toList();
  }

  @override
  String resolveLotId(String destinationSelectionId) {
    final destination = _destinations[destinationSelectionId];
    if (destination == null) {
      throw const DomainException(
        message: 'Seleccioná un lote activo antes de guardar.',
        code: DomainErrorCode.validation,
      );
    }
    return destination.id;
  }

  @override
  String resolveLotName(String destinationSelectionId) =>
      _destinations[destinationSelectionId]?.name ??
      (throw const DomainException(
        message: 'El lote seleccionado ya no está disponible.',
        code: DomainErrorCode.validation,
      ));

  @override
  String? resolveMotherId(String? motherSelectionId) =>
      motherSelectionId == null ? null : _motherIdsBySelection[motherSelectionId];

  @override
  String? resolveFatherId(String? fatherSelectionId) =>
      fatherSelectionId == null ? null : _fatherIdsBySelection[fatherSelectionId];
}
