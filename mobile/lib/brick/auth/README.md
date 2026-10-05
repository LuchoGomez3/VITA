# Pendiente: sesión y cola offline de toda la app

Estado: documentado para implementar en otra rama de integración general.
Este documento no cambia el comportamiento actual.

Para los pendientes del resto de los módulos, ver la
[auditoría general de sincronización](../sync/README.md).

## Problema actual

Las operaciones se guardan en SQLite y sus requests en la cola persistente de
Brick. Cerrar sesión limpia las credenciales, pero no borra esas bases.

El problema aparece si la cola intenta enviar sin una sesión válida:
`AuthenticatedBackendClient` devuelve un 401 y publica un resultado rechazado.
En `AppBrickRepository`, los códigos reintentables son 500, 501, 502, 503 y 504;
401 no está incluido. Por eso Brick puede retirar ese envío de la cola aunque
el registro local siga existiendo. Iniciar sesión nuevamente no reconstruye
automáticamente el envío retirado.

La renovación automática del access token ya existe. Si falla por conectividad,
el cliente devuelve 503 y conserva el envío. Si falla definitivamente por
autenticación, el caso cae en el problema anterior.

Ejemplo: guardar un pesaje offline, cerrar sesión y dejar la app abierta. Un
reintento sin credenciales puede dejar el pesaje rechazado en lugar de pendiente.

## Comportamiento esperado

| Situación | Resultado esperado |
| --- | --- |
| Sin conexión | Guardar localmente y conservar el envío pendiente |
| Access token vencido con refresh válido | Renovar y enviar con el nuevo token |
| Refresh sin conexión o backend con 5xx | Conservar el envío y reintentar después |
| Sesión ausente, revocada o refresh inválido | Pausar los envíos; conservar datos y cola; solicitar login cuando corresponda |
| Cerrar sesión | Pausar antes de limpiar credenciales, sin borrar operaciones pendientes |
| Iniciar sesión con la misma cuenta | Restaurar credenciales y retomar los envíos de esa cuenta |
| Iniciar sesión con otra cuenta | Mantener aislados los datos y envíos anteriores; no enviarlos con la nueva cuenta |
| Rechazo funcional del backend | Mostrar el rechazo de esa operación sin confundirlo con sesión vencida |
| Reiniciar la app | Restaurar la cola; habilitar envíos solo después de resolver la sesión y su cuenta |

La sincronización automática requiere que la app esté ejecutándose. No prometer
envíos con la app cerrada sin implementar un mecanismo de ejecución en segundo
plano específico.

## Implementación a coordinar en la otra rama

1. Coordinar el ciclo de la cola con restauración de sesión, login, renovación,
   logout y rechazo definitivo de autenticación. La cola debe empezar pausada
   mientras se determina la sesión y reanudarse solo con credenciales válidas.
2. Evitar que un 401 por falta de sesión retire un envío o marque la entidad como
   rechazada. Ante 401 remoto, intentar una única renovación y, si sigue sin
   autorización, conservar la operación y pausar. No agregar 401 a los
   reintentos sin más: eso produciría intentos continuos sin resolver la sesión.
3. Cubrir requests en curso durante logout o cambio de cuenta. Pausar el timer
   no cancela por sí solo los envíos que ya comenzaron; sus respuestas no deben
   actualizar datos de la sesión siguiente ni eliminar pendientes por un fallo
   de autenticación.
4. Asociar la persistencia local y los envíos con la cuenta que los creó, además
   del establecimiento. No alcanza con cambiar el Bearer del cliente compartido:
   el backend atribuye operaciones, como observaciones, al usuario autenticado.
   Resolver el aislamiento por cuenta antes de habilitar reanudación automática.
   Conservar las operaciones si la cuenta perdió acceso al establecimiento e
   informar el rechazo de permisos; no enviarlas con otra identidad.
5. Preservar UUID, cuerpo, fecha original y timestamps al reintentar. El login no
   debe recrear pesajes, notas o altas con identificadores nuevos. Conservar
   también el orden/dependencias de alta de animal y operaciones posteriores.
6. Definir una recuperación para instalaciones donde un 401 ya retiró requests:
   identificar rechazos de autenticación y reconstruir únicamente operaciones
   recuperables. Una edición del animal necesita su PUT acotado, no el POST de
   alta. No reencolar todos los rechazos funcionales ni adivinar la cuenta autora
   de pendientes antiguos que no tengan esa información.
7. Reflejar en la UI general que hay cambios guardados pendientes de iniciar
   sesión, manteniendo la lectura offline disponible para la cuenta autorizada.
   Las features no deben implementar su propio login ni manejar tokens.

## Archivos a revisar

- [Cliente HTTP autenticado](authenticated_backend_client.dart): renovación,
  respuesta sintética sin sesión y publicación de resultados de sync.
- [Proveedor de tokens](backend_access_token_provider.dart): expiración,
  renovación compartida y limpieza de credenciales.
- [Repositorio Brick](../core/repository.dart): inicio de cola, persistencia y
  clasificación de errores reintentables.
- [Composición de auth](../../features/auth/auth_composition.dart): conexión de
  auth con Brick y notificaciones de rechazo de sesión.
- [Repositorio de auth](../../features/auth/data/repositories/auth_repository_impl.dart):
  restauración, login y logout.
- Stores de `../stores/`: separar rechazo funcional de espera de autenticación.

Mantener la coordinación en la composición global y la infraestructura
compartida. No acoplar las features entre sí ni agregar lógica de animales o
pesajes al repositorio genérico. Si el aislamiento requiere modelos nuevos,
generar sus migraciones con `fvm dart run melos run build`.

## Pruebas de aceptación

- Guardar pesos y notas offline, recuperar conexión y verificar un único envío
  efectivo por UUID, con su fecha original.
- Vencer el access token con refresh válido y verificar renovación y envío.
- Fallar la renovación por red y comprobar que la operación sigue pendiente.
- Revocar la sesión o devolver 401 definitivo y comprobar que el envío sigue
  persistido, sin marcarlo como rechazo funcional ni entrar en un bucle.
- Cerrar sesión con pendientes, volver a entrar con la misma cuenta y comprobar
  que se retoman sin pérdida ni duplicados.
- Reiniciar con pendientes y comprobar que no se envían antes de restaurar la
  sesión, incluso si la app arranca con conectividad.
- Iniciar sesión con otra cuenta y verificar aislamiento de datos, cola y autor
  remoto; volver a la cuenta original y recuperar sus pendientes.
- Cerrar sesión durante un request o refresh en curso y comprobar que una
  respuesta tardía no modifica la sesión siguiente.
- Verificar que 400/403/409/422 se interpretan según el error del backend y no se
  ocultan como falta de conexión. Un rechazo de permisos debe conservar el
  registro local para informar y resolver el problema.
- Recuperar un request previamente retirado por 401 sin recrear un UUID ni
  sustituir un PUT por un POST.

Ejecutar pruebas unitarias y de integración con SQLite y la cola real de Brick,
además del recorrido manual offline en dispositivo o emulador. La futura
implementación toca autenticación y debe recibir revisión humana antes del
merge, conforme al AGENTS.md del monorepo.
