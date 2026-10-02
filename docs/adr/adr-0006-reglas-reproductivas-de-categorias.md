# ADR-0006 — Reglas de sexo y condición reproductiva en categorías y animales

- **Estado:** aceptado
- **Fecha:** 2026-10-01, revisado el 2026-10-02 (catálogo global)
- **Contexto:** VITA-173

## Contexto

Desde "Visualizar animal" el productor tiene que poder registrar si una hembra está
preñada, vacía o sin determinar, y cambiar la categoría de un animal. Hasta ahora
`animales.estado` mezclaba la situación del animal en el establecimiento (`activo`,
`vendido`, `muerto`, `baja`) y no había dónde guardar su condición reproductiva.
`categorias` solo tenía nombre y descripción, así que nada impedía asignarle `Vaca` a un
macho.

El nombre de una categoría no alcanza para saber qué admite: cada establecimiento puede
crear las suyas y nombrarlas como quiera, y una misma palabra se usa distinto según la
zona.

El catálogo real de categorías es el que usa el front: seis categorías con UUIDs fijos,
hardcodeados en mobile. Esas filas no existían en Supabase. Las cinco categorías
cargadas allí (`550e8400-…`, de dos establecimientos) son datos de prueba.

## Decisión

- `animales.estado_reproductivo` es una columna aparte de `estado`, con los valores
  `sin_determinar`, `vacia` y `prenada`, o `null` cuando no corresponde. Un animal puede
  estar `activo` y `prenada` a la vez.
- `categorias` gana dos atributos explícitos y obligatorios:
  - `sexo_permitido` (`macho`, `hembra` o `ambos`).
  - `permite_estado_reproductivo`, que por defecto es falso.

  Ninguna capa los infiere del nombre.
- La regla de compatibilidad sobre el **estado final** del animal es:
  - `null` siempre es válido.
  - Un macho no admite ninguna condición reproductiva.
  - `sin_determinar` vale para cualquier hembra, tenga o no categoría.
  - `vacia` y `prenada` exigen una hembra con una categoría que tenga
    `permite_estado_reproductivo`.
  - La categoría, si hay, tiene que admitir el sexo del animal.
- La regla se aplica en las tres vías de escritura: alta, edición y reenvío de
  sincronización. Si una solicitud cambia categoría y condición, se valida la combinación
  resultante. Si es inválida, se rechaza completa, sin cambios parciales y sin corregir
  nada automáticamente: pasar una hembra preñada a una categoría que no admite condición
  exige mandar `estado_reproductivo: null` en la misma solicitud.
- La base replica la regla con dos triggers, porque Supabase acepta escrituras directas
  que no pasan por la API:
  - `trg_animales_categoria_compatible` valida el animal contra su categoría.
  - `trg_categorias_reglas_compatibles` impide que cambiar las reglas de una categoría
    deje animales vivos incompatibles.

  El primero bloquea la fila de la categoría (`for share`) para que los dos no se crucen
  en escrituras concurrentes.
- **Catálogo global** (decisión de Ernesto, PO de animales, y Lucho, 2026-10-02: "las
  categorías están en el front"). La migración `20261001_02` siembra las seis categorías
  del front como globales (`establecimiento_id` null), con los mismos UUIDs que usa
  mobile. Si alguna ya existe no la duplica; si existe sin reglas, la clasifica:

  | Categoría | `sexo_permitido` | `permite_estado_reproductivo` |
  | --- | --- | --- |
  | Ternera | `hembra` | no |
  | Ternero | `macho` | no |
  | Vaquillona | `hembra` | sí |
  | Vaca | `hembra` | sí |
  | Novillo | `macho` | no |
  | Toro | `macho` | no |

  Las globales se leen y se asignan desde cualquier establecimiento, pero ninguno puede
  editarlas ni borrarlas.
- **Datos de prueba heredados.** Las cinco categorías de Supabase se clasifican por id
  para que la migración no se corte con los datos actuales:
  - Ternero de prueba (`…440030`): `ambos`, porque tiene 2 hembras asignadas.
  - Engorde Rápido (`…440034`): `ambos`.
  - Novillo y Toro de prueba: `macho`.
  - Vaca de prueba: `hembra`, con condición reproductiva habilitada.

  El script SQL trae un paso de limpieza manual, opcional e idempotente, que viene
  comentado: mueve las hembras del Ternero de prueba a la Ternera global y borra
  lógicamente Engorde Rápido si no tiene animales.
- La migración no asigna `ambos` por defecto. Si encuentra una categoría fuera de la
  tabla de clasificación, o un animal vivo incompatible con ella, se detiene y lista los
  casos para resolverlos a mano.

## Consecuencias

- El catálogo de categorías expone `sexo_permitido` y `permite_estado_reproductivo`, y
  mobile puede ofrecer solo las opciones compatibles.
- Crear una categoría exige `sexo_permitido`. El reenvío de un alta ya registrada que no
  lo trae (cliente anterior a este cambio) conserva el valor guardado. Lo mismo pasa
  con `estado_reproductivo` en el reenvío del alta de un animal: omitirlo no lo borra.
- Una escritura offline encolada antes de este cambio con una combinación que ahora es
  inválida recibe 422 al sincronizar. Mobile tiene que mostrar el error y dejar
  corregirla.
- Asignar una categoría eliminada lógicamente se rechaza. Una que se borró después de
  asignarse no traba la edición de otros campos del animal.
- Un animal borrado no bloquea cambiar las reglas de su categoría, pero restaurarlo
  vuelve a validarlo.
- Mobile nunca upsertea las categorías globales: solo las usa como `categoria_id`. Si
  reenviara una por `POST /categorias`, el backend responde 403
  `categoria_global_no_editable` y no la modifica. Se decidió no relajar esa validación de
  permisos porque ningún flujo lo necesita.
- `categorias` y `animales` tienen hoy RLS activo y ninguna policy en Supabase: los
  clientes directos por PostgREST no ven nada, y solo el backend accede. Este ADR no
  agrega policies, porque abrirían un acceso que hoy no existe. Si algún cliente llega a
  leer directo, hará falta una policy de lectura para las globales y las propias.
- El downgrade de `20261001_02` conserva el catálogo sembrado: puede haber animales que
  ya lo referencian.
- La migración tiene que aplicarse **antes** de desplegar el backend: `create_all` no
  agrega columnas a tablas existentes, y el código nuevo las lee.
