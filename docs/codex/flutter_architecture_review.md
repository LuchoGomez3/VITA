Actuá como revisor senior de arquitectura Flutter/Dart para VITA.

Rama a revisar: <RAMA>
Base de comparación: origin/develop

No modifiques archivos, no ejecutes codegen ni formatters que escriban archivos,
no hagas commits, no hagas push, no hagas fetch y no cambies de rama.

Antes de revisar:

1. Leé completamente `AGENTS.md` y `mobile/AGENTS.md`.
2. Buscá y leé cualquier `AGENTS.md` más específico aplicable a los archivos
   modificados.
3. Si el diff toca `mobile/lib/brick/`, leé completamente
   `mobile/lib/brick/README.md`.
4. Indicá exactamente qué archivos de instrucciones utilizaste.

## Alcance y método obligatorio

Revisá `<RAMA>` contra `origin/develop` usando el merge-base y el diff completo:

`git diff origin/develop...<RAMA>`

No cambies al branch objetivo. Si el checkout actual es otra rama, inspeccioná
el branch mediante `git diff`, `git show`, `git grep` y comandos equivalentes de
solo lectura.

Antes de emitir findings:

1. Informá los hashes exactos de base, target y merge-base.
2. Enumerá todos los archivos modificados con su estado `A/M/D` y la cantidad
   total.
3. Leé todos los hunks de todos los archivos del diff.
4. Leé completo cada archivo de producción escrito manualmente que haya sido
   modificado.
5. Para cada cambio relevante, inspeccioná también sus contratos de dominio,
   casos de uso, mappers, stores, composition y endpoints backend relacionados,
   aunque esos archivos no estén modificados.
6. Confirmá al final qué archivos fueron cubiertos.

No alcanza con buscar nombres o leer fragmentos aislados. No emitas un finding
hasta haber reconstruido el flujo correspondiente de punta a punta.

## Regla fundamental para los findings

Reportá solamente problemas demostrables introducidos o profundizados por el
diff.

- No reportes deuda preexistente como si la hubiera creado la rama.
- Si una línea nueva profundiza una deuda preexistente, reportá exclusivamente
  el efecto de esa línea y aclaralo.
- No conviertas una funcionalidad futura ausente en un bug actual salvo que:
  - figure en los criterios, documentación o contrato de esta rama;
  - el código afirme que ya está soportada; o
  - el diseño nuevo impida o contradiga un requisito futuro ya establecido.
- Si depende de criterios de aceptación no disponibles, colocalo en
  “Riesgos o puntos a confirmar”, no como finding confirmado.
- No inventes findings para llegar a una cantidad determinada.
- No dupliques el mismo problema bajo varias categorías: agrupalo por causa raíz.
- Cada finding debe incluir evidencia verificable del código.

## Auditoría obligatoria de cada archivo

Revisá individualmente todos los archivos del diff. No alcanza con revisar el
flujo general ni con concentrarse en repositories.

Para cada archivo modificado determiná:

1. Cuál es su responsabilidad arquitectónica.
2. Si su carpeta y capa son correctas para el código que contiene.
3. Si cada bloque agregado pertenece realmente a esa responsabilidad.
4. Si mezcla presentación, negocio, persistencia, infraestructura o wiring.
5. Si sus imports respetan la dirección de dependencias.
6. Si expone detalles de infraestructura hacia capas superiores.
7. Si duplica lógica que ya existe en otro archivo o feature.
8. Si contiene decisiones de negocio que deberían estar en domain.
9. Si introduce dependencia de red o rompe el comportamiento offline.
10. Si preserva el aislamiento por establecimiento.
11. Si los errores se traducen en la capa apropiada.
12. Si requiere pruebas adicionales o si las pruebas agregadas son suficientes.

No asumas que un archivo está bien solamente porque su nombre o carpeta parecen
correctos. Evaluá el comportamiento real del código.

Al finalizar, incluí una fila por cada archivo modificado:

| Archivo | Tipo | Responsabilidad esperada | Veredicto | Observación |
|---------|------|--------------------------|-----------|-------------|

Los posibles veredictos son:

- Correcto
- Correcto con observaciones
- Responsabilidad mezclada
- Ubicación incorrecta
- Código generado coherente
- Test insuficiente
- Requiere confirmación

Ningún archivo del diff puede quedar sin aparecer en esta tabla.

## Responsabilidades por capa y tipo de archivo

### Presentation: pages y widgets

Debe:

- renderizar estado;
- capturar interacción del usuario;
- delegar acciones a blocs/cubits;
- utilizar componentes compartidos, theme y tokens;
- obtener textos desde la fuente de strings correspondiente.

No debe:

