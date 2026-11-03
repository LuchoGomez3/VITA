import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:meta/meta.dart';

/// Roles que existen hoy en la base (`ck_usuarios_establecimientos_rol`).
///
/// Una sección que los cubre a todos es "general": se muestra siempre, incluso
/// sin un rol conocido.
const Set<UserRole> manualRoles = {UserRole.owner, UserRole.admin, UserRole.employee};

/// Tramo de texto de un bloque, con o sin negrita.
@immutable
class ManualSpan {
  /// Crea un tramo.
  const ManualSpan(this.text, {this.isBold = false});

  /// Texto del tramo.
  final String text;

  /// Si va en negrita (`**así**` en el markdown).
  final bool isBold;

  @override
  bool operator ==(Object other) => other is ManualSpan && other.text == text && other.isBold == isBold;

  @override
  int get hashCode => Object.hash(text, isBold);

  @override
  String toString() => isBold ? '**$text**' : text;
}

/// Bloque del subconjunto de markdown que entiende el manual.
@immutable
sealed class ManualBlock {
  const ManualBlock();
}

/// Título `#`, `##` o `###`.
final class ManualHeading extends ManualBlock {
  /// Crea un título de nivel [level] (1 a 3).
  const ManualHeading({required this.level, required this.spans});

  /// Nivel del título, de 1 (`#`) a 3 (`###`).
  final int level;

  /// Texto del título.
  final List<ManualSpan> spans;
}

/// Párrafo de texto corrido.
final class ManualParagraph extends ManualBlock {
  /// Crea un párrafo.
  const ManualParagraph(this.spans);

  /// Texto del párrafo.
  final List<ManualSpan> spans;
}

/// Lista con viñetas (`-`) o numerada (`1.`).
final class ManualList extends ManualBlock {
  /// Crea una lista.
  const ManualList({required this.items, this.isOrdered = false, this.start = 1});

  /// Ítems de la lista, cada uno con su texto.
  final List<List<ManualSpan>> items;

  /// Si es numerada.
  final bool isOrdered;

  /// Número del primer ítem de una lista numerada.
  final int start;
}

/// Cita `>`, que el manual muestra como nota destacada.
final class ManualNote extends ManualBlock {
  /// Crea una nota.
  const ManualNote(this.spans);

  /// Texto de la nota.
  final List<ManualSpan> spans;
}

/// Una sección del manual (un archivo de `assets/manual/`).
@immutable
class ManualSection {
  /// Crea una sección.
  const ManualSection({
    required this.id,
    required this.title,
    required this.roles,
    required this.blocks,
    this.summary = '',
  });

  /// Identificador estable: el nombre del archivo sin `.md`.
  final String id;

  /// Título de la sección.
  final String title;

  /// Una línea que explica de qué trata, para el índice.
  final String summary;

  /// Roles para los que aplica.
  final Set<UserRole> roles;

  /// Contenido de la sección.
  final List<ManualBlock> blocks;

  /// Si aplica a todos los roles (y por eso se muestra siempre).
  bool get isGeneral => roles.containsAll(manualRoles);

  /// Si aplica a alguno de [userRoles].
  bool appliesToAny(Set<UserRole> userRoles) => roles.any(userRoles.contains);
}

/// Manual filtrado para la persona que lo lee.
@immutable
class UserManual {
  /// Crea el manual.
  const UserManual({required this.sections, required this.userRoles});

  /// Secciones que la persona puede usar, en el orden del manual.
  final List<ManualSection> sections;

  /// Roles de la persona en sus establecimientos; vacío si no se conocen.
  final Set<UserRole> userRoles;
}
