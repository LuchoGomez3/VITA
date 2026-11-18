import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/remove_animal_from_livestock_sale_selection_use_case.dart';

void main() {
  const useCase = RemoveAnimalFromLivestockSaleSelectionUseCase();
  const first = LivestockSaleAnimal(
    id: 'first',
    establishmentId: 'establishment-id',
    rfidTagNumber: '982000412991415',
    visualTag: '001',
    categoryName: 'Novillo',
    lotName: 'Norte',
    status: LivestockSaleAnimalStatus.active,
  );
  const second = LivestockSaleAnimal(
    id: 'second',
    establishmentId: 'establishment-id',
    rfidTagNumber: '982000412991416',
    visualTag: '002',
    categoryName: 'Novillo',
    lotName: 'Sur',
    status: LivestockSaleAnimalStatus.active,
  );

  test('removes the requested animal and keeps the remaining order', () {
    final selection = useCase(
      animalId: 'first',
      selection: const LivestockSaleSelection(animals: [first, second]),
    );

    expect(selection.animals, [second]);
  });

  test('does not change the selection when the animal is absent', () {
    const original = LivestockSaleSelection(animals: [first, second]);

    final selection = useCase(animalId: 'missing', selection: original);

    expect(selection, original);
  });
}
