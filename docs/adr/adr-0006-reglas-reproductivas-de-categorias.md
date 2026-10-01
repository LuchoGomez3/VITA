# ADR-0006 — Reglas de sexo y condición reproductiva en categorías y animales

- **Estado:** aceptado
- **Fecha:** 2026-10-01
- **Contexto:** VITA-173

## Contexto

Desde "Visualizar animal" el productor tiene que poder registrar si una hembra está
preñada, vacía o sin determinar, y cambiar la categoría de un animal. Hasta ahora
`animales.estado` mezclaba la situación del animal en el establecimiento (`activo`,
`vendido`, `muerto`, `baja`) y no había dónde guardar su condición reproductiva.
`categorias` solo tenía nombre y descripción, así que nada impedía asignarle `Vaca` a un
macho.

El nombre de una categoría no alcanza para saber qué admite: cada establecimiento crea
las suyas y las nombra como quiere ("Engorde Rápido" no dice nada del sexo), y una misma
palabra se usa distinto según la zona.

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
- Las categorías existentes se clasificaron a mano, por id, en la migración
  `20261001_02`:

  | Categoría | `sexo_permitido` | `permite_estado_reproductivo` |
  | --- | --- | --- |
  | Ternero | `ambos` | no |
  | Novillo | `macho` | no |
  | Vaca | `hembra` | sí |
  | Toro | `macho` | no |
  | Engorde Rápido | `ambos` | no |

  **Ternero admite ambos sexos** porque en el campo "ternero" nombra a machos y hembras
  sin destete, y la categoría ya tiene hembras asignadas. No habilita condición
  reproductiva porque un ternero no se preña. **Engorde Rápido** es una categoría por
  destino productivo, no por sexo.
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
- La migración tiene que aplicarse **antes** de desplegar el backend: `create_all` no
  agrega columnas a tablas existentes, y el código nuevo las lee.
