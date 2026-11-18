import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/user_manual/data/parsers/manual_markdown_parser.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';
import 'package:frontend_mayoral/features/user_manual/domain/repositories/user_manual_repository.dart';
import 'package:logging/logging.dart';

/// Archivos del manual, en el orden en que se muestran.
///
/// Para sumar una sección: crear el `.md` en `assets/manual/` (la carpeta ya
/// está declarada en `pubspec.yaml`) y agregarlo acá.
abstract final class UserManualAssets {
  /// Carpeta de las secciones.
  static const folder = 'assets/manual';

  /// Secciones, en orden.
  static const sections = [
    'primeros_pasos.md',
    'leer_caravanas.md',
    'mover_animales.md',
    'registrar_pesajes.md',
    'invitar_equipo.md',
    'crear_establecimiento.md',
  ];
}

/// Lee el manual de los assets de la app: funciona sin conexión.
class UserManualRepositoryImpl implements UserManualRepository {
  /// Crea el repositorio; [bundle] se reemplaza en los tests.
  UserManualRepositoryImpl({
    AssetBundle? bundle,
    List<String> sectionFiles = UserManualAssets.sections,
  }) : _bundle = bundle ?? rootBundle,
       _sectionFiles = sectionFiles;

  final AssetBundle _bundle;
  final List<String> _sectionFiles;

  static final Logger _logger = Logger('UserManualRepositoryImpl');

  @override
  Future<Result<List<ManualSection>>> getSections() async {
    final sections = <ManualSection>[];
    for (final file in _sectionFiles) {
      final id = file.endsWith('.md') ? file.substring(0, file.length - 3) : file;
      try {
        final source = await _bundle.loadString('${UserManualAssets.folder}/$file');
        sections.add(ManualMarkdownParser.parseSection(id, source));
      } on Object catch (error, stackTrace) {
        // Una sección rota no tiene que dejar sin manual al resto.
        _logger.severe('No se pudo leer la sección "$file" del manual.', error, stackTrace);
      }
    }
    if (sections.isEmpty) {
      return const Result.failure(
        DomainException(message: 'No se pudo leer el manual de usuario.', code: DomainErrorCode.notFound),
      );
    }
    return Result.success(List.unmodifiable(sections));
  }
}
