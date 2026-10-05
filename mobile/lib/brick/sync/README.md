# Auditoría de sincronización de la app

Actualización posterior: [asignación y traslado entre lotes](../../features/lot_movement/README.md)
implementa POST batch, origen null, transacción local, estados de movimiento,
recuperación de jobs faltantes e historial de eventos. Los hallazgos siguientes
son la auditoría previa a esa implementación; los pendientes globales de sesión,
aislamiento, conflictos y dependencias siguen vigentes.

Revisión: 2026-10-05. Estado: pendientes para una rama de integración general.
En esta revisión se modifica documentación, no el comportamiento de la app.

## Alcance y límites

Se revisaron arranque, sesión, router, almacenamiento compartido, los ocho
stores Brick, los modelos y adapters REST, y las doce features presentes en
`lib/features/`. También se contrastaron los contratos locales del backend de
animales, categorías, pesajes, observaciones y egresos, y la implementación
instalada de la cola Brick.

Es una auditoría estática del árbol de trabajo, incluyendo los cambios actuales
de detalle animal. No certifica una prueba contra backend desplegado ni un
recorrido en dispositivo. Los escenarios derivados del código se indican como
riesgos a reproducir; los flags y las funciones ausentes se indican como
integraciones pendientes. No asumir que toda operación local está en la cola.

La revisión específica de vencimiento de sesión y logout está en
[auth/README.md](../auth/README.md). Este documento amplía el alcance a toda la app.

## Qué existe hoy

La base principal y la cola REST son persistentes y separadas. Los stores guardan
primero en SQLite y luego intentan el envío. La cola de Brick reintenta requests
de escritura; no convierte los GET en una descarga periódica. La configuración
actual conserva 500–504 para reintento y elimina de la cola las respuestas que
no estén en esa lista, incluidos los 4xx. El intervalo predeterminado de la
versión instalada es de cinco segundos; eso no garantiza un envío cada cinco
segundos ni ejecución con la app cerrada.

| Área | Escrituras | Lecturas / actualización | Situación |
| --- | --- | --- | --- |
| Auth | HTTP y secure storage | Restauración local, refresh automático del token | La sesión aún no gobierna el ciclo de la cola |
| Sync inicial | Catálogo en secure storage | En login: establecimientos, categorías, animales, pesajes y egresos según rol | Descarga secuencial, sin cursor ni estado por recurso |
| Registro animal | SQLite + POST de animal | Contexto local de lotes; categorías y genealogía con IDs temporales | Falta cerrar referencias y dependencias remotas |
| Detalle animal | PUT acotado; POST de pesaje y observación | Pull de relacionados al cargar/refrescar; guardado y validación locales | Integrado, con pendientes globales de sesión, conflictos y recuperación |
| RFID | Sin escritura de negocio | Busca animal solo en SQLite por establecimiento | Depende de que la descarga local esté completa y vigente |
| Home | Sin escritura | Recalcula SQLite al cargar/refrescar | Refrescar no descarga cambios del backend |
| Campo / lotes | Transacciones SQLite; envío opcional | Consulta local; existe pull de lotes sin coordinador global | Flags remotos deshabilitados por defecto |
| Movimientos entre lotes | Animal y movimiento en transacción local; envío opcional del movimiento | Sin pull de movimientos ni aplicación de resultados de sync | Integración remota incompleta |
| Egresos operativos | SQLite + POST; espera categoría personalizada | Historial local primero, luego HTTP; pull inicial | Es el flujo más completo de caché visible, pero tiene pendientes de recuperación |
| Registro de establecimiento | POST directo y actualización del catálogo local | Requiere conexión | Flujo online explícito, sin cola Brick |
| Perfil | Sin escritura de negocio | Lee catálogo descargado al login | Sin actualización propia de membresías |
| SENASA | Validar / generar por POST directo | Historial y descargas remotos; establecimientos locales | Operaciones online, sin cola de exportación |
| Livestock | Sin persistencia de negocio propia | Pantalla de accesos | No hay un listado sincronizado de animales en esta feature |
| Fotos de animales | Archivos privados locales | Archivo por establecimiento/animal o asset por caravana | Exclusivamente local por decisión de producto; no subir fotos |

## Prioridades

