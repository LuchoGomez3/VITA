import 'dart:convert';

import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_context.dart';

/// Resuelve establecimiento y lotes reales desde datos disponibles offline.
///
/// Categorías y genealogía conservan temporalmente el catálogo existente hasta
/// que sus respectivas features expongan fuentes locales equivalentes.
class AnimalRegistrationOfflineContext implements AnimalRegistrationContext {
  /// Crea el contexto con almacenamiento y store inyectables.
  AnimalRegistrationOfflineContext({
    required SecureStorageService storage,
    required LotBrickStore lotStore,
  }) : _storage = storage,
       _lotStore = lotStore;

  final SecureStorageService _storage;
  final LotBrickStore _lotStore;
  final Map<String, AnimalRegistrationDestination> _destinations = {};
  String _establishmentId = '';

  // TODO(agusf): reemplazar este mapa por el catalogo de categorias
  // sincronizado en Brick y hacer que el draft conserve el UUID real.
  static const _categoryIdsByName = <String, String>{
    'Ternera': 'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8',
    'Ternero': 'b9a6e57b-20ae-49b1-a7bb-17c71af546f3',
    'Vaquillona': 'b6d6440c-88c6-48cc-9003-0ad2cc05f3d5',
    'Vaca': 'ef69117b-c979-4665-b13f-2b26ff0f19b3',
    'Novillo': '41da4271-bd25-4ba0-ba34-24dc6586f0f2',
    'Toro': 'b5e8ea91-9789-4f7e-9dad-10262f1920f4',
  };

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
  String get establishmentId => _establishmentId;

  @override
  Future<List<AnimalRegistrationDestination>> loadDestinations() async {
    final encoded = await _storage.read(SecureStorageKeys.establishmentCatalog);
    if (encoded == null || encoded.isEmpty) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List) return const [];
    final establishments = decoded.whereType<Map<String, dynamic>>();
    if (establishments.isEmpty) return const [];
    // TODO(agusf): obtener el establecimiento activo desde un proveedor de
    // sesion/seleccion; no asumir que el primero del catalogo es el elegido.
    final first = establishments.first;
    final id = first['id'];
    if (id is! String || id.isEmpty) return const [];
    _establishmentId = id;

    final lots = await _lotStore.getLocalLots(id);
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
  String resolveCategoryId(String categoryName) =>
      _categoryIdsByName[categoryName] ??
      (throw const DomainException(
        message: 'La categoría seleccionada no está disponible.',
        code: DomainErrorCode.validation,
      ));

  @override
  String? resolveMotherId(String? motherSelectionId) =>
      motherSelectionId == null ? null : _motherIdsBySelection[motherSelectionId];

  @override
  String? resolveFatherId(String? fatherSelectionId) =>
      fatherSelectionId == null ? null : _fatherIdsBySelection[fatherSelectionId];
}
