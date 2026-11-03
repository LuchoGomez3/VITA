import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/user_manual/data/repositories/user_manual_repository_impl.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';

/// Bundle en memoria: lo que no está, falla como un asset faltante.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.files);

  final Map<String, String> files;
  final requested = <String>[];

  @override
  Future<ByteData> load(String key) async {
    requested.add(key);
    final content = files[key];
    if (content == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(content.codeUnits));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    requested.add(key);
    final content = files[key];
    if (content == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    return content;
  }
}

const _general = '---\ntitulo: General\nroles: owner, admin, employee\n---\nHola **campo**.';
const _owner = '---\ntitulo: Solo dueños\nroles: owner\n---\n- uno';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserManualRepositoryImpl', () {
    test('lee las secciones en el orden de la lista, desde assets/manual', () async {
      final bundle = _FakeBundle({'assets/manual/b.md': _owner, 'assets/manual/a.md': _general});
      final repository = UserManualRepositoryImpl(bundle: bundle, sectionFiles: const ['a.md', 'b.md']);

      final result = await repository.getSections();

      final sections = (result as Success<List<ManualSection>>).data;
      expect(sections.map((section) => section.id), ['a', 'b']);
      expect(sections.map((section) => section.title), ['General', 'Solo dueños']);
      expect(sections[1].roles, {UserRole.owner});
      expect(bundle.requested, ['assets/manual/a.md', 'assets/manual/b.md']);
    });

    test('saltea una sección faltante o mal escrita y conserva el resto', () async {
      final bundle = _FakeBundle({
        'assets/manual/a.md': _general,
        'assets/manual/rota.md': '---\ntitulo: Rota\nroles: capataz\n---\n',
      });
      final repository = UserManualRepositoryImpl(bundle: bundle, sectionFiles: const ['a.md', 'falta.md', 'rota.md']);

      final result = await repository.getSections();

      expect((result as Success<List<ManualSection>>).data.map((section) => section.id), ['a']);
    });

    test('sin ninguna sección legible devuelve un error', () async {
      final repository = UserManualRepositoryImpl(bundle: _FakeBundle({}), sectionFiles: const ['a.md']);

      final result = await repository.getSections();

      expect(result, isA<Failure<List<ManualSection>>>());
    });

    test('las secciones reales del manual están declaradas y se leen sin errores', () async {
      final result = await UserManualRepositoryImpl().getSections();

      final sections = (result as Success<List<ManualSection>>).data;
      // Si una sección no se pudiera leer, el repositorio la saltearía.
      expect(sections, hasLength(UserManualAssets.sections.length));
      for (final section in sections) {
        expect(section.title, isNotEmpty, reason: section.id);
        expect(section.summary, isNotEmpty, reason: section.id);
        expect(section.blocks, isNotEmpty, reason: section.id);
      }
      expect(sections.first.isGeneral, isTrue, reason: 'Primeros pasos es para todos');
    });
  });
}
