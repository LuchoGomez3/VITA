import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/weighing/domain/entities/animal_weighing.dart';

/// Guarda pesajes de animales.
abstract class WeighingRepository {
  /// Guarda [weighing] en el celular y lo deja en cola para el servidor.
  Future<Result<AnimalWeighing>> save(AnimalWeighing weighing);
}
