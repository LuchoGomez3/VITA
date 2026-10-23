# Equipo e invitaciones

## Recuperación de sesión del 2026-10-23

El cierre retira primero las rutas protegidas. Si falla la limpieza local, Auth
muestra un error con reintento y mantiene bloqueados el login y la restauración
hasta completarla. Los errores esperables de plataforma y timeout se registran
y se traducen a dominio. Los borrados nativos pendientes permanecen ordenados
por clave aunque el llamador reciba un timeout.

## Correcciones de revisión del 2026-10-22

Se agregaron regresiones para renovación rechazada en HTTP directo, descarte de
rechazos de una identidad anterior, publicación del catálogo durable y recuperación
del aviso local tras cancelar, quitar o reenviar. Cada hallazgo tiene su commit.

Validación conjunta:

```powershell
fvm flutter test --no-pub test/brick test/features/auth test/features/team test/features/sync test/features/home test/app/router test/core/widgets test/core/authentication/establishment_catalog_test.dart --reporter expanded
fvm dart run melos run build
```

Resultado: **261 tests aprobados**, generación exitosa sin diferencias en archivos
generados y análisis de los archivos modificados y de Team sin incidencias. No se
realizó validación manual en dispositivo ni contra servicios reales.

## Arquitectura

La UI consume casos de uso de `domain/use_cases/team_use_cases.dart`. El contexto
local se obtiene por `TeamRepository.findEstablishment`; ninguna factory ni
callback de presentación consulta el catálogo. Los casos de uso validan email,
roles asignables y protección del titular. Backend valida nuevamente membresía,
identidad (incluido no quitarse a uno mismo) y permisos actuales.

## Estado y lifecycle

`BlocProvider(create: ...)` posee cada Cubit, incluida la inicialización de Invitar.
Los estados son Freezed y cada operación independiente tiene `ResultState`.
El flujo de canje usa una unión: ingresar, confirmar, pertenecer o recuperar.
Los pasos que muestran preview/membresía requieren esos datos en su constructor.
Las revisiones de lectura descartan respuestas superpuestas o de un código borrado.
Después del cierre se descartan emisiones y navegación.

Si la renovación del token se rechaza definitivamente, el provider notifica a
Auth también para los requests HTTP directos de Team. Auth cierra la sesión y el
router retira las rutas protegidas; los guards siguen descartando resultados de
otra identidad. Una falla transitoria de red conserva la sesión offline.

Una mutación ya enviada no se deshace al salir. Su repositorio termina el request y
la persistencia. El transporte cierra los clientes que crea por request; un cliente
inyectado pertenece al llamador. La descarga tras el canje pertenece al coordinador
de sincronización de la sesión, que libera sus recursos al cerrarse la aplicación.
El repositorio de datos guarda y relee el catálogo, y entrega su resumen al
coordinador mediante un callback inyectado. La composición de aplicación conecta
ese callback y mantiene el repositorio por sesión; el router no accede a storage.
El guardado del catálogo espera el ciclo anterior, publica la membresía persistida
y luego inicia otro ciclo para incluirla en la descarga. Inicio escucha también
esta publicación temprana, sin recrear el shell.

## Confirmación y persistencia

`TeamMutation<T>` devuelve el resultado remoto, su efecto tipado (`TeamChange`), el
snapshot reconciliado y un posible
error local. Cancelar/quitar eliminan la fila conocida; invitar/reenviar reemplazan
la invitación por ID. El GET posterior reconcilia, pero no es necesario para guardar
el resultado confirmado. Una cola explícita por sesión serializa lecturas, mutaciones y escrituras
de Team. La composición comparte el repositorio entre rutas y lo reemplaza al cambiar
la identidad, evitando estado global adicional y pérdidas entre establecimientos.
Los snapshots copian y protegen sus listas. Si no había un listado completo, el
snapshot parcial se identifica como tal. No se persiste el código en claro.

Un error de storage después de una confirmación se muestra como cambio confirmado
sin guardado offline. Si el dispositivo sigue rechazando escrituras, no se puede
garantizar el contenido de la próxima apertura offline: hay que recuperar mediante
el refresco cuando vuelva a funcionar el almacenamiento. Si tampoco puede leerse
la base, no se sobrescribe y el efecto confirmado se aplica a los datos que la UI
ya tenía. No se reejecuta la mutación
solo por este error.

El aviso de persistencia se retira cuando un refresco consigue guardar el
snapshot completo. Si el refresco falla, permanece visible. La recuperación
conserva la confirmación y cualquier código efímero aún pendiente de compartir.

