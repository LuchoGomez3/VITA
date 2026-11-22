# Revisión QA/técnica Flutter

Actuá como revisor senior de calidad y comportamiento Flutter/Dart para VITA.

Rama a revisar: `<RAMA>`  
Base de comparación: `origin/develop`

Esta guía complementa la revisión de arquitectura. No repitas una auditoría de
ubicación y responsabilidades archivo por archivo: concentrá el análisis en los
flujos afectados y en fallos observables de ejecución, datos, lifecycle,
rendimiento, offline-first y experiencia de usuario.

No modifiques archivos, no ejecutes comandos que alteren el working tree, no
hagas commits, no hagas push, no abras PR, no hagas fetch y no cambies de rama.

## Instrucciones aplicables

Antes de revisar:

1. Leé completamente `AGENTS.md` y `mobile/AGENTS.md`.
2. Leé cualquier `AGENTS.md` más específico aplicable al diff.
3. Si el cambio toca `mobile/lib/brick/`, leé completamente
   `mobile/lib/brick/README.md`.
4. Indicá exactamente qué archivos de instrucciones utilizaste.

## Objetivo

Encontrá regresiones y defectos reales introducidos o hechos alcanzables por la
rama antes de abrir una PR hacia `develop`.

Priorizá:

- resultados incorrectos;
- crashes y excepciones no controladas;
- pérdida, duplicación o corrupción de datos;
- divergencias entre UI, SQLite y backend;
- operaciones que dejan de funcionar sin conexión;
- fallas al recuperar conectividad;
- carreras, callbacks tardíos y problemas de lifecycle;
- fugas o recursos que permanecen activos;
- degradaciones de rendimiento relevantes;
- estados de UI sin salida o sin recuperación;
- código, mocks, flags, assets o datos de demostración que hayan sobrevivido a
  una rama temporal o de presentación.

No conviertas esta revisión en una lista de preferencias de estilo o en una
segunda revisión de arquitectura. Si una mala separación de responsabilidades
causa un bug concreto, reportá el comportamiento defectuoso y mencioná la causa
arquitectónica sin duplicar el finding.

## Alcance y método obligatorio

Usá el merge-base y el diff completo:

```text
git diff origin/develop...<RAMA>
```

Si el checkout actual es otra rama, inspeccioná el target mediante `git diff`,
`git show`, `git grep`, `git log` y comandos equivalentes de solo lectura. No
atribuyas al target resultados de tests o análisis ejecutados sobre otro
checkout.

Antes de buscar bugs:

1. Informá los hashes de base, target y merge-base.
2. Enumerá todos los archivos `A/M/D` y la cantidad total.
3. Leé todos los hunks del diff.
4. Identificá qué comportamientos y recorridos del usuario cambia cada grupo de
   modificaciones.
5. Inspeccioná el código adyacente necesario para recorrer esos flujos de punta
   a punta, aunque no esté en el diff.
6. Inspeccioná los tests existentes para conocer contratos, casos esperados y
   huecos de cobertura.
7. Revisá el historial de commits de la rama cuando el origen del cambio sea
   relevante para detectar código recuperado o accidental.

No es obligatorio leer completo cada archivo que aparezca en el diff si el
contenido no modificado no interviene en el comportamiento analizado. Sí es
obligatorio cubrir todos los hunks y seguir cada flujo relevante hasta sus
efectos observables.

## Inventario de flujos afectados

Antes de emitir findings, construí una lista breve de los flujos modificados.
Para cada uno determiná:

- disparador: acción del usuario, lifecycle, sync, timer o evento externo;
- precondiciones;
- estado inicial local y remoto;
- componentes que participan;
- lecturas y escrituras;
- estados intermedios visibles;
- resultado exitoso esperado;
- errores y recuperación;
- comportamiento offline;
- comportamiento al reconectar;
- posibilidad de acciones concurrentes o repetidas;
- pruebas que lo cubren.

Usá como guía, cuando corresponda:

```text
acción/evento
  → page/widget
  → bloc/cubit
  → use case
  → repository/data source/store
  → SQLite/secure storage/cola/HTTP/dispositivo
  → reconciliación
  → nuevo estado de UI
```

La unidad principal de esta revisión es el flujo, no el archivo.

## Estándar de evidencia

Un finding confirmado debe demostrar:

1. Qué condición concreta lo activa.
2. Qué camino sigue el código.
3. Qué resultado produce actualmente.
4. Por qué ese resultado es incorrecto.
5. Por qué las validaciones, guards o tests existentes no lo evitan.
6. Qué parte fue introducida o profundizada por el diff.

No reportes como bug confirmado:

