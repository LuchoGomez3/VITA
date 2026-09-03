# ADR-0001 — La venta de hacienda se modela separada de los egresos

- **Estado:** aceptado
- **Fecha:** 2026-09-02
- **Contexto Linear:** [VITA-127](https://linear.app/utn-frc-proyecto-final/issue/VITA-127), bajo la historia VITA-43
- **Decide:** Lucho (Backend / ML / Infra)
- **Requiere validación del Product Owner:** sí (ver "Pendiente de validación")

## Contexto

Hasta ahora no existía forma de persistir la venta de un animal. El backend tenía un
modelo `Egreso` / `EgresoDetalle` con `TipoEgreso.venta`, `comprador_texto`,
`peso_total_kg` y `precio_total`, pero era un esqueleto huérfano: sin router, service,
repository ni schemas, sin tabla creada en Supabase y sin ningún código que lo
referenciara. El mobile tampoco lo consumía.

En paralelo, el PR #44 incorporó `egresos_operativos` (movimientos de caja) y fijó por
escrito que `egresos` representa "salidas físicas de animales". Quedaron entonces tres
conceptos distintos compitiendo por la palabra *egreso*, y uno de ellos —`TipoEgreso.venta`—
solapado con la operación comercial que VITA-43 pide registrar.

La historia VITA-43 exige datos que el modelo `Egreso` no contempla: tipo de comprador
(frigorífico / remate / particular), nombre y apellido del comprador, número de DTe,
modalidad de venta (por kilo o al bulto) y el desglose peso × precio por kilo.

## Decisión

**1. La venta es una entidad propia.** Se crean `ventas` y `ventas_detalles`, nuevas e
independientes, en el módulo `api/modules/ventas/`.

**2. `egresos` se conserva y pierde el valor `venta`.** `TipoEgreso` queda como
`muerte | baja | traslado_externo`: salidas físicas **no comerciales**. Se le quita el
`default=TipoEgreso.venta` a `Egreso.tipo`, porque el motivo de una salida siempre es una
decisión explícita. No se elimina el módulo ni se migran datos: no hay ninguno.

La frontera queda así:

| Concepto | Tabla | Qué registra |
| --- | --- | --- |
| Venta de hacienda | `ventas` | operación comercial: comprador, DTe, monto |
| Salida física no comercial | `egresos` | muerte, baja, traslado externo |
| Movimiento de caja | `egresos_operativos` | gastos e insumos del campo |

**3. `nro_dte` es nullable.** El Documento de Tránsito electrónico lo emite SENASA y suele
generarse *después* de cerrar el trato. Exigirlo en el esquema rompería el escenario 3 de
VITA-43 (venta cerrada en el campo sin señal). Si la operación necesita el DTe como
obligatorio en algún flujo, esa es una regla del service o de la UI, no del esquema.

**4. El comprador no siempre es una persona.** `nombre_comprador` es obligatorio y no vacío
y contiene la razón social o el nombre de pila; `apellido_comprador` es nullable, porque un
frigorífico o un remate no tiene apellido. El ticket original los pedía a ambos `NOT NULL`.

**5. `ventas_detalles` no se sincroniza por separado.** Hereda solo de `Base`, sin
`SoftDeleteMixin`: la venta es un agregado atómico y sus detalles viajan dentro de su
payload. Mismo criterio que `exportaciones_senasa_animales`.

## El módulo económico pasa a estar dentro de alcance

`ventas` persiste `monto_total`, `precio_por_kg` y `peso_total_kg`. Hasta ahora CLAUDE.md
traía una restricción dura que prohibía "cualquier módulo económico/de precios
(scraping Rosgan/Liniers, tasador de rodeo, simulador de venta)". Esa restricción quedó
desactualizada: `egresos_operativos` ya es un módulo económico, `ventas` es el otro lado
del mismo flujo, y el equipo confirmó que el producto sí va a tener módulo económico,
alimentado por ventas y por una futura API de precios.

La restricción se levantó en este mismo cambio. Quedan dentro de alcance:

- Registro de operaciones (ventas, egresos operativos) y balance / flujo de caja / margen bruto.
- Valuación del stock en pesos.
- Cotizaciones de mercado externas (Rosgan/Liniers) y la `MercadoScreen` ya diseñada.
- Simulación y proyección de ventas.

Sigue prohibido el blockchain, y sigue vigente offline-first — que en este módulo tiene una
implicancia concreta: **una cotización externa es una mejora, nunca una precondición**. La
venta se registra, el balance se muestra y las pantallas renderizan con la última cotización
cacheada o sin ninguna. Un flujo económico que exija conectividad al feed de precios para
funcionar es una violación de offline-first, no una decisión de producto.

Archivos actualizados junto con este ADR: `CLAUDE.md`, `AGENTS.md`,
`.claude/skills/backend-code-review/SKILL.md` y `.claude/specs/estado-pantallas-diseno.md`
(que bloqueaba `MercadoScreen` y ahora la lista como pendiente sin spec).

Como corolario, el `mockStockValue = '$ 8.450.000'` del dashboard
(`mobile/lib/features/home/presentation/strings/home_strings.dart`) deja de ser deuda por
contradecir una restricción: ahora es simplemente un valor mockeado a la espera de su
fuente de datos real.

## Consecuencias

- VITA-135 puede construir el módulo backend (schemas, repository, service, router) sobre
  una estructura ya migrada, y VITA-138 el modelo Brick del mobile.
- La transición de `Animal.estado` a `vendido` debe hacerse transaccionalmente al crear la
  venta (VITA-135). Hoy `estado` se edita suelto por `PUT /animales/{id}` sin validación de
  transición, y el modelo Brick del mobile ni siquiera lo mapea: son dos huecos abiertos.
- `egresos` sigue sin API. Si el producto necesita registrar muertes o bajas, hay que
  implementarlo; este ADR solo delimita su alcance.
- Agregar un valor a `TipoVenta` o `TipoComprador` ahora requiere migración, porque las
  restricciones `CHECK` los replican en la base. `test_enums_coinciden_entre_modelo_migracion_y_script`
  falla si el enum de Python, la migración y el script SQL se desalinean.

## Alternativas descartadas

- **Extender `Egreso` con los campos comerciales.** Habría mezclado en una tabla la muerte
  de un animal y una operación de venta, con la mitad de las columnas siempre nulas, y
  obligado a validaciones condicionales por `tipo` en cada consulta.
- **Eliminar el módulo `egresos`.** Era gratis técnicamente (sin API, sin tabla, sin datos),
  pero habría dejado sin modelo a muerte, baja y traslado externo, y contradice la frontera
  que el equipo acababa de fijar por escrito en el PR #44.

## Pendiente de validación

- **Product Owner (Ernesto):** que `nro_dte` sea opcional en el esquema. VITA-127 toca
  SENASA 530/2025, así que la Definition of Done exige validación explícita del PO.
- **Franco (autor del ticket):** VITA-127 declaraba `nro_dte` y `apellido_comprador` como
  obligatorios y ponía `egresos` fuera de alcance. Ambas cosas cambiaron; VITA-135 arrastra
  las mismas restricciones en su descripción y conviene ajustarlas.
