# Auth mobile

Esta feature implementa la autenticacion mobile y la restauracion de sesion para
un flujo offline-first.

El principio base es:

- login y registro requieren internet;
- una sesion ya iniciada debe poder restaurarse sin internet;
- Brick puede sincronizar con el backend cuando haya token, pero no debe conocer
  detalles de login ni leer credenciales persistidas.

## Alcance actual

Esta fase introduce el primer flujo real de sesion:

- login contra `/api/auth/login`;
- registro online contra `/api/v1/usuarios/registro`;
- refresh contra `/api/auth/refresh` cuando una llamada online necesita token
  vigente;
- persistencia local de una sesion minima en secure storage;
- restauracion offline al abrir la app;
- estado global de autenticacion con `AuthSessionCubit`;
- hidratacion del token provider que usa Brick;
- logout remoto con limpieza local garantizada, incluso sin conexion;
- proteccion central de arranque y rutas segun el estado de sesion;
- pantallas de login y registro bajo `presentation`.

No implementa el borrado de bases Brick al cerrar sesion. Esa decision queda
documentada en [Fases futuras](#fases-futuras). La preparacion masiva de tablas
offline vive en `features/sync`; auth solo la coordina despues de una
autenticacion exitosa.

## Capas

- **Backend**: `/api/auth/login` recibe `email + password` y devuelve
  `access_token + refresh_token + expires_in + usuario`. Esta accion requiere
  internet. `/api/auth/refresh` renueva tokens cuando vuelve la conexion.
- **Secure storage**: guarda una copia minima de la sesion para reabrir la app
  offline. No guarda datos de negocio ni colas de sync.
- **Memoria**: `SessionBackendAccessTokenProvider` mantiene el JWT vigente para
  que Brick lo pueda pedir antes de sincronizar.

## Flujo de login

```txt
LoginPage
  -> LoginBloc
  -> SignInUseCase
  -> AuthRepositoryImpl
  -> AuthRemoteDataSource
  -> Backend /api/auth/login
```

Despues del login exitoso, `LoginBloc` invoca un callback de preparacion offline
inyectado desde la composicion. Ese callback delega en `features/sync` para
descargar los datos necesarios para operar offline. Ese paso no pertenece al
dominio de auth: auth obtiene y persiste sesion; sync prepara datos de negocio
locales. El callback devuelve los IDs de establecimientos disponibles. Login
conserva ese resumen para que otras partes de la aplicacion puedan conocer el
alcance preparado para la sesion sin duplicar la consulta.

## Flujo de registro

```txt
SignUpPage
  -> SignUpBloc
  -> RegisterUserUseCase
  -> AuthRepositoryImpl
  -> AuthRemoteDataSource
  -> Backend /api/v1/usuarios/registro
```

El registro es online-only. En la misma respuesta del alta, el backend devuelve
la sesion completa creada para el usuario. Mobile la persiste e hidrata el token
provider de Brick sin volver a enviar el correo ni la password en una segunda
solicitud. La password se limpia de la UI al terminar y nunca se persiste.

Durante el proceso, la UI mantiene el estado de registro ocupado hasta que la
sesion devuelta queda persistida. Mientras tanto bloquea nuevos envios para
evitar solicitudes duplicadas.

Al finalizar se muestra una pantalla de confirmacion con dos acciones:

- `Configurar mi establecimiento` abre el asistente del primer establecimiento;
- `Ir al inicio` permite posponer esa configuracion y entrar a Home.

La sincronizacion de datos operativos no se ejecuta durante el registro porque
un dueño nuevo todavia no tiene establecimientos, animales ni pesajes. El login
manual conserva su preparacion offline para dispositivos que deben recuperar
informacion existente.

Si el backend responde al login con una sesion valida, `AuthRepositoryImpl`:

1. construye un `AuthSession` de dominio;
2. guarda una version minima en secure storage;
3. hidrata `SessionBackendAccessTokenProvider.instance`;
4. devuelve la sesion para que la UI actualice el estado global.

El backend usa el campo `username` por el estandar OAuth2 password form, pero en
mobile y dominio se habla de `email`. La traduccion queda encapsulada en
`AuthRemoteDataSource`.

## Que se guarda en secure storage

La clave `SecureStorageKeys.authSession` contiene un JSON versionado con:

- `access_token`
- `refresh_token`
- `access_token_expires_at`
- `user_id`
- `email`
- `first_name`
- `last_name`
- `cuit` si el backend lo devuelve
- `role`

No se guardan passwords. Tampoco se guarda el token dentro de SQLite/Brick.

## Arranque offline

```txt
FrontendMayoralApp
  -> AuthSessionCubit.restoreSession()
  -> RestoreSessionUseCase
  -> AuthRepositoryImpl.restoreSession()
  -> AuthLocalDataSource
  -> SecureStorageService
```

Al abrir la app, `AuthSessionCubit.restoreSession()` lee secure storage mediante
`RestoreSessionUseCase`. Si hay sesion local, emite `authenticated` sin llamar al
backend. Esto permite entrar a la app sin internet y trabajar contra SQLite.

Si no hay sesion local, emite `unauthenticated` y la app muestra la welcome
publica con acciones para iniciar sesion o registrar una cuenta. Login y
registro son las excepciones al offline-first porque ambos requieren internet:
registro para crear la cuenta en backend, login para obtener una sesion inicial
valida.

Los redirects centrales impiden acceder a rutas privadas sin sesion. Mientras
se restaura secure storage se muestra la ruta tecnica de chequeo; con una sesion
valida se habilita la experiencia interna y sin sesion se vuelve al flujo
publico de autenticacion.

## Como Brick obtiene el token

Brick no conoce `features/auth`. Su cliente HTTP usa el contrato
`BackendAccessTokenProvider`.

Cuando auth hace login o restore, el repositorio hidrata
`SessionBackendAccessTokenProvider.instance` con `access_token`,
`refresh_token` y expiracion. Desde ahi, `AuthenticatedBackendClient` puede
pedir un token vigente antes de agregar `Authorization: Bearer <token>` a los
requests de sync.

Restaurar la app offline no refresca tokens. Si el access token vencio, la app
sigue entrando offline con la sesion local; el refresh ocurre recien cuando una
llamada online o una sincronizacion necesita hablar con backend.

## Logout

Logout borra la sesion de secure storage y limpia el token en memoria. En esta
fase no borra las bases SQLite de Brick; esa decision queda pendiente porque
puede implicar perder cambios locales no sincronizados.

## Validacion

Casos cubiertos por tests:

- login exitoso persistiendo sesion;
- hidratacion del token provider usado por Brick;
- restore de sesion desde storage local sin backend;
- logout limpiando storage seguro y memoria;
- credenciales invalidas;
- timeout/backend no disponible;
- pantalla inicial durante restauracion de sesion;
- validaciones locales de nombre, CUIT/CUIL, email y password;
- boton de registro deshabilitado mientras el formulario es invalido;
- registro seguido de inicio automatico de sesion;
- estados de carga de registro, login y preparacion offline del login;
- bloqueo de solicitudes duplicadas;
- limpieza de la password al completar el flujo;
- navegacion desde la confirmacion al asistente o a Home.

Comando usado:

```powershell
cd mobile
fvm flutter test
```

Resultado esperado de esta fase: todos los tests pasan.

`flutter analyze` puede seguir reportando infos preexistentes del proyecto. Si
CI usa `--fatal-infos`, esa limpieza debe abordarse como una tarea separada para
no mezclarla con la integracion de sesion.

## Fases futuras

### Politica multiusuario

El logout revoca la sesion remota cuando hay conexion y siempre elimina tokens
del almacenamiento seguro y de memoria. No borra SQLite/Brick: antes de hacerlo
hay que definir que pasa con datos locales pendientes de sincronizar y con el
caso de otro usuario iniciando sesion en el mismo dispositivo.

### Payloads mas estrictos

Los mappers actuales son suficientes para la primera integracion, pero pueden
endurecerse para detectar respuestas invalidas del backend con errores mas
claros.

### Observabilidad y errores UX

Conviene diferenciar mejor backend caido, timeout, token expirado, credenciales
invalidas y perfil inexistente para mostrar mensajes mas utiles.

Los estados y entidades que contienen `AuthSession` no deben imprimirse ni
enviarse completos a herramientas de observabilidad, porque incluyen access y
refresh tokens. Antes de incorporar un `BlocObserver` o reporte automatico de
estado se deben redactar esos campos sensibles.