- algo que solamente “podría” pasar sin un camino de ejecución identificable;
- una preferencia de implementación;
- una optimización sin impacto razonable;
- una capacidad futura que no pertenece a la historia;
- deuda que ya existe igual en `origin/develop`;
- ausencia de test sin explicar qué regresión concreta queda desprotegida.

Si el análisis estático no alcanza para confirmar el comportamiento, movelo a
“Riesgos a validar manualmente” e indicá la prueba exacta necesaria.

## Áreas de revisión

### 1. Corrección funcional y datos

Buscá:

- ramas lógicas incorrectas o inalcanzables;
- estados que se aceptan pero luego no se pueden representar;
- `null`, listas vacías, valores desconocidos y datos legacy;
- defaults silenciosos que convierten datos inválidos en datos válidos;
- pérdida de campos al mapear entre dominio, DTO, Brick y backend;
- enums o códigos que no coinciden entre mobile y backend;
- filtros que incluyen o excluyen registros incorrectos;
- ordenamientos inestables;
- selección del registro equivocado ante duplicados;
- fechas locales/UTC, cambios de día o mes y timestamps fuera de orden;
- redondeos, precisión y unidades incorrectas;
- identidad equivocada entre UUID de negocio y PK local;
- resultados parciales presentados como completos;
- operaciones idempotentes que dejan de serlo al repetirse;
- errores asociados a una entidad o establecimiento equivocado.

Contrastá el comportamiento con schemas, endpoints y tests backend cuando el
diff modifica un contrato compartido.

### 2. Offline-first, persistencia y sincronización

Para cada escritura afectada reconstruí:

```text
intención del usuario
  → validación
  → escritura local durable
  → actualización inmediata de UI
  → encolado
  → reintento
  → respuesta backend
  → confirmación/rechazo
  → reconciliación local
```

Verificá:

- que guardar no dependa de conectividad ni de una respuesta remota;
- que la escritura local ocurra antes del request;
- que cerrar o reiniciar la app no pierda operaciones pendientes;
- que la cola conserve payload, método, ruta e identidad correctos;
- idempotencia ante reintentos o respuestas duplicadas;
- qué ocurre con 4xx, 401, 409, 5xx, timeout y ausencia de red;
- que los rechazos no queden eternamente como loading o pending;
- reconexión repetida o conectividad intermitente;
- sync manual y automático ejecutándose simultáneamente;
- pull remoto mientras existen cambios locales pending/rejected;
- last-write-wins y timestamps iguales, viejos o fuera de orden;
- tombstones y soft deletes;
- altas creadas y eliminadas antes del primer sync;
- atomicidad de operaciones sobre varias tablas o entidades;
- registros huérfanos después de un fallo parcial;
- deduplicación por UUID y conservación de datos locales aún no confirmados;
- diferencias entre una capacidad de lectura offline y una de escritura
  offline.

Para lecturas verificá que la pantalla pueda renderizar con la última caché
conocida, con caché vacía y con datos parcialmente hidratados.

### 3. Lifecycle, concurrencia y asincronía

Revisá:

- `TextEditingController`, `ScrollController`, `AnimationController`,
  `FocusNode`, timers y listeners sin `dispose`;
- `StreamSubscription` sin cancelación;
- clientes o recursos creados localmente cuyo ownership no esté definido;
- callbacks que sobreviven al widget, bloc o sesión que los creó;
- `setState`, emisión o navegación después de `dispose`/`close`;
- futures sin cancelación lógica cuyos resultados llegan fuera de orden;
- respuestas anteriores que pisan una búsqueda, filtro o selección más nueva;
- dos submits, taps rápidos o eventos duplicados;
- operaciones simultáneas que actualizan la misma entidad;
- subscriptions creadas más de una vez por rebuild;
- `BlocProvider.value` usado para instancias creadas localmente;
- blocs/cubits que no cierran recursos internos;
- cambio de establecimiento, logout o navegación durante una operación;
- uso de `BuildContext` después de un `await` sin verificar vigencia;
- errores asíncronos que quedan fuera del manejo del bloc/cubit.

No declares una fuga de memoria sin identificar el recurso, quién mantiene la
referencia y el punto donde debería liberarse.

### 4. Estado de UI, navegación y recuperación

Recorré, como mínimo:

- initial;
- loading;
- data;
- empty;
- error recuperable;
- error no recuperable;
- retry;
- refresh;
- navegación hacia atrás y retorno a la pantalla;
- cambio de parámetros o establecimiento;
- reentrada al flujo después de éxito o error.

Buscá:

