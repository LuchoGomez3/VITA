import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';

/// Contrato para obtener los indicadores productivos de Inicio.
abstract class HomeDashboardRepository {
  /// Calcula el tablero con la informacion local disponible.
  Future<Result<HomeDashboard>> getDashboard();
}
