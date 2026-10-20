import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/livestock/data/repositories/livestock_establishment_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_establishments_use_case.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_reader_cubit.dart';

/// Construye el Cubit de Hacienda con su fuente local offline.
LivestockReaderCubit createLivestockReaderCubit() {
  const catalog = EstablishmentCatalog(
    secureStorage: FlutterSecureStorageService(),
  );
  const repository = LivestockEstablishmentRepositoryImpl(
    establishmentCatalog: catalog,
  );
  return LivestockReaderCubit(
    const GetLivestockEstablishmentsUseCase(repository),
  );
}
