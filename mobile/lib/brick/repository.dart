import 'package:frontend_mayoral/brick/models/animal.model.dart';

class AppBrickRepository {
  final List<BrickAnimalModel> _animals = [];

  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async {
    _animals.removeWhere((current) => current.nroCaravana == animal.nroCaravana);
    _animals.add(animal.copyWith(syncedAt: DateTime.now()));
    return _animals.firstWhere((current) => current.nroCaravana == animal.nroCaravana);
  }
}

/*
  Cuando se integre Brick de verdad, esta clase será el punto central para
  extender `OfflineFirstWithRestRepository` y conectar:

  - RestProvider
  - SqliteProvider
  - offline queue manager
  - migrations / adapters generados

  Por ahora queda simple para dejar clara la estructura.
*/
