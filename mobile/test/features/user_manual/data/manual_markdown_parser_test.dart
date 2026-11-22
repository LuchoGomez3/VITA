import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/user_manual/data/parsers/manual_markdown_parser.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';

void main() {
  group('ManualMarkdownParser.parseSection', () {
    test('lee título, resumen y roles del front-matter', () {
      final section = ManualMarkdownParser.parseSection('invitar', '''
---
titulo: Invitar a tu equipo
resumen: Sumá gente al campo.
roles: owner, admin
---
Texto.
''');

      expect(section.id, 'invitar');
      expect(section.title, 'Invitar a tu equipo');
      expect(section.summary, 'Sumá gente al campo.');
      expect(section.roles, {UserRole.owner, UserRole.admin});
      expect(section.isGeneral, isFalse);
      expect(section.blocks.single, isA<ManualParagraph>());
    });

    test('una sección con los tres roles es general', () {
      final section = ManualMarkdownParser.parseSection('a', '---\ntitulo: A\nroles: employee, owner, admin\n---\n');

      expect(section.isGeneral, isTrue);
      expect(section.blocks, isEmpty);
    });

    test('rechaza un archivo sin front-matter', () {
      expect(() => ManualMarkdownParser.parseSection('a', '# Hola'), throwsFormatException);
    });

    test('rechaza un front-matter sin cerrar', () {
      expect(() => ManualMarkdownParser.parseSection('a', '---\ntitulo: A\nroles: owner\n'), throwsFormatException);
    });

    test('rechaza una sección sin título o sin roles', () {
      expect(() => ManualMarkdownParser.parseSection('a', '---\nroles: owner\n---\n'), throwsFormatException);
      expect(() => ManualMarkdownParser.parseSection('a', '---\ntitulo: A\n---\n'), throwsFormatException);
    });

    test('rechaza un rol mal escrito en vez de esconder la sección', () {
      expect(
        () => ManualMarkdownParser.parseSection('a', '---\ntitulo: A\nroles: owner, capataz\n---\n'),
        throwsFormatException,
      );
    });
  });

  group('ManualMarkdownParser.parseBlocks', () {
    test('reconoce títulos de nivel 1 a 3', () {
      final blocks = ManualMarkdownParser.parseBlocks('# Uno\n## Dos\n### Tres\n#### Cuatro');

      final levels = blocks.cast<ManualHeading>().map((heading) => heading.level);
      expect(levels, [1, 2, 3, 3]);
      expect((blocks.first as ManualHeading).spans, [const ManualSpan('Uno')]);
    });

    test('une las líneas de un párrafo y separa párrafos con una línea vacía', () {
      final blocks = ManualMarkdownParser.parseBlocks('Primera línea\nsegunda línea.\n\nOtro párrafo.');

      expect(blocks, hasLength(2));
      expect((blocks[0] as ManualParagraph).spans, [const ManualSpan('Primera línea segunda línea.')]);
      expect((blocks[1] as ManualParagraph).spans, [const ManualSpan('Otro párrafo.')]);
    });

    test('arma listas con viñetas y numeradas', () {
      final blocks = ManualMarkdownParser.parseBlocks('- uno\n* dos\n\n3. tres\n4. cuatro');

      final bullets = blocks[0] as ManualList;
      expect(bullets.isOrdered, isFalse);
      expect(bullets.items, [
        [const ManualSpan('uno')],
        [const ManualSpan('dos')],
      ]);
      final ordered = blocks[1] as ManualList;
      expect(ordered.isOrdered, isTrue);
      expect(ordered.start, 3);
      expect(ordered.items, hasLength(2));
    });

    test('una línea con sangría continúa el ítem anterior', () {
      final blocks = ManualMarkdownParser.parseBlocks('1. Tocá Leer\n   y acercá el bastón.\n2. Listo');

      final list = blocks.single as ManualList;
      expect(list.items.first, [const ManualSpan('Tocá Leer y acercá el bastón.')]);
    });

    test('cambiar de viñetas a números empieza otra lista', () {
      final blocks = ManualMarkdownParser.parseBlocks('- a\n1. b');

      expect(blocks.map((block) => (block as ManualList).isOrdered), [false, true]);
    });

    test('una cita es una nota, aunque ocupe varias líneas', () {
      final blocks = ManualMarkdownParser.parseBlocks('Antes.\n> Sin señal\n> también anda.\n\nDespués.');

      expect(blocks, hasLength(3));
      expect((blocks[1] as ManualNote).spans, [const ManualSpan('Sin señal también anda.')]);
    });

    test('el texto pegado después de una lista es un párrafo nuevo', () {
      final blocks = ManualMarkdownParser.parseBlocks('- a\nTexto suelto');

      expect(blocks[0], isA<ManualList>());
      expect(blocks[1], isA<ManualParagraph>());
    });
  });

  group('ManualMarkdownParser.parseInline', () {
    test('separa la negrita del texto normal', () {
      expect(ManualMarkdownParser.parseInline('Tocá **Leer** y después **Cerrar**.'), [
        const ManualSpan('Tocá '),
        const ManualSpan('Leer', isBold: true),
        const ManualSpan(' y después '),
        const ManualSpan('Cerrar', isBold: true),
        const ManualSpan('.'),
      ]);
    });

    test('un ** sin cerrar queda como texto', () {
      expect(ManualMarkdownParser.parseInline('2 ** 3'), [const ManualSpan('2 ** 3')]);
    });

    test('negrita en títulos y en ítems de lista', () {
      final blocks = ManualMarkdownParser.parseBlocks('## Con **negrita**\n- **Inicio**: el resumen');

      expect((blocks[0] as ManualHeading).spans.last, const ManualSpan('negrita', isBold: true));
      expect((blocks[1] as ManualList).items.single.first, const ManualSpan('Inicio', isBold: true));
    });
  });
}
