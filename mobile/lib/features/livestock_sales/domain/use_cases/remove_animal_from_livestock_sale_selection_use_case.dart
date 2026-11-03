import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';

/// Quita un animal de la seleccion sin alterar el orden de los restantes.
class RemoveAnimalFromLivestockSaleSelectionUseCase {
  /// Crea el caso de uso.
  const RemoveAnimalFromLivestockSaleSelectionUseCase();

  /// Devuelve una nueva seleccion sin el animal indicado.
  LivestockSaleSelection call({
    required String animalId,
    required LivestockSaleSelection selection,
  }) {
    return selection.copyWith(
      animals: selection.animals.where((animal) => animal.id != animalId).toList(growable: false),
    );
  }
}
