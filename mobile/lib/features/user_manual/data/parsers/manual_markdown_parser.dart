import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';

/// Lee una sección del manual: un front-matter simple y un subconjunto de
/// markdown.
///
/// Formato del archivo:
///
/// ```text
/// ---
/// titulo: Registrar pesajes
/// resumen: Una línea para el índice (opcional).
/// roles: owner, admin, employee
/// ---
/// ## Subtítulo
/// Texto con **negrita**.
/// ```
///
/// Del markdown entiende títulos `#`/`##`/`###`, párrafos, listas con `-` (o
/// `*`) y numeradas (`1.`), `**negrita**` y citas `>`, que se muestran como
/// notas. Cualquier otra cosa se toma como texto.
abstract final class ManualMarkdownParser {
  static final _heading = RegExp(r'^(#{1,6})\s+(.*)$');
  static final _bullet = RegExp(r'^[-*]\s+(.*)$');
  static final _ordered = RegExp(r'^(\d+)\.\s+(.*)$');
  static final _quote = RegExp(r'^>\s?(.*)$');

  /// Arma la sección [id] a partir del contenido de su archivo.
  ///
  /// Tira [FormatException] si falta el front-matter, el título o los roles, o
  /// si un rol no es `owner`, `admin` ni `employee`: un error de tipeo no
  /// tiene que esconder una sección en silencio.
  static ManualSection parseSection(String id, String source) {
    final lines = source.replaceAll('\r\n', '\n').split('\n');
    if (lines.isEmpty || lines.first.trim() != '---') {
      throw FormatException('La sección "$id" no empieza con el front-matter (---).');
    }
    final end = lines.indexWhere((line) => line.trim() == '---', 1);
    if (end == -1) {
      throw FormatException('La sección "$id" no cierra el front-matter (---).');
    }

    final fields = <String, String>{};
    for (final line in lines.sublist(1, end)) {
      if (line.trim().isEmpty) continue;
      final colon = line.indexOf(':');
      if (colon == -1) {
        throw FormatException('Línea inválida en el front-matter de "$id": $line');
      }
      fields[line.substring(0, colon).trim().toLowerCase()] = line.substring(colon + 1).trim();
    }

    final title = fields['titulo'] ?? '';
    if (title.isEmpty) {
      throw FormatException('La sección "$id" no tiene titulo.');
    }
    return ManualSection(
      id: id,
      title: title,
      summary: fields['resumen'] ?? '',
      roles: parseRoles(id, fields['roles'] ?? ''),
      blocks: parseBlocks(lines.sublist(end + 1).join('\n')),
    );
  }

  /// Interpreta `roles: owner, admin, employee`.
  static Set<UserRole> parseRoles(String id, String value) {
    final roles = <UserRole>{};
    for (final raw in value.split(',')) {
      final name = raw.trim().toLowerCase();
      if (name.isEmpty) continue;
      final role = switch (name) {
        'owner' => UserRole.owner,
        'admin' => UserRole.admin,
        'employee' => UserRole.employee,
        _ => throw FormatException('Rol desconocido "$name" en la sección "$id".'),
      };
      roles.add(role);
    }
    if (roles.isEmpty) {
      throw FormatException('La sección "$id" no indica para qué roles aplica.');
    }
    return Set.unmodifiable(roles);
  }

  /// Convierte el cuerpo markdown en bloques.
  static List<ManualBlock> parseBlocks(String body) {
    final blocks = <ManualBlock>[];
    final paragraph = <String>[];
    final note = <String>[];
    final listItems = <String>[];
    var listOrdered = false;
    var listStart = 1;

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      blocks.add(ManualParagraph(parseInline(paragraph.join(' '))));
      paragraph.clear();
    }

    void flushNote() {
      if (note.isEmpty) return;
      blocks.add(ManualNote(parseInline(note.join(' '))));
      note.clear();
    }

    void flushList() {
      if (listItems.isEmpty) return;
      blocks.add(
        ManualList(
          items: List.unmodifiable(listItems.map(parseInline)),
          isOrdered: listOrdered,
          start: listStart,
        ),
      );
      listItems.clear();
    }

    void flushAll() {
      flushParagraph();
      flushNote();
      flushList();
    }

    for (final rawLine in body.replaceAll('\r\n', '\n').split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        flushAll();
        continue;
      }

      final heading = _heading.firstMatch(line);
      if (heading != null) {
        flushAll();
        final level = heading.group(1)!.length.clamp(1, 3);
        blocks.add(ManualHeading(level: level, spans: parseInline(heading.group(2)!.trim())));
        continue;
      }

      final quote = _quote.firstMatch(line);
      if (quote != null) {
        flushParagraph();
        flushList();
        final text = quote.group(1)!.trim();
        if (text.isEmpty) {
          // Un `>` solo separa párrafos dentro de la misma cita: se une.
          continue;
        }
        note.add(text);
        continue;
      }

      final bullet = _bullet.firstMatch(line);
      final ordered = bullet == null ? _ordered.firstMatch(line) : null;
      if (bullet != null || ordered != null) {
        flushParagraph();
        flushNote();
        final isOrdered = ordered != null;
        if (listItems.isNotEmpty && listOrdered != isOrdered) {
          flushList();
        }
        if (listItems.isEmpty) {
          listOrdered = isOrdered;
          listStart = isOrdered ? int.parse(ordered.group(1)!) : 1;
        }
        listItems.add((bullet ?? ordered)!.group(isOrdered ? 2 : 1)!.trim());
        continue;
      }

      if (listItems.isNotEmpty && rawLine.startsWith(RegExp(r'\s'))) {
        // Línea con sangría: continúa el último ítem.
        listItems[listItems.length - 1] = '${listItems.last} $line';
        continue;
      }
      if (note.isNotEmpty) {
        note.add(line);
        continue;
      }
      flushList();
      paragraph.add(line);
    }
    flushAll();
    return List.unmodifiable(blocks);
  }

  /// Separa `**negrita**` del texto normal. Un `**` sin cerrar queda como
  /// texto.
  static List<ManualSpan> parseInline(String text) {
    final spans = <ManualSpan>[];
    var index = 0;
    while (index < text.length) {
      final open = text.indexOf('**', index);
      final close = open == -1 ? -1 : text.indexOf('**', open + 2);
      if (open == -1 || close == -1) {
        spans.add(ManualSpan(text.substring(index)));
        break;
      }
      if (open > index) {
        spans.add(ManualSpan(text.substring(index, open)));
      }
      final bold = text.substring(open + 2, close);
      if (bold.isNotEmpty) {
        spans.add(ManualSpan(bold, isBold: true));
      }
      index = close + 2;
    }
    return List.unmodifiable(spans);
  }
}
