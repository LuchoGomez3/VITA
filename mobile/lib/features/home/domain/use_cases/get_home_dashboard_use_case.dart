import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';

/// Obtiene el tablero productivo que consume la pantalla de Inicio.
class GetHomeDashboardUseCase {
  /// Crea el caso de uso con su contrato de datos.
  const GetHomeDashboardUseCase(this._repository);

  final HomeDashboardRepository _repository;

  /// Solicita el calculo actualizado de los KPIs locales.
  Future<Result<HomeDashboard>> call({
    Set<String>? establishmentIds,
  }) {
    return _repository.getDashboard(establishmentIds: establishmentIds);
  }
}
