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
- logout local;
- pantalla tecnica inicial para decidir si mostrar welcome publica o entrar a
  la app;
- pantallas de login y registro bajo `presentation`.

No implementa guards completos por ruta ni borrado de bases Brick al cerrar
sesion. Esas decisiones quedan documentadas en [Fases futuras](#fases-futuras).
La preparacion masiva de tablas offline vive en `features/sync`; auth solo la
coordina despues de un login exitoso.

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
locales.

## Flujo de registro

```txt
SignUpPage
  -> SignUpBloc
  -> RegisterUserUseCase
  -> AuthRepositoryImpl
  -> AuthRemoteDataSource
  -> Backend /api/v1/usuarios/registro
```

El registro es online-only. Si el backend confirma el alta, la UI navega a la
pantalla de exito con el `AppUser` devuelto por el repositorio. No se guarda la
password, no se persiste sesion y no se crean datos offline desde este flujo.
El usuario debe iniciar sesion luego del registro para que mobile guarde la
sesion y ejecute la preparacion offline.

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
- pantalla inicial durante restauracion de sesion.

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

### Guards reales de router

Hoy existe una pantalla inicial de restauracion. Mas adelante conviene sumar
redirects/guards centrales para evitar acceder a rutas internas sin sesion.

### Politica multiusuario y logout

La fase actual no borra SQLite/Brick al cerrar sesion. Antes de hacerlo hay que
definir que pasa con datos locales pendientes de sincronizar y con el caso de
otro usuario iniciando sesion en el mismo dispositivo.

### Payloads mas estrictos

Los mappers actuales son suficientes para la primera integracion, pero pueden
endurecerse para detectar respuestas invalidas del backend con errores mas
claros.

### Observabilidad y errores UX

Conviene diferenciar mejor backend caido, timeout, token expirado, credenciales
invalidas y perfil inexistente para mostrar mensajes mas utiles.
