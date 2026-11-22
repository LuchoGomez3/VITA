import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';
import 'package:frontend_mayoral/features/user_manual/domain/repositories/user_manual_repository.dart';

/// Sección mínima para los tests.
ManualSection sectionFor(String id, Set<UserRole> roles, {String? title}) => ManualSection(
  id: id,
  title: title ?? id,
  summary: 'Resumen de $id',
  roles: roles,
  blocks: const [
    ManualParagraph([ManualSpan('Texto de prueba')]),
  ],
);

/// Las secciones del esqueleto, con los roles reales.
final List<ManualSection> sampleSections = [
  sectionFor('primeros_pasos', manualRoles, title: 'Primeros pasos'),
  sectionFor('registrar_pesajes', manualRoles, title: 'Registrar pesajes'),
  sectionFor('invitar_equipo', {UserRole.owner, UserRole.admin}, title: 'Invitar a tu equipo'),
  sectionFor('crear_establecimiento', {UserRole.owner}, title: 'Crear un establecimiento'),
];

/// Repositorio en memoria.
class FakeUserManualRepository implements UserManualRepository {
  /// Crea el repositorio con [result].
  FakeUserManualRepository([Result<List<ManualSection>>? result]) : result = result ?? Result.success(sampleSections);

  /// Lo que devuelve [getSections].
  Result<List<ManualSection>> result;

  @override
  Future<Result<List<ManualSection>>> getSections() async => result;
}
