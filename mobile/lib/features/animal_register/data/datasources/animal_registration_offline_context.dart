import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_context.dart';

/// Resuelve establecimiento y lotes reales desde datos disponibles offline.
///
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
}