P0: conservación de operaciones e identidad/alcance de cuenta.
P1: consistencia de datos y dependencias entre recursos.
P2: experiencia, observabilidad y escalabilidad.

| ID | Prioridad | Tema | Evidencia |
| --- | --- | --- | --- |
| SYNC-01 | P0 | 401 puede retirar envíos al vencer/cerrar sesión | Confirmado en configuración y cliente de cola |
| SYNC-02 | P0 | Arranque y cambio de cuenta sin aislamiento de cola | Confirmado en bootstrap; escenarios de cruce a reproducir |
| SYNC-03 | P0 | Home consolidado usa todos los registros locales | Confirmado: alcance null no se limita al catálogo actual |
| SYNC-04 | P0 | Escritura local y encolado separados, sin recuperación general | Confirmado; cierre/fallo en la ventana a reproducir |
| SYNC-05 | P1 | Dependencias de categoría/lote/animal sin coordinación general | Confirmado; rechazo por orden a reproducir |
| SYNC-06 | P1 | Referencias temporales y establecimiento implícito en alta animal | Confirmado en contexto offline |
| SYNC-07 | P1 | Borrados remotos no llegan para animales/categorías/pesajes | Confirmado en requests de pull |
| SYNC-08 | P1 | Merge desigual y respuestas atrasadas | Confirmado en stores; concurrencia a reproducir |
| SYNC-09 | P1 | Un 2xx no reconcilia la versión ganadora del servidor | Confirmado contra contrato LWW |
| SYNC-10 | P1 | Egresos esperando categoría pueden quedar sin envío | Confirmado en caminos de despertar; reinicio a reproducir |
| SYNC-11 | P1 | Lotes y movimientos pendientes de contrato/integración | Confirmado; no habilitar flags como solución aislada |
| SYNC-12 | P1 | Estados de operaciones distintas comparten una entidad | Confirmado en traslado y PUT acotado; falsa confirmación a reproducir |
| SYNC-13 | P1 | Descarga inicial parcial y sin recuperación global | Confirmado en coordinador y disparadores |
| SYNC-14 | P1 | UUID de dominio sin unicidad SQLite general | Confirmado en adapters; duplicación concurrente a reproducir |
| SYNC-15 | P2 | Caché visible, reactividad y estado de rechazo inconsistentes | Confirmado en páginas/cubits |
| SYNC-16 | P2 | Transportes HTTP con renovación y timeout diferentes | Confirmado en servicios |
| SYNC-17 | P2 | Cursor, tamaño de descarga y política de reintentos | Pendiente de diseño sobre contratos actuales |

## Hallazgos y trabajo a implementar

### SYNC-01 y SYNC-02 — Sesión, arranque y cuenta autora

[main.dart](../../main.dart) inicializa Brick antes de crear la app y restaurar
la sesión. `initialize()` de Brick inicia el timer de la cola; los stores se
registran después en [brick_bootstrap.dart](../brick_bootstrap.dart).
[AuthSessionCubit](../../features/auth/presentation/session/cubit/auth_session_cubit.dart)
no pausa ni reanuda esa cola. Un reintento puede ocurrir sin credenciales durante
restauración o después de logout.

Las rutas de las bases son fijas para la instalación. Los modelos identifican
el establecimiento, pero la cola no conserva una cuenta autora que restrinja
qué sesión puede enviarla. Cambiar el token compartido no aísla pendientes.
En observaciones y egresos, backend asigna el autor desde la sesión que envía.

Implementar coordinación global de sesión y cola, inicio pausado, manejo de
401 como espera de autenticación, aislamiento por cuenta, requests en curso y
recuperación de requests retirados. El detalle completo y las pruebas están en
[la propuesta de auth](../auth/README.md). No reemplazarlo por reintentos
indefinidos de 401 ni borrar SQLite al cerrar sesión.

### SYNC-03 — Alcance del home y caché de membresías

[HomeDashboardCubit](../../features/home/presentation/bloc/home_dashboard_cubit.dart)
pasa `establishmentIds: null` para el consolidado.
[HomeDashboardRepositoryImpl](../../features/home/data/repositories/home_dashboard_repository_impl.dart)
interpreta null como todos los animales y egresos de SQLite, sin intersectar con
el catálogo de la cuenta actual. Cerrar sesión limpia ese catálogo, pero conserva
SQLite. También quedan datos de establecimientos a los que se perdió acceso.