`TeamAcceptance` separa membresía otorgada y error al guardarla. El flujo sigue
mostrando aceptación y permite recuperar catálogo/descarga con la sincronización
existente, sin canjear otra vez cuando la aceptación ya se confirmó. Si la descarga
falla, el aviso de guardado solo se retira cuando el catálogo durable coincide en
ID, nombre y rol con la membresía confirmada; una entrada anterior no alcanza.
Una respuesta ilegible o perdida conserva el código y la preview en el estado de recuperación.
Recuperar repite el comando autorizado: backend solo devuelve un resultado consumido
al mismo ID y email, con membresía aún activa y su rol actual. Un 409 no es éxito,
aunque la caché conserve acceso. El backend permite previsualizar ese mismo resultado
para retomar el flujo tras reiniciar. Ver [ADR-0013](../../../../docs/adr/adr-0013-recuperacion-de-canje-confirmado.md).
El código desaparece del estado al confirmar; al reenviar, Equipo entrega
el código a la ruta de compartir y lo retira de su estado.

El contrato REST/cache completo del catálogo reside en
`core/authentication/data/establishment_remote_summary.dart`: lo consumen Sync y
Team desde data. Los objetos de dominio siguen libres de serialización y storage.

## Política pendiente

[ADR-0012](../../../../docs/adr/adr-0012-invitaciones-por-codigo-email.md) continúa
**propuesto, pendiente del PO**. Estas correcciones preservan el comportamiento
implementado (lista cacheada, gestión autorizada por servidor); no aprueban la
excepción online-only, agregan colas de permisos ni amplían roles. El texto del ADR
es histórico y no fue modificado. La validación de la excepción offline-first y los
roles propuestos sigue siendo una decisión funcional del PO.

Las modificaciones de validación de permisos y tratamiento de códigos requieren
revisión humana según `AGENTS.md`, antes de su integración.

## Validación previa de arquitectura (integración anterior)

Base: `develop` / `origin/develop` en `c7ae894`; verificado también mediante
`git ls-remote origin refs/heads/develop`. Rama de trabajo:
`feature/equipo-architecture-fixes`. No se hicieron commits, push ni merges.

Desde `mobile/`:

```powershell
fvm dart run melos run build
fvm flutter analyze --no-pub --fatal-infos lib/features/team test/features/team lib/core/authentication/data lib/features/sync/domain/services/offline_sync_coordinator.dart test/features/sync/domain/services/offline_sync_coordinator_test.dart test/features/sync/data/models/establishment_remote_summary_test.dart test/features/sync/data/repositories/initial_data_sync_repository_impl_test.dart
fvm flutter test --no-pub test/features/team test/features/sync/domain/services/offline_sync_coordinator_test.dart test/features/sync/data/models/establishment_remote_summary_test.dart test/features/sync/data/repositories/initial_data_sync_repository_impl_test.dart test/core/authentication/establishment_catalog_test.dart --reporter expanded
fvm flutter analyze --no-pub --fatal-infos
```

Resultados: generación exitosa, análisis del alcance sin incidencias, **82 tests
aprobados**. El análisis global informa **247 infos preexistentes**, fuera de los
archivos afectados. Se retiraron los cambios incidentales de generación en otros
módulos. `git diff --check` no reporta problemas.

Las pruebas cubren cierres de Cubit/ruta, inicialización tardía, respuestas
superpuestas, fallas de lectura/escritura por timeout y plataforma, canje confirmado
con falla local y recuperación sin segundo canje, catálogo guardado con descarga
fallida, mutaciones con GET posterior fallido y reapertura offline, aislamiento de
snapshots, ausencia del código en cache, inmutabilidad y permisos fail-closed.
No se realizó validación manual contra backend real ni emulador en esta tarea.
El generador advierte que el SDK Dart 3.12 es más nuevo que su analyzer 3.11;
no se actualizaron dependencias como parte de estas correcciones.


## Correcciones QA del 2026-10-20

Se confirmó el contexto histórico `6772d33...c510899` y el merge `8242d5d`, y se
integró sobre el estado de trabajo existente, preservando `mobile/AGENTS.md` y
`docs/codex/`. No se hicieron commits, push, merges ni PR.

1. **Entrada al canje:** el estado vacío posterior al login abre la misma ruta
   que Perfil. Las pruebas usan el router real: cancelar vuelve al origen y el
   éxito abre Inicio, incluso durante descarga.
2. **Lifecycle:** los Cubits descartan emisiones al cerrar o cambiar de sesión.
   Persistencia y descarga sobreviven al cierre de la ruta. La cola pertenece al
   repositorio de sesión; los clientes por request se cierran en `finally`.
   Logout invalida la identidad antes de esperar escrituras iniciadas y limpiar
   storage, evitando que una escritura demorada repueble datos de otra cuenta.
