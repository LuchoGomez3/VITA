import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/features/rfid_scan/data/repositories/rfid_animal_lookup_repository_impl.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_reading_source.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/find_animal_by_rfid_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/validate_rfid_reading_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/bloc/rfid_scan_bloc.dart';

/// Crea el BLoC de identificacion con dependencias locales resueltas.
RfidScanBloc createRfidScanBloc({
  required RfidReadingSource readingSource,
  required String establishmentId,
}) {
  final repository = RfidAnimalLookupRepositoryImpl(
    animalBrickStore: BrickAnimalStore.instance,
  );
  return RfidScanBloc(
    readingSource: readingSource,
    validateRfidReadingUseCase: ValidateRfidReadingUseCase(),
    findAnimalByRfidUseCase: FindAnimalByRfidUseCase(repository),
    establishmentId: establishmentId,
  );
}