- loaders infinitos;
- pantalla vacía sin explicación;
- errores que desaparecen antes de ser visibles;
- snackbars o navegación duplicados por rebuild;
- rutas o parámetros incorrectos;
- uso de pantallas ya desmontadas;
- acciones habilitadas durante operaciones incompatibles;
- formularios que pierden información tras un error;
- éxito mostrado antes de tener persistencia local durable;
- retry que repite efectos ya aplicados;
- UI que conserva datos de otro animal, lote o establecimiento;
- inconsistencias entre filtros, conteos y detalle.

### 5. Rendimiento y uso de recursos

Buscá impacto razonable para los volúmenes esperados de VITA:

- rebuilds de subárboles amplios ante cambios pequeños;
- selectors inexistentes o estados demasiado grandes;
- lectura de SQLite, secure storage o red durante `build`;
- consultas repetidas por item o patrón N+1;
- múltiples recorridos evitables sobre colecciones grandes;
- búsquedas `contains` sobre listas dentro de loops relevantes;
- algoritmos cuadráticos en animales, pesajes o movimientos;
- ordenamientos repetidos;
- cálculos pesados en el isolate principal;
- deserialización o procesamiento de imágenes en UI;
- listas grandes construidas eager en lugar de builder/slivers;
- imágenes sin dimensiones, cache o límites;
- listeners globales que actualizan más UI de la necesaria;
- polling, timers o retries demasiado frecuentes;
- crecimiento sin límite de cachés, colecciones o streams.

No reportes microoptimizaciones. Explicá el volumen o la frecuencia que vuelve
relevante el problema.

### 6. UX, accesibilidad y condiciones de campo

Verificá:

- feedback inmediato de acciones;
- loading y progreso comprensibles;
- empty states útiles;
- mensajes que expliquen el error y cómo recuperarse;
- distinción entre error de validación, conflicto, rechazo y falta de red;
- prevención o confirmación de acciones destructivas;
- conservación de datos ingresados;
- targets táctiles adecuados;
- labels y semántica para lectores de pantalla;
- contraste y legibilidad;
- teclado, foco y scroll en formularios;
- funcionamiento con conexión lenta o inexistente;
- flujos utilizables en campo sin información técnica innecesaria;
- acciones críticas disponibles mediante RFID y entrada manual cuando aplique.

### 7. Multi-tenant, sesión y privacidad

Buscá:

- datos de otro establecimiento en listas, conteos, detalle o caché;
- requests construidos con el establecimiento equivocado;
- resultados tardíos de la sesión anterior;
- cambio de establecimiento sin limpiar o volver a filtrar estado visible;
- logout que borra datos offline que deberían conservarse;
- 401 que elimina más información de la necesaria;
- roles desconocidos tratados como autorizados;
- IDs relacionados pertenecientes a tenants distintos;
- secretos, tokens o datos identificables en logs, fixtures o código.

Las validaciones mobile son UX y defensa local; no deben considerarse reemplazo
de autorización backend o RLS.

### 8. Manejo de errores y observabilidad

Verificá:

- excepciones absorbidas;
- `catch` demasiado amplios que pierden códigos útiles;
- fallbacks que convierten corrupción o errores de contrato en datos vacíos;
- errores técnicos expuestos directamente al usuario;
- errores críticos sin log;
- logs sin stack trace cuando sería necesario;
- datos sensibles en logs;
- resultados con forma de éxito después de una escritura parcial;
- retries aplicados a errores funcionales no reintentables;
- errores reintentables marcados definitivamente como rechazados.

### 9. Persistencia, migraciones y compatibilidad

Cuando cambien modelos persistidos revisá:

- instalación limpia;
- upgrade desde la versión inmediatamente anterior;
- upgrade con filas reales anteriores, nulls y duplicados;
- schema, adapter y migración coherentes;
- defaults para filas legacy;
- downgrade cuando corresponda;
- datos desconocidos futuros;
- columnas agregadas sin pérdida de datos;
- índices, unicidad y costo de consultas relevantes;
- cambios de nombre interpretados correctamente y no como drop/add accidental;
- archivos generados sincronizados con su fuente.

### 10. Tests y capacidad de detectar regresiones

No evalúes solamente cuántos tests se agregaron. Determiná si fallarían ante el
bug que deberían prevenir.

Buscá:

- tests que solo verifican tipos o valores triviales;
- mocks que devuelven siempre éxito;
- `noSuchMethod` o `dynamic` que ocultan llamadas nuevas;
- ausencia de verificación de efectos secundarios;
- pruebas que no comprueban que una escritura fue encolada;
- tests offline que nunca simulan una falla de red;
- tests de retry sin duplicación;
- tests de migración con una tabla irrealmente mínima;
- falta de escenarios de concurrencia o resultados fuera de orden;
- fixtures que no respetan tenant, timestamps o estados reales;
- tests que pasan aunque la UI quede en loading o muestre datos obsoletos;
- dependencias de orden entre archivos de test o singletons no reseteados.

