import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';
import 'package:frontend_mayoral/features/home/domain/services/home_dashboard_calculator.dart';

/// Obtiene el tablero productivo que consume la pantalla de Inicio.
class GetHomeDashboardUseCase {
  /// Crea el caso de uso con su contrato de datos.
  GetHomeDashboardUseCase(
    this._repository, {
    HomeDashboardCalculator calculator = const HomeDashboardCalculator(),
    DateTime Function()? now,
  }) : _calculator = calculator,
       _now = now ?? DateTime.now;

  final HomeDashboardRepository _repository;
  final HomeDashboardCalculator _calculator;
  final DateTime Function() _now;

  /// Solicita el calculo actualizado de los KPIs locales.
  Future<Result<HomeDashboard>> call({
    Set<String>? establishmentIds,
  }) async {
    final result = await _repository.getDashboardSource(
      establishmentIds: establishmentIds,
    );
    return switch (result) {
      Success(:final data) => Result.success(_calculator.calculate(data, _now())),
      Failure(:final error) => Result.failure(error),
      _ => const Result.failure(
        DomainException(message: 'No se pudieron calcular los indicadores.'),
      ),
    };
  }
}