Reproducir con cuenta A, logout y cuenta B con otro establecimiento: el consolidado
puede incorporar stock de A. La tarjeta financiera se oculta si no hay un
establecimiento seleccionado y rol habilitado; eso no corrige el alcance del
cálculo de stock. No afirmar que todos esos totales financieros se muestran.

Limitar consultas y totales a membresías vigentes de la cuenta activa. Separar
alcance desconocido de «todos los establecimientos autorizados». Actualizar
membresías al sincronizar y definir acceso a cachés cuando se revoca un permiso;
no eliminar silenciosamente operaciones pendientes.

### SYNC-04 — Persistencia de intención y cola

[AppBrickRepository](../core/repository.dart) guarda en la base principal y los
stores llaman después a `enqueueRemoteUpsert` con `unawaited`. La serialización
y el guardado en la base de cola ocurren más tarde. Si el proceso termina en esa
ventana, o falla serialización/escritura de cola, puede existir un registro
pending sin request. El helper registra la excepción, pero no hay un barrido
general al arranque que reconstruya operaciones pendientes sin envío.

Diseñar una intención de sincronización persistida atómicamente con el cambio
local, o una recuperación durable equivalente. Son dos bases: no asumir que la
transacción actual de SQLite también cubre la cola. Conservar tipo de operación,
UUID, versión, cuenta y dependencias. Una edición de animal usa PUT, no POST de
alta. Un barrido debe ser idempotente y no duplicar requests ya existentes.

También cubrir el caso inverso: backend aceptó y Brick retiró el envío, pero el
proceso terminó antes de persistir synchronized. Hoy los listeners son asíncronos
y el callback HTTP publica en un stream, sin esperar la escritura final del store.

### SYNC-05 y SYNC-06 — Dependencias y referencias reales

Animal, categoría y pesaje se encolan de forma independiente. Backend exige que
existan las referencias de categoría, lote, madre/padre y animal. Un pesaje, nota
o PUT puede llegar antes de que termine el alta de su animal; un 4xx por esa
dependencia no resuelta sale de la cola. El orden de inserción no sustituye una
dependencia confirmada: hay intentos inmediatos y respuestas concurrentes.

[AnimalRegistrationOfflineContext](../../features/animal_register/data/datasources/animal_registration_offline_context.dart)
usa mapas temporales de UUID para categorías y genealogía, y toma el primer
establecimiento del catálogo. Los lotes se obtienen localmente, mientras su sync
remota está deshabilitada por defecto. Un lote creado solo en el celular puede
ser rechazado como referencia por el POST de animal aunque guardar localmente
haya funcionado.

Usar catálogo Brick real y selección global explícita de establecimiento.
Persistir dependencias, enviar primero recursos requeridos y distinguir espera
de dependencia de rechazo funcional. Validar pertenencia y restricciones antes
de guardar, preservando operaciones offline. No habilitar el sync de lotes sin
cerrar el contrato remoto de geometría y mutaciones.

### SYNC-07 — Borrados remotos

Los transformers de [animal](../models/animal.model.dart),
[categoría](../models/categoria.model.dart) y [pesaje](../models/pesaje.model.dart)
no incluyen `include_deleted=true` en el pull. Backend lo admite y por defecto
oculta borrados. Como los stores solo hacen upsert de lo recibido, un registro
borrado en otro dispositivo permanece vigente en este.

Observaciones, egresos y el pull preparado de lotes sí solicitan tombstones.
Incorporar borrados explícitos y resolver su conflicto con pendientes locales.
No interpretar ausencia en un GET como borrado: puede ser un delta, un filtro
o un cambio de permisos. Diferenciar `estado: muerto` de `deleted_at`; la muerte
mantiene la ficha, mientras el tombstone representa borrado lógico.

### SYNC-08 y SYNC-09 — Versión canónica y concurrencia