3. **Inicio montado:** el coordinador serializa el catálogo respecto del ciclo
   anterior y publica la membresía antes de descargar. Una consulta anterior al
   canje no la pisa. La prueba conserva la misma instancia de Inicio, vuelve antes
   de terminar y selecciona el campo nuevo aun con descarga fallida.
4. **Respuesta perdida:** el servidor reconoce exclusivamente al aceptante y su
   acceso activo. Devuelve el rol vigente y no vuelve a escribir ni enviar avisos.
   Mobile conserva el código incierto y exige respuesta remota para recuperar;
   nunca toma la caché o `codigo_usado` como prueba. Se prueban efectos remotos
   ocurridos antes del error, otra cuenta, acceso revocado y roles modificados.
5. **Ancho del código:** las cajas usan el ancho disponible, sin tamaño horizontal
   fijo. El campo de texto conserva edición accesible, foco, teclado y pegado.
   Las pruebas cubren 320/360 px, teclado visible y escala 1x/2x, incluidos los
   límites pintados de los caracteres y la confirmación adaptable.

La revisión humana debe incluir el contrato idempotente y las protecciones de
sesión/roles. El ADR-0012 continúa pendiente del PO. No se probó en dispositivo ni
contra Supabase/backend real; los tests usan fakes, HTTP simulado y almacenamiento
sintético. Es necesario desplegar primero el backend actualizado para recuperar
un canje mediante reintento.


### Validación final de QA

Comandos desde `mobile/` (ejecutados con FVM):

```powershell
fvm dart run melos run build
fvm flutter test --no-pub test/features/team test/features/sync test/features/home test/features/auth test/app/router test/core/authentication test/core/widgets test/brick/backend_access_token_provider_test.dart --reporter expanded
fvm flutter analyze --no-pub --fatal-infos lib/app/router/app_router.dart lib/brick/auth/backend_access_token_provider.dart lib/core/authentication/data lib/core/widgets/app_status_chip.dart lib/features/team lib/features/sync lib/features/auth/data/repositories/auth_repository_impl.dart lib/features/home/presentation/bloc/home_dashboard_cubit.dart test/features/team test/features/sync test/features/auth/data/repositories/auth_repository_impl_test.dart test/brick/backend_access_token_provider_test.dart
fvm flutter analyze --no-pub --fatal-infos
```

- Generación estándar: exitosa; archivos generados mediante Melos, sin edición manual.
- Tests relacionados: **185 aprobados**, incluidas navegación real y persistencia.
- Análisis del alcance: **sin incidencias**.
- Análisis global: falla por **247 infos**, sin errors ni warnings. Se cruzaron las
  rutas del diagnóstico con `git diff --name-only` y archivos nuevos: **0** de esas
  incidencias pertenecen a archivos modificados o añadidos.
- `fvm dart format` con `--output=none --set-exit-if-changed` sobre los **46 Dart**
  modificados/nuevos: **0 cambios necesarios**. `git diff --check`: correcto.

Desde `backend/` se ejecutaron las herramientas de la `.venv` existente:

```powershell
.\.venv\Scripts\ruff.exe check .
.\.venv\Scripts\ruff.exe format . --check
.\.venv\Scripts\python.exe -m pytest tests/test_equipo.py -q -p no:cacheprovider
.\.venv\Scripts\python.exe -m alembic heads
```

Resultados: Ruff correcto, **190 archivos** ya formateados, **40 tests aprobados**
y una única cabeza `20261017_02`. No se modificó el esquema ni se aplicaron
migraciones. Los tests backend usan SQLite y overrides de autenticación, sin
contactar Supabase ni SMTP real.

El intento inicial con `uv run --offline` no pudo acceder a su caché del sistema;
se usó la `.venv` disponible. FVM requirió acceso al SDK/caché fuera del workspace
para poder ejecutar. FVM emite `Invalid kernel binary format version` al arrancar,
pero continúa y ejecuta Flutter 3.44.0 / Dart 3.12.0. Build runner advierte que su
analyzer soporta Dart 3.11. No se agregaron ni actualizaron dependencias.

Los logs locales de esta ejecución quedan en `.dart_tool/qa_relevant_tests.log`,
`.dart_tool/qa_scope_analyze.log` y `.dart_tool/qa_global_analyze.log` (ignorados por
Git). No se declara validación en dispositivo ni cumplimiento de la Definition of
Done: quedan revisión humana y pruebas manuales contra el backend actualizado.