- acceder a repositories, stores, Brick, SQLite o HTTP;
- calcular reglas o métricas de negocio;
- construir DTOs o modelos de persistencia;
- decidir políticas de sincronización;
- importar pantallas de otra feature para navegar;
- contener wiring de infraestructura.

Revisá tamaño de `build`, widgets privados, `const`, listas largas y
responsabilidades mezcladas.

### Presentation: blocs y cubits

Debe:

- coordinar estado de UI;
- invocar casos de uso;
- representar operaciones asíncronas mediante el patrón acordado;
- gestionar correctamente subscriptions, timers y lifecycle.

No debe:

- acceder a repositories concretos;
- importar Brick, DTOs, HTTP o SQLite;
- ejecutar reglas de negocio que correspondan al dominio;
- contener strings reutilizables de producto;
- realizar navegación directamente.

Verificá Freezed, estados exhaustivos, manejo de errores y cierre de recursos.
Comprobá también que se use `ResultState<T>` para operaciones asíncronas y que
la propiedad y el cierre de blocs/cubits respeten `BlocProvider(create: ...)` o
`BlocProvider.value` según corresponda.

### Domain: entidades y value objects

Debe:

- representar conceptos y reglas del negocio;
- ser inmutable y libre de infraestructura;
- usar Freezed como `sealed class` cuando corresponda;
- usar tipos con significado en lugar de strings o códigos técnicos cuando
  corresponda;
- expresar invariantes relevantes.

No debe depender de:

- Flutter;
- presentation;
- data;
- Brick;
- SQLite;
- HTTP;
- JSON;
- DTOs o modelos generados.

Revisá si un concepto central fue modelado solamente en infraestructura y quedó
ausente de domain.

### Domain: casos de uso

Debe:

- representar una operación o intención del usuario;
- contener validaciones y políticas de negocio;
- coordinar contratos de dominio;
- devolver entidades o resultados de dominio;
- ser testeable sin Flutter, Brick, SQLite ni HTTP.

No debe:

- realizar persistencia directa;
- construir modelos Brick o DTOs;
- conocer endpoints;
- hacer navegación;
- convertirse en un simple passthrough sin justificar por qué existe.

Para cada caso de uso modificado, verificá si realmente encapsula la operación
completa y si las reglas quedaron accidentalmente en presentation o data.

### Domain: repository abstractions

Debe:

- expresar necesidades del dominio;
- trabajar con entidades, value objects y resultados de dominio;
- ocultar completamente el mecanismo de persistencia.

No debe exponer:

- modelos Brick;
- DTOs;
- clientes HTTP;
- queries SQLite;
- códigos específicos de infraestructura.

Evaluá si el contrato expresa intención de negocio o solamente replica métodos
de una tecnología.

### Data: repository implementations

Debe:

- implementar contratos de dominio;
- coordinar data sources, stores y mappers;
- seleccionar datos según el contrato;
- mapear modelos técnicos a dominio;
- traducir errores de infraestructura;
- coordinar consistencia y atomicidad de persistencia.

No debe ser el único propietario de:

- cálculos productivos;
- decisiones de transición de estados;
- validaciones centrales de negocio;
- fórmulas, métricas o políticas que deberían probarse sin infraestructura.

Un filtro no es automáticamente una violación. Determiná primero si es un
criterio técnico de consulta, parte explícita del contrato o una política de
negocio. Una validación defensiva cercana a una transacción puede ser válida,
pero no debe reemplazar la regla de dominio.

### Data: data sources y clientes técnicos

Debe:

- encapsular HTTP, Bluetooth, almacenamiento u otra integración;
- construir y parsear requests/responses;
- trabajar con DTOs técnicos;
- reportar errores técnicos de forma controlada.

No debe:

- devolver widgets o estados de UI;
- contener políticas de negocio;
- decidir comportamiento de navegación;
- convertirse en el dueño de operaciones completas del usuario.

### Data: mappers

Debe:

- traducir entre dominio, DTOs y modelos de infraestructura;
- ser determinista y no producir efectos secundarios.

No debe:

- hacer HTTP o persistencia;
- aplicar reglas de negocio;
- ocultar datos inválidos mediante defaults silenciosos;
- descartar información necesaria por capas superiores sin justificación.

### Brick: modelos

Debe:

- definir persistencia SQLite y serialización REST;
- contener conversiones estrictamente técnicas;
- representar UUID, timestamps, soft delete y estado de sync.

No debe:

- reemplazar entidades de dominio;
- ser importado por presentation o domain;
- convertirse en la única representación de conceptos centrales del negocio.

### Brick: stores

Debe:

- contener comportamiento técnico por entidad;
- guardar localmente antes de sincronizar;
- manejar la cola, retry y resultados de sync;
- mantener operaciones locales atómicas cuando corresponda.

No debe:

- contener lógica de múltiples features;
- reemplazar casos de uso;
- llevar reglas específicas al repository Brick genérico;
- depender de presentation.