Animales, categorías, pesajes, observaciones y lotes protegen pending/rejected
del pull, pero no comparan consistentemente updatedAt de versiones ya
sincronizadas antes de sobrescribirlas. Egresos sí compara timestamps, aunque
puede marcar synchronized a una copia local pending/rejected si llega una versión
remota igual o posterior. Definir qué prueba la aceptación real y cómo resolver
rechazados; protegerlos para siempre tampoco es reconciliación.

El cliente HTTP informa la versión enviada. El store de animal ignora resultados
anteriores a su versión actual; los demás stores no aplican esa comprobación.
Los handlers asíncronos pueden leer una versión y guardarla después de una
mutación concurrente. Probar el merge y la aplicación de respuestas con
transacciones o control de versión, sin pisar datos entre lectura y escritura.

[AuthenticatedBackendClient](../auth/authenticated_backend_client.dart) confirma
por status HTTP y no aplica `data` de la respuesta. Backend puede devolver 200
con el registro remoto ganador cuando el timestamp entrante pierde por LWW.
Entonces el celular marca synchronized una copia que no coincide con el servidor;
el siguiente pull puede corregirla, pero hasta entonces muestra un resultado falso.
También quedan autores asignados por backend sin hidratar hasta un pull.

Reconciliar el cuerpo canónico o consultar después de confirmar, comparar la
versión efectiva y explicar conflictos de negocio. Conservar la regla LWW
acordada y probar relojes desfasados; incrementar un timestamp contra la copia
local no resuelve por sí solo el desfase entre dos dispositivos.

### SYNC-10 — Egresos que esperan categorías

[BrickOperatingExpenseStore](../stores/operating_expense_brick_store.dart) guarda
un egreso y lo encola solo si su categoría personalizada está synchronized.
Los pendientes se despiertan al recibir un resultado HTTP de categoría. En cambio,
[cacheRemoteCategories](../stores/operating_expense_category_brick_store.dart)
puede confirmar una categoría durante el pull sin emitir ese evento.

Reproducir: categoría aceptada remotamente, egreso esperando y reinicio antes
del evento; el pull confirma la categoría, pero el egreso no tiene request y no
hay barrido de dependientes al arranque. Un rechazo anterior de categoría también
propaga rejected al egreso, y el despertar posterior solo selecciona pending.

Recuperar dependientes tanto tras POST como tras reconciliación remota y arranque.
Definir recuperación de rechazos por dependencia sin reintentar otros rechazos
de negocio. Mantener identidad por valor/tipo/establecimiento usada por backend;
no cambiar UUIDs ni considerar cualquier 409 una confirmación.

### SYNC-11 y SYNC-12 — Lotes, movimientos y unidad de confirmación

Los flags de lotes/movimientos son false por defecto. Es una integración pendiente
declarada, no una falla de internet. Hay pull de lotes sin llamada desde sync
inicial; movimientos no tiene pull, estado synchronized/rejected en su modelo
ni listener de resultados. Su contrato REST sigue marcado provisional.

[saveWithAnimals](../stores/animal_lot_movement_brick_store.dart) actualiza lote
de animales y guarda movimiento en una transacción SQLite. Solo encola el
movimiento si el flag está activo, no PUT individuales. Backend debe confirmar
la misma operación compuesta de forma atómica; no desarmarla en requests sueltos.

El traslado marca el animal pending. Un PUT posterior del detalle envía
categoría/estado/condición, pero no lote. Su confirmación puede marcar todo el
animal synchronized aunque la ubicación local siga sin sincronizar. Es un riesgo
concreto de usar un único estado para varias operaciones. Separar confirmaciones
por operación/versión y reconciliar el registro canónico.

Antes de activar los flags: acordar geometría local frente a WGS84, POST/PUT y
DELETE/tombstones, auditoría del responsable, pull de movimientos, dependencias
de lotes y resolución de movimientos concurrentes.

### SYNC-13 — Cobertura y recuperación del pull global

[InitialDataSyncRepositoryImpl](../../features/sync/data/repositories/initial_data_sync_repository_impl.dart)
escribe el catálogo y recorre establecimientos y recursos de forma secuencial.
La primera excepción termina la preparación: recursos anteriores quedan
guardados y los siguientes no se descargan. Login informa el error y permite
entrar, pero no queda un progreso persistido por establecimiento/recurso.

