# frontend_mayoral

Frontend mobile de la app de trazabilidad ganadera.

La base del proyecto está armada con Flutter, navegación con `go_router`, manejo de estado con `flutter_bloc` y una arquitectura modular orientada a features. La persistencia offline-first se piensa alrededor de Brick.

## Stack base

- Flutter
- FVM
- `go_router`
- `flutter_bloc`
- Brick

## Versión de Flutter del proyecto

Este proyecto trabaja con:

- Flutter `3.44.0`

Para mantener la misma versión entre todos los miembros del equipo, el proyecto usa **FVM** (`Flutter Version Management`).

## Requisitos previos

Antes de correr el proyecto, asegurate de tener instalado:

- Git
- Un editor de código
  - VS Code, Cursor o Android Studio
- Extensiones/plugins de Flutter y Dart en el editor
- Android Studio si vas a usar emulador Android
- Xcode si vas a correr iOS desde macOS
- Un dispositivo para ejecutar la app
  - emulador Android
  - simulador iOS
  - o teléfono físico con depuración habilitada

## Instalación de Flutter y FVM

### 1. Instalar Flutter SDK

Primero instalá Flutter en tu máquina siguiendo la documentación oficial:

- https://docs.flutter.dev/get-started/install

No hace falta instalar Dart por separado: **Dart ya viene incluido con Flutter**.

### 2. Instalar FVM

Instalá FVM siguiendo su documentación oficial:

- https://fvm.app/

## Configuración inicial del proyecto

Una vez que tengas Flutter y FVM instalados:

### 1. Instalar la versión de Flutter del proyecto

```bash
fvm install 3.44.0
```

### 2. Seleccionar esa versión para este repo

```bash
fvm use 3.44.0
```

### 3. Verificar que todo esté bien

```bash
fvm flutter doctor
```

## Primer arranque

### 1. Instalar dependencias

```bash
fvm flutter pub get
```

### 2. Ver dispositivos disponibles

```bash
fvm flutter devices
```

### 3. Ejecutar la app

```bash
fvm flutter run
```

## Flujo recomendado para el equipo

Dentro de este proyecto, usar siempre los comandos de Flutter a través de FVM:

```bash
fvm flutter pub get
fvm flutter run
fvm flutter test
fvm flutter analyze
```

Esto evita que cada integrante use una versión distinta de Flutter por accidente.
## FVM y Melos

Ambas herramientas se usan juntas, pero cumplen funciones distintas:

- **FVM** define qué versión de Flutter usa este proyecto.
- **Melos** centraliza scripts y tareas repetitivas del repo.

En otras palabras:

- usar `FVM` asegura que todo el equipo trabaje con el mismo SDK de Flutter
- usar `Melos` evita repetir comandos largos y deja un workflow común para generación de código, análisis, formato y tests

## Comandos útiles con Melos

Una vez configurado FVM y descargadas las dependencias del proyecto, podés usar estos comandos:

```bash
melos run build
melos run analyze
melos run format
melos run format:fix
melos run test
```

Comandos más comunes:

- `melos run build`: ejecuta `build_runner` para generar código de `freezed` y `json_serializable`.
- `melos run analyze`: corre el análisis estático del proyecto.
- `melos run format`: verifica formato.
- `melos run format:fix`: aplica formato automáticamente.
- `melos run test`: ejecuta tests en paquetes que tengan carpeta `test`.

## Estructura base

```text
lib/
  app/
    config/
    router/
    theme/
  core/
    errors/
    extensions/
    formatters/
    result/
    theme/
    validators/
    widgets/
  brick/
  features/
    auth/
    animal_register/
    animal_detail/
    home/
```

## Decisiones principales

- `app/`: composición global de la aplicación
- `core/`: piezas reutilizables y transversales
- `brick/`: infraestructura offline-first
- `features/`: funcionalidades del producto
- `go_router`: navegación centralizada
- `flutter_bloc`: estado de presentación
- `Result<T>` y `ResultState<T>`: manejo consistente de resultados y estado async
- `DomainException`: contrato común de errores expuestos hacia capas superiores

## Guía de arquitectura

La guía viva del proyecto está en:

- [docs/guide.md](docs/guide.md)

Ahí se documentan:

- estructura de carpetas
- convenciones
- uso de Brick
- navegación
- organización por capas

## Estado actual

Este repo está en etapa de esqueleto/base arquitectónica. Algunas features están modeladas como referencia y todavía no representan el flujo final completo del producto.


