import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/livestock/data/repositories/livestock_establishment_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';

void main() {
  test('mapea el catálogo offline al dominio de Hacienda', () async {
    final repository = _repository(
      '''[{"id":"establishment-1","name":"El Ombú","role":"owner"}]''',
    );

    final result = await repository.getEstablishments();

    switch (result) {
      case Success<List<LivestockEstablishment>>(:final data):
        expect(data, [
          const LivestockEstablishment(
            id: 'establishment-1',
            name: 'El Ombú',
            role: UserRole.owner,
          ),
        ]);
      case Failure<List<LivestockEstablishment>>():
        fail('El catálogo válido debía mapearse correctamente.');
    }
  });

  test('traduce un catálogo corrupto a un error de dominio', () async {
    final repository = _repository('{"invalid":true}');

    final result = await repository.getEstablishments();

    expect(result, isA<Failure<List<LivestockEstablishment>>>());
  });

  test('traduce fallas del storage a un error de dominio', () async {
    final repository = LivestockEstablishmentRepositoryImpl(
      establishmentCatalog: EstablishmentCatalog(
        secureStorage: _MemoryStorage(readError: Exception('storage unavailable')),
      ),
    );

    final result = await repository.getEstablishments();

    expect(result, isA<Failure<List<LivestockEstablishment>>>());
  });
}

LivestockEstablishmentRepositoryImpl _repository(String catalog) {
  return LivestockEstablishmentRepositoryImpl(
    establishmentCatalog: EstablishmentCatalog(
      secureStorage: _MemoryStorage(value: catalog),
    ),
  );
}

class _MemoryStorage implements SecureStorageService {
  _MemoryStorage({this.value, this.readError});

  String? value;
  final Exception? readError;

  @override
  Future<void> delete(String key) async {
    value = null;
  }

  @override
  Future<String?> read(String key) async {
    final error = readError;
    if (error != null) throw error;
    return value;
  }

  @override
  Future<void> write({required String key, required String value}) async {
    this.value = value;
  }
}