El disparador es login manual; restauración de sesión y signup no ejecutan esa
preparación. No se encontró un coordinador general de pull al recuperar conexión
o volver al primer plano. Observaciones se descargan al abrir cada ficha y no
integran el sync inicial. Perfil y selectores dependen del catálogo cacheado.
RFID solo consulta SQLite y puede interpretar datos faltantes como animal no
registrado, induciendo un alta que el servidor rechace por caravana duplicada.

Registrar progreso y fecha de último pull exitoso por cuenta, establecimiento y
recurso. Continuar/reintentar tareas recuperables sin descartar caché ni marcar
una descarga parcial como completa. Coordinar actualización de membresías,
catálogos, entidades y observaciones, respetando rol financiero. Diferenciar
«sin coincidencia local» de «ausencia confirmada en backend» en identificación.

### SYNC-14 — Identidad y duplicados locales

Los adapters generados no tienen una restricción única general por localId;
`primaryKeyByUniqueColumns` devuelve la primaryKey Brick. Los stores compensan
con búsqueda de PK y deduplicación en memoria, con criterios distintos; algunos
diccionarios eligen la última fila iterada sin comparar versiones. Esa protección
no asegura unicidad frente a escrituras concurrentes o duplicados históricos.

Diseñar saneamiento y unicidad por identidad remota, preservando la versión y los
pendientes correctos. Probar dos pulls simultáneos y una respuesta de sync con
filas duplicadas. Regenerar adapters/migraciones; no editar código generado a mano.

### SYNC-15 — Lo que muestra la UI

Home y campo refrescan consultas locales; eso no implica traer cambios de otro
dispositivo. En detalle animal, cargar espera los pulls antes de emitir Data y
refrescar reemplaza la ficha por loading. Su guardado sí valida y devuelve datos
locales sin esperar red. Egresos ya muestra caché primero y luego refresca: tomar
ese patrón como referencia para evitar bloquear la ficha en red lenta.

Los cubits de estas pantallas no se suscriben a cambios locales del store, aunque
Brick los notifica. Un resultado de sync puede cambiar SQLite mientras el badge
visible sigue pending hasta la siguiente lectura. No hay un resumen global de
operaciones esperando sesión, dependencia, reintento o corrección.

La tarjeta de historial de egresos etiqueta tanto pending como rejected como
«Pendiente de sincronización»; Reintentar del historial vuelve a consultar, no
reencola automáticamente la operación rechazada. Los contadores no deben prometer
que un rechazo funcional se resolverá solo. `FieldStrings.pendingSyncCount` aún
declara un mock fijo; no conectarlo a una UI como contador real sin reemplazarlo.

Actualizar estado visible mediante contratos de dominio, distinguir estados y
ofrecer acciones de corrección/reenvío apropiadas. No mostrar synchronized
solo porque se recuperó conexión. Describir frescura de caché y conteos reales.

### SYNC-16 — Transportes que no pasan por la cola

Brick renueva token y reintenta una vez tras 401. Egresos de lectura tiene una
implementación similar y timeout de 15 s. Establecimientos y el fallback HTTP
del detalle usan el token provider, pero no hacen el mismo refresh forzado tras
un 401 inesperado. SENASA tampoco hace ese reintento. Sus errores no recorren
siempre el mismo canal global de invalidación de sesión.

No hay timeout explícito en el cliente Brick compartido, en el fallback de
detalle ni en el transporte SENASA. Una conexión que queda abierta puede demorar
la ficha o el envío; la cola instalada tiene desbloqueo de requests viejos y no
debe suponerse que eso cancela el request original.

Unificar límites, renovación y clasificación de errores en transporte compartido,
sin meter reglas de features en auth. Mantener online explícitos signup/login,
registro remoto de establecimiento y validación/generación/descarga SENASA.
Si se quieren borradores o exportaciones offline, definir persistencia y producto
en otra tarea; no encolar POST de generación de archivos automáticamente.
El CSV remoto de egresos tampoco incluye necesariamente cambios locales pending;
conservar esa distinción en la UI.

El observador de resultados de Brick reconoce POST y PUT con id en el cuerpo,
no DELETE/PATCH. Es una limitación a contemplar cuando se integren esas mutaciones:
definir identidad desde la ruta y versión de operación antes de habilitarlas,
para no retirar requests sin actualizar el estado local correspondiente.

