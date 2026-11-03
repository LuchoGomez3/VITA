import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';

/// Fuente de las secciones del manual. Viajan dentro de la app, así que se
/// leen sin conexión.
abstract interface class UserManualRepository {
  /// Todas las secciones, en el orden del manual y sin filtrar por rol.
  Future<Result<List<ManualSection>>> getSections();
}
