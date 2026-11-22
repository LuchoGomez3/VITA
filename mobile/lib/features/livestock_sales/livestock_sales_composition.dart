import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/livestock_sale_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/repositories/livestock_sale_animal_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/repositories/livestock_sale_draft_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/repositories/livestock_sale_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/add_animal_to_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/confirm_livestock_sale_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/delete_livestock_sale_draft_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/load_livestock_sale_draft_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/remove_animal_from_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/save_livestock_sale_draft_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/search_livestock_sale_animals_by_rfid_prefix_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/bloc/livestock_sale_bloc.dart';

/// Dependencias de dominio listas para el futuro flujo de presentacion.
class LivestockSalesUseCases {
  /// Agrupa seleccion y confirmacion sobre los stores reales de la app.
  const LivestockSalesUseCases({
    required this.addAnimal,
    required this.searchAnimalsByRfidPrefix,
    required this.removeAnimal,
    required this.confirmSale,
    required this.loadDraft,
    required this.saveDraft,
    required this.deleteDraft,
  });

  /// Agrega animales desde el inventario SQLite.
  final AddAnimalToLivestockSaleSelectionUseCase addAnimal;

  /// Busca sugerencias locales mientras se ingresa la caravana manualmente.
  final SearchLivestockSaleAnimalsByRfidPrefixUseCase searchAnimalsByRfidPrefix;

  /// Quita animales del borrador actual.
  final RemoveAnimalFromLivestockSaleSelectionUseCase removeAnimal;

  /// Valida y persiste una venta completa offline-first.
  final ConfirmLivestockSaleUseCase confirmSale;

  /// Recupera el progreso cifrado de una venta incompleta.
  final LoadLivestockSaleDraftUseCase loadDraft;

  /// Actualiza el progreso cifrado de una venta incompleta.
  final SaveLivestockSaleDraftUseCase saveDraft;

  /// Descarta el progreso al cancelar o confirmar la operación.
  final DeleteLivestockSaleDraftUseCase deleteDraft;
}

/// Construye el contrato que consumira el BLoC sin exponer Brick.
LivestockSalesUseCases createLivestockSalesUseCases({
  required String establishmentId,
}) {
  // Composition es el unico punto que conoce las implementaciones Brick. El
  // BLoC recibe casos de uso y conserva limpia la frontera de presentation.
  final animalRepository = LivestockSaleAnimalRepositoryImpl(
    animalBrickStore: BrickAnimalStore.instance,
    categoryBrickStore: BrickCategoriaStore.instance,
    lotBrickStore: BrickLotStore.instance,
    establishmentId: establishmentId,
  );
  final saleRepository = LivestockSaleRepositoryImpl(
    saleStore: BrickLivestockSaleStore.instance,
  );
  const draftRepository = LivestockSaleDraftRepositoryImpl(
    secureStorage: FlutterSecureStorageService(),
  );
  return LivestockSalesUseCases(
    addAnimal: AddAnimalToLivestockSaleSelectionUseCase(
      repository: animalRepository,
    ),
    searchAnimalsByRfidPrefix: SearchLivestockSaleAnimalsByRfidPrefixUseCase(
      repository: animalRepository,
    ),
    removeAnimal: const RemoveAnimalFromLivestockSaleSelectionUseCase(),
    confirmSale: ConfirmLivestockSaleUseCase(repository: saleRepository),
    loadDraft: const LoadLivestockSaleDraftUseCase(draftRepository),
    saveDraft: const SaveLivestockSaleDraftUseCase(draftRepository),
    deleteDraft: const DeleteLivestockSaleDraftUseCase(draftRepository),
  );
}

/// Crea el BLoC del flujo sin exponer stores Brick a presentation.
LivestockSaleBloc createLivestockSaleBloc({
  required String userId,
  required String establishmentId,
}) {
  final useCases = createLivestockSalesUseCases(
    establishmentId: establishmentId,
  );
  return LivestockSaleBloc(
    userId: userId,
    establishmentId: establishmentId,
    addAnimal: useCases.addAnimal,
    searchAnimalsByRfidPrefix: useCases.searchAnimalsByRfidPrefix,
    removeAnimal: useCases.removeAnimal,
    confirmSale: useCases.confirmSale,
    loadDraft: useCases.loadDraft,
    saveDraft: useCases.saveDraft,
    deleteDraft: useCases.deleteDraft,
  );
}
