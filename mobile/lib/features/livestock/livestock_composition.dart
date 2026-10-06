import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/livestock/data/repositories/livestock_establishment_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_sale_establishments_use_case.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_access_cubit.dart';

/// Construye el estado de accesos de Hacienda sobre datos locales.
LivestockAccessCubit createLivestockAccessCubit() {
  const catalog = EstablishmentCatalog(
    secureStorage: FlutterSecureStorageService(),
  );
  const repository = LivestockEstablishmentRepositoryImpl(catalog);
  return LivestockAccessCubit(
    getSaleEstablishments: const GetLivestockSaleEstablishmentsUseCase(
      repository,
    ),
  );
}
