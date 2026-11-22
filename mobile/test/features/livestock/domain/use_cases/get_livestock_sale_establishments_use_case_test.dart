import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_sale_establishments_use_case.dart';

void main() {
  test('conserva solamente establecimientos de admin y owner', () async {
    const useCase = GetLivestockSaleEstablishmentsUseCase(
      _EstablishmentRepository(),
    );

    final result = await useCase();

    final establishments = result.when(
      success: (data) => data,
      failure: (error) => throw error,
    );
    expect(
      establishments.map((establishment) => establishment.id),
      ['admin-id', 'owner-id'],
    );
  });
}

class _EstablishmentRepository implements LivestockEstablishmentRepository {
  const _EstablishmentRepository();

  @override
  Future<Result<List<LivestockEstablishment>>> getEstablishments() async {
    return const Result.success([
      LivestockEstablishment(
        id: 'admin-id',
        name: 'Campo Admin',
        role: UserRole.admin,
      ),
      LivestockEstablishment(
        id: 'employee-id',
        name: 'Campo Empleado',
        role: UserRole.employee,
      ),
      LivestockEstablishment(
        id: 'owner-id',
        name: 'Campo Owner',
        role: UserRole.owner,
      ),
    ]);
  }
}