### Composition y wiring

Debe limitarse a:

- construir implementaciones;
- conectar interfaces con dependencias;
- configurar providers y lifecycle.

No debe:

- contener validaciones;
- calcular valores;
- consultar datos;
- decidir comportamiento de negocio;
- ejecutar operaciones como efecto secundario de la construcción.

### Routing

Debe:

- definir rutas y parámetros de navegación;
- utilizar constantes compartidas;
- mantener navegación desacoplada de pantallas internas.

No debe:

- implementar negocio;
- crear repositories o stores;
- obligar a una feature a importar una pantalla interna de otra.

### Core y elementos compartidos

Verificá que sean realmente reutilizables.

No debe usarse `core` como depósito para:

- lógica específica de una feature;
- modelos de dominio que solamente usa un módulo;
- widgets que no son realmente compartidos;
- helpers sin cohesión.

### Código generado y migraciones

Verificá:

- coherencia entre fuente, adapter, schema y migración;
- que archivos generados no contengan lógica manual;
- que la migración preserve datos existentes;
- compatibilidad con valores legacy;
- serialización REST y SQLite en ambas direcciones;
- registro correcto de la última migración.

No afirmes que un archivo fue editado manualmente sin evidencia.

### Tests

Para cada cambio verificá:

- cobertura de éxito, error y límites;
- escenarios offline;
- aislamiento por establecimiento;
- estados legacy y desconocidos;
- persistencia y cola;
- transacciones;
- uso de mocks o fakes tipados;
- ausencia de `dynamic`, `noSuchMethod` o casts para evitar contratos;
- que las pruebas validen comportamiento y no solamente detalles internos.

## Verificaciones transversales obligatorias

Estas verificaciones no pertenecen a una única carpeta. Aplicalas al flujo y a
todos los archivos afectados, aunque cada archivo parezca correcto de forma
aislada.

### Dependencias y acoplamiento

Verificá:

- imports desde una feature hacia implementaciones internas de otra feature;
- dependencias circulares directas o indirectas;
- barrels que oculten dependencias indebidas o exporten elementos sin cohesión;
- navegación que importe pantallas en lugar de usar rutas;
- abstracciones que filtren DTOs, Brick, SQLite, HTTP u otros detalles técnicos;
- lógica compartida duplicada que debería tener un único dueño claro;
- que extraer algo a `core` sea reutilización real y no una forma de esconder
  acoplamiento entre features.

No concluyas que existe acoplamiento solamente por un import. Determiná qué
responsabilidad cruza el límite y si forma parte de una API pública válida.

### Estado, UI, strings y design system

Verificá:

- que pages y widgets rendericen estado en lugar de reconstruir reglas;
- que blocs/cubits no acumulen responsabilidades de casos de uso;
- que los estados asíncronos respeten el patrón acordado;
- que no existan textos de producto reutilizables hardcodeados en pages,
  widgets, blocs, cubits, casos de uso, repositories o servicios;
- que labels, títulos, botones, validaciones, errores y empty states repetidos
  tengan una fuente de verdad en el archivo de strings correspondiente;
- uso consistente de widgets core, theme y tokens;
- que un literal técnico, código backend o dato de test no sea confundido con
  copy de producto.

La regla de strings centralizados es bloqueante cuando el diff dispersa o
duplica lenguaje de producto reutilizable.

### Offline-first y sincronización

Para cada lectura o escritura afectada verificá:

- cuál es la fuente local utilizada para renderizar;
- que una pantalla pueda abrirse y mostrar el último estado conocido sin red;
- que toda escritura se confirme localmente antes de intentar HTTP;
- que no se espere una respuesta remota para guardar o continuar la UX;
- UUID generado por cliente para entidades sincronizables;
- `createdAt`, `updatedAt` y `deletedAt` cuando corresponda;
- soft delete en lugar de eliminación física cuando deba sincronizarse;
- estados pending/synchronized/rejected y manejo visible de rechazos;
- encolado, retry, idempotencia y recuperación después de reiniciar la app;
- last-write-wins y tratamiento de datos remotos más viejos;
- atomicidad cuando una operación modifica más de una entidad;
- comportamiento ante valores legacy, ausentes o desconocidos.

Separá expresamente:

- lectura local;
- hidratación remota;
- escritura local;
- sincronización saliente;
- reconciliación de la respuesta backend.

No declares que una capacidad es offline-first si solamente está implementada
la lectura o solamente existe el request remoto.

### Contrato mobile/backend

Cuando cambien campos REST, DTOs, adapters, transformers o endpoints:

- inspeccioná router, schema y service backend relacionados;
- verificá método HTTP, ruta, wrapper de respuesta y nombres de campos;
- comprobá qué campos acepta alta, edición y borrado;
- diferenciá campos de entrada, salida y solo lectura;
- verificá nulabilidad, enums, timestamps y códigos desconocidos;
- rastreá quién origina cada transición y qué operación se encola;
- no juzgues anotaciones como `ignoreTo` o `ignoreFrom` de forma aislada:
  compará adapter generado, request real, endpoint y dueño de la escritura.

### Multi-tenant, autorización y privacidad

Verificá:

- filtrado por `establecimientoId` en lecturas locales y remotas;
- que IDs recibidos no permitan cruzar datos entre establecimientos;
- que relaciones y operaciones compuestas pertenezcan al mismo tenant;
- que el cliente falle cerrado ante roles ausentes o desconocidos;
- que las validaciones mobile no sustituyan autorización y RLS backend;
- ausencia de secretos, tokens o datos identificables en código, logs y tests.

### Errores, logging y contratos de resultado

Verificá:

- que no haya errores silenciados ni `try/catch` vacíos;
- que data traduzca fallas técnicas sin ocultar la causa relevante;
- que domain y presentation no dependan de excepciones de infraestructura;
- mensajes comprensibles para operaciones críticas de campo;
- logging mediante la herramienta acordada y sin información sensible;
- que los fallbacks offline no conviertan errores reales en éxitos aparentes.

### Convenciones y mantenibilidad

Verificá:

- nombres y ubicación de archivos según Effective Dart;
- APIs públicas documentadas cuando corresponde;
- funciones y clases con una responsabilidad clara;
- ausencia de casts o defensas que oculten problemas de tipos;
- dependencias con versiones fijas, sin `^`, cuando el diff modifica manifests;
- ausencia de archivos generados desactualizados respecto de sus fuentes;
- que una abstracción nueva resuelva una necesidad real y no infle la estructura.

## Severidad

Usá estas definiciones:

- Bloqueante: rompe compilación, datos, seguridad, aislamiento multi-tenant o
  una escritura offline exigida por los criterios actuales.
- Alta: violación arquitectónica demostrable o riesgo funcional importante
  introducido por el diff.
- Media: deuda concreta, inconsistencia de contrato/documentación o test que
  reduce mantenibilidad o confiabilidad.
- Baja: problema localizado de estilo o claridad sin riesgo funcional inmediato.

No marques como Bloqueante una capacidad futura hipotética. Si el requisito
futuro está confirmado pero no forma parte de esta historia, clasificá el diseño
como Alta o como riesgo documentado según si el diff lo impide o simplemente
todavía no lo implementa.

## Reconstrucción de flujos

Para cada comportamiento afectado, reconstruí el flujo completo:

```text
UI → bloc/cubit → use case → contrato de dominio → repository impl
   → mapper/data source/store → SQLite/cola/HTTP
```

Marcá cualquier salto de capa, dependencia invertida o responsabilidad ausente.

Si el cambio toca solamente una parte del flujo, verificá que sea compatible con
las demás partes, pero no reportes como bug una funcionalidad futura que todavía
no forma parte de la historia.

Cuando exista un requisito futuro confirmado, diferenciá entre:

- todavía no implementado;
- preparado para extensión;
- diseño que dificulta la extensión;
- diseño que directamente impide el requisito.

## Formato de entrega

Primero:

### Alcance revisado

- Hash de `origin/develop`
- Hash de `<RAMA>`
- Merge-base
- Cantidad de archivos
- Lista completa `A/M/D`

### Auditoría por archivo

Incluí la tabla completa exigida en “Auditoría obligatoria de cada archivo”,
con una fila por cada archivo del diff, incluso cuando su veredicto sea
`Correcto` o `Código generado coherente`.

Después, para cada finding confirmado:

- Severidad: Bloqueante / Alta / Media / Baja
- Estado: Confirmado
- Archivo y línea aproximada
- Código o evidencia concreta
- Flujo completo analizado
- Por qué viola la arquitectura o convención
- Qué parte fue introducida por este diff
- Si existe deuda previa relacionada
- Corrección recomendada limitada al alcance del diff

Luego:

### Riesgos o puntos a confirmar

Incluí aquí observaciones que dependan de criterios de aceptación ausentes.
Explicá exactamente qué información falta para convertirlas en findings.

Finalmente:

### Verificado sin problemas

Indicá explícitamente qué comprobaste:

- límites entre capas;
- imports entre features;
- navegación;
- strings;
- offline-first;
- multi-tenant;
- Brick/modelo/adapter/schema/migración;
- código generado;
- tests.

### Limitaciones

Indicá:

- qué no pudiste validar;
- qué comandos no ejecutaste;
- si no se hizo fetch;
- si no se ejecutaron tests o análisis porque la rama no estaba checked out.

No modifiques archivos y no propongas cambios fuera del alcance del diff.