### SYNC-17 — Pull incremental y reintentos

Los listados backend revisados devuelven listas completas, sin paginación actual.
No se encontró un bug de «solo primera página» en esos contratos. Sí admiten
updated_since, pero mobile no mantiene ni envía un cursor general y repite
descargas completas. El nombre OperatingExpenseRemotePage no prueba paginación.

Persistir cursores solo después de aplicar correctamente una descarga completa,
con solapamiento/idempotencia para timestamps iguales. Si se agrega paginación,
acordar orden estable y cursor con backend antes de cambiar los consumidores.

La configuración no define backoff propio, tratamiento de 429/Retry-After ni
dependencias a nivel de cola. Un 429 actualmente sale de la cola como no
reintentable. Definir esa política con backend y probarla, sin convertir todos
los 4xx en reintentos. No hay garantía de tareas en segundo plano con la app
cerrada; cualquier promesa de esa clase requiere implementación específica.

## Orden sugerido de implementación

1. Sesión y cuenta, alcance de caché, conservación durable y recuperación:
   SYNC-01 a SYNC-04. Son condiciones para el resto.
2. Referencias y dependencias, tombstones, canonicalización y egresos pendientes:
   SYNC-05 a SYNC-10 y unicidad de SYNC-14.
3. Integración de lotes/movimientos y coordinación de pull:
   SYNC-11 a SYNC-13, en conjunto con backend.
4. Reactividad, diagnóstico, transporte y escalabilidad:
   SYNC-15 a SYNC-17, conservando los contratos de producto.

## Pruebas que debe agregar la rama de integración

| Escenario | Criterio de aceptación |
| --- | --- |
| Offline → online; reinicio entre ambos | Mismo UUID y fecha, un registro remoto, estado local correcto |
| Logout/token vencido y reingreso | Request conservado, sin falso rejected ni bucle de 401 |
| Cuenta A → B → A | B no ve ni envía datos de A; A recupera sus pendientes |
| Pérdida de membresía o rol financiero | Caché/alcance según política; pendientes conservados y permisos informados |
| Cierre entre cambio SQLite y encolado | Recuperación del envío sin duplicar intención |
| Backend acepta y cierre antes del ack local | Recuperación y reconciliación sin falso pending permanente |
| Alta de animal/categoría seguida de peso, nota o edición | Hijos esperan confirmación y se retoman si la app reinicia |
| Lote nuevo local y alta animal | Dependencia resuelta o espera explícita; no rechazo irrecuperable por orden |
| Borrado en otro dispositivo | Tombstone aplicado; no reaparece por fila duplicada o pull atrasado |
| Dos dispositivos y reloj desfasado | Copia canónica y conflicto visible; 200 no da falsa confirmación |
| Respuestas fuera de orden; baja y Deshacer | La versión anterior no pisa ni confirma la nueva |
| Egreso esperando categoría confirmada por pull | Se encola sin depender de otro POST/evento de categoría |
| Traslado más edición de ficha | Confirmar el PUT no confirma una ubicación aún local |
| Error a mitad del sync inicial | Progreso real, caché útil y reintento de recursos faltantes |
| Dos pulls/escrituras concurrentes por UUID | Una identidad local y selección estable de versión |
| Red lenta, 5xx y 429 | Caché visible; timeout/reintento acordados y sin pérdida de requests |
| Sync mientras la pantalla sigue abierta | Badges y totales reflejan cambios sin exigir salir y entrar |

Hay pruebas existentes de cliente/token, pulls iniciales, filtros locales,
payloads, transacciones de lotes y baja/Deshacer. Revisarlas en
[test/brick](../../../test/brick) y
[test/features/sync](../../../test/features/sync). No equivalen a cobertura de
todo el ciclo de la cola real, reinicios, cambio de cuenta o dos dispositivos.
Agregar integración con SQLite + cola Brick y recorridos manuales en dispositivo.

La implementación futura debe seguir los límites de capas, mantener privados y
locales los archivos de fotos y recibir revisión humana de autenticación y
permisos según AGENTS.md. No dar estos pendientes por resueltos al mergear la
feature de detalle animal.
