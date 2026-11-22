# Manual de usuario

Perfil → Sobre la app → **Manual de usuario**. Índice de secciones
(`UserManualPage`, ruta `/perfil/manual`) y detalle de cada una
(`UserManualSectionPage`, `/perfil/manual/seccion`, recibe la `ManualSection`
en `extra`; sin ella vuelve al índice).

## Contenido

Cada sección es un archivo `assets/manual/<id>.md`, empaquetado con la app: el
manual se lee sin conexión. La carpeta ya está declarada en `pubspec.yaml`.

```text
---
titulo: Registrar pesajes
resumen: Una línea para el índice.
roles: owner, admin, employee
---
## Subtítulo

1. Paso con **negrita**.

> Nota destacada (por ejemplo, qué pasa sin señal).
```

- `roles` acepta `owner`, `admin` y `employee` (los únicos que existen en la
  base, ver `docs/producto/roles.md`). Un rol mal escrito hace fallar el test de
  assets en vez de esconder la sección en silencio.
- Una sección con los tres roles es **general**: se muestra siempre. Las demás
  llevan la etiqueta "Para dueño y administrador", etc.
- El orden lo da `UserManualAssets.sections`
  (`data/repositories/user_manual_repository_impl.dart`). Para sumar una
  sección: crear el `.md` y agregarlo a esa lista.

Markdown soportado (render propio, sin dependencias): títulos `#`/`##`/`###`,
párrafos, listas `-`/`*` y numeradas, `**negrita**` y citas `>` como notas.

## Filtrado por rol

`GetUserManualUseCase` lee las membresías del catálogo offline
(`EstablishmentCatalog.getMemberships`). El rol es por establecimiento, así que
se muestra la unión de lo que aplica a cada rol de la persona. `veterinarian`
cuenta como `employee` (adr-0012). Sin rol conocido (catálogo vacío, ilegible o
roles `unknown`) quedan solo las secciones generales.