Reportá cobertura faltante solamente cuando puedas nombrar la regresión
concreta que quedaría sin detectar.

### 11. Restos de ramas de demo o presentación

Cuando el contexto indique que el código fue recuperado de una rama temporal,
buscá específicamente:

- mocks conectados en runtime;
- fixtures o IDs hardcodeados;
- URLs, tokens o configuración temporal;
- feature flags forzados;
- delays artificiales;
- datos falsos usados como fallback exitoso;
- navegación directa para saltar flujos reales;
- assets pesados o no utilizados;
- comentarios o TODOs que describan comportamiento de demo;
- servicios reales reemplazados por implementaciones en memoria;
- manejo de errores relajado para que una presentación siempre continúe;
- dependencias agregadas solo para la demo.

No reportes algo por provenir de esa rama: demostrale impacto en runtime,
configuración, tamaño, tests o mantenibilidad del cambio actual.

## Severidad

### Bloqueante

- crash en un flujo principal;
- pérdida o corrupción de datos;
- aislamiento multi-tenant o privacidad comprometidos;
- escritura offline requerida que no funciona;
- migración que rompe instalaciones existentes;
- operación que queda irrecuperable o produce duplicados graves;
- regresión que impide completar el objetivo principal de la rama.

### Importante

- comportamiento incorrecto en un escenario realista;
- estado persistente divergente entre UI, SQLite y backend;
- retry, reconexión o lifecycle defectuoso;
- fuga de recursos demostrable;
- degradación relevante para volúmenes esperados;
- flujo confuso o sin recuperación que afecta una tarea habitual;
- cobertura ausente sobre un riesgo relevante introducido por el diff.

### Menor

- caso límite de bajo impacto;
- inconsistencia localizada de UX o accesibilidad;
- desperdicio de recursos acotado;
- cobertura faltante sobre un comportamiento no crítico;
- resto de demo sin impacto funcional inmediato pero que debe limpiarse.

No eleves severidad por una capacidad futura todavía no incluida en la historia,
salvo que el diseño nuevo impida un requisito ya confirmado.

## Formato de entrega

### Alcance revisado

- hash de `origin/develop`;
- hash de `<RAMA>`;
- merge-base;
- cantidad y lista de archivos `A/M/D`;
- archivos de instrucciones utilizados;
- comandos de validación ejecutados y no ejecutados.

### Cobertura por flujo

Incluí una fila por cada flujo afectado, no por cada archivo:

| Flujo | Offline | Reconexión/retry | Error | Concurrencia/lifecycle | Tests | Resultado |
|-------|---------|------------------|-------|------------------------|-------|-----------|

Usá `Verificado`, `Problema`, `Riesgo` o `No aplicable`. La tabla debe mostrar
qué recorridos fueron analizados, pero no reemplaza la evidencia de los
findings.

### Hallazgos confirmados

Ordenalos por severidad. Para cada uno indicá:

- Severidad: Bloqueante / Importante / Menor
- Estado: Confirmado
- Archivo y línea aproximada
- Flujo afectado
- Precondiciones y escenario de reproducción
- Evidencia concreta y recorrido del código
- Resultado actual
- Resultado esperado
- Impacto para el usuario o los datos
- Parte introducida o profundizada por el diff
- Corrección sugerida dentro del alcance
- Test que debería detectar la regresión

### Riesgos a validar manualmente

Para cada riesgo indicá:

- por qué no puede confirmarse estáticamente;
- dispositivo, conectividad y datos necesarios;
- pasos exactos de validación;
- resultado esperado y señal de fallo.

Los riesgos no confirmados no deben presentarse como bugs ni bloquear por sí
solos la recomendación final.

### Cobertura faltante

Enumerá únicamente tests faltantes asociados a una regresión concreta. No
dupliques findings confirmados.

### Verificado sin problemas

Indicá los escenarios relevantes que fueron inspeccionados y no mostraron
defectos. No uses frases genéricas como “se revisó offline”; nombrá el flujo y
la condición comprobada.

### Limitaciones

Indicá:

- qué no se pudo ejecutar o validar;
- si no se hizo fetch;
- si el target no estaba checked out;
- si no se ejecutaron tests o análisis y por qué;
- qué conclusiones dependen solamente de análisis estático.

### Recomendación final

Elegí una:

- Aprobar
- Aprobar con cambios
- Bloquear hasta corregir

Justificá la recomendación exclusivamente con hallazgos confirmados y su
impacto. No bloquees por cantidad de observaciones, riesgos hipotéticos o deuda
preexistente.
