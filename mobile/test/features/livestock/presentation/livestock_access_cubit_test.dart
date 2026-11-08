import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_sale_establishments_use_case.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_access_cubit.dart';

void main() {
  final outcomes = <String, Result<List<LivestockEstablishment>>>{
    'datos': const Result.success([]),
    'error': const Result.failure(DomainException(message: 'No se pudo leer el catalogo.')),
  };

  for (final outcome in outcomes.entries) {
    test('ignora ${outcome.key} si se desmonta el shell durante la lectura', () async {
      final repository = _PendingEstablishmentRepository();
      final cubit = LivestockAccessCubit(
        getSaleEstablishments: GetLivestockSaleEstablishmentsUseCase(repository),
      );

      final loading = cubit.load();
      await cubit.close();
      repository.result.complete(outcome.value);

      await expectLater(loading, completes);
    });
  }
}

class _PendingEstablishmentRepository implements LivestockEstablishmentRepository {
  final result = Completer<Result<List<LivestockEstablishment>>>();

  @override
  Future<Result<List<LivestockEstablishment>>> getEstablishments() => result.future;
}
