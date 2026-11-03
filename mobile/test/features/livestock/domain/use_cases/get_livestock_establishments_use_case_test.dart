import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_establishments_use_case.dart';

void main() {
  test('conserva roles conocidos y excluye unknown', () async {
    final repository = _FakeRepository(
      Result.success([
        _establishment('admin', UserRole.admin),
        _establishment('owner', UserRole.owner),
        _establishment('employee', UserRole.employee),
        _establishment('unknown', UserRole.unknown),
      ]),
    );

    final result = await GetLivestockEstablishmentsUseCase(repository)();

    switch (result) {
      case Success<List<LivestockEstablishment>>(:final data):
        expect(data.map((establishment) => establishment.id), ['admin', 'owner', 'employee']);
      case Failure<List<LivestockEstablishment>>():
        fail('El caso de uso debía devolver los roles conocidos.');
    }
  });

  test('propaga el error tipado del repositorio', () async {
    const error = DomainException(message: 'catalog unavailable');
    final repository = _FakeRepository(const Result.failure(error));

    final result = await GetLivestockEstablishmentsUseCase(repository)();

    expect(result, const Result<List<LivestockEstablishment>>.failure(error));
  });
}

LivestockEstablishment _establishment(String id, UserRole role) => LivestockEstablishment(
  id: id,
  name: id,
  role: role,
);

class _FakeRepository implements LivestockEstablishmentRepository {
  _FakeRepository(this.result);

  final Result<List<LivestockEstablishment>> result;

  @override
  Future<Result<List<LivestockEstablishment>>> getEstablishments() async => result;
}
