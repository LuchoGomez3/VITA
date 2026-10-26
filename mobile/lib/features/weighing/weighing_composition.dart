import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/weighing/data/repositories/weighing_repository_impl.dart';
import 'package:frontend_mayoral/features/weighing/domain/use_cases/record_animal_weighing_use_case.dart';

/// Construye el caso de uso que registra pesajes sobre el store local.
RecordAnimalWeighingUseCase createRecordAnimalWeighingUseCase() {
  return RecordAnimalWeighingUseCase(
    repository: WeighingRepositoryImpl(pesajeStore: BrickPesajeStore.instance),
    createId: generateUuidV4,
  );
}
