# GUIA Front

## **2.2. Arquitectura Interna por Capas: El Paradigma Presentación-Dominio-Datos**

Cada paquete de nuestro monorepo, ya sea un paquete de funcionalidad (por ejemplo, auth, cart, checkout) o un paquete de biblioteca (como design_system, remote_client), debe concebirse como una unidad modular con una arquitectura interna clara y consistente. El objetivo no es solo organizar archivos, sino garantizar que cada paquete sea testeable, mantenible y extraíble para su reutilización en diferentes aplicaciones.

Para lograrlo, adoptamos un enfoque híbrido que combina dos paradigmas complementarios:

- **Flutter Clean Architecture:** Estructura cada paquete en capas bien delimitadas con dependencias orientadas hacia el núcleo de negocio.
- **Feature Oriented Architecture:** Organiza el código alrededor de funcionalidades cohesivas y concretas.

Este diseño asegura una evolución ordenada del sistema y fomenta la colaboración entre equipos.

### **Capa de Presentación**

La capa de Presentación concentra la interfaz de usuario y la gestión del estado. Aquí residen las pantallas, widgets y controladores de estado (BLoCs o Cubits) asociados a la funcionalidad. Su responsabilidad principal es capturar los eventos de la UI, traducirlos en acciones de negocio a través de casos de uso y emitir estados que la interfaz renderizará.

Dentro de cada paquete de funcionalidad, esta capa se organiza en submódulos con responsabilidades bien definidas:

- **bloc o cubit:** Contiene la lógica de estado asociada a la funcionalidad. Aquí se implementan los eventos, estados y controladores que orquestan el flujo de datos entre la UI y el Dominio. La configuración y lineamientos de implementación se detallan en los anexos.
- **pages:** Reúne todas las pantallas (screens) que representan la vista principal de la funcionalidad. Cada page utiliza los controladores de estado expuestos por bloc o cubit.
- **widgets:** Incluye los componentes reutilizables específicos de la funcionalidad, diseñados para ser consumidos por las páginas sin duplicar lógica o estructura de UI.

### **Principios fundamentales de la capa de Presentación:**

- Utilizar un modelo de gestión de estado reactivo, basado en streams o eventos.
- Mantener la separación estricta respecto de la lógica de negocio y los datos: nunca acceder directamente a repositorios ni a servicios externos.
- Encapsular todos los elementos de UI y estado de la funcionalidad dentro del propio paquete, garantizando modularidad y autonomía.

### **Capa de Dominio**

El Dominio constituye el núcleo de la lógica de negocio y define cómo fluye la información sin depender de detalles técnicos o externos. Su rol es establecer las reglas y contratos que gobiernan cada funcionalidad, garantizando independencia de frameworks, SDKs o servicios específicos.

Dentro de cada paquete, esta capa se organiza en tres componentes principales:

- **Modelos de dominio (entities):** Representan los objetos de negocio puros, con las propiedades y comportamientos necesarios para la funcionalidad. Ejemplos: User, Cart, Product.
  - No incluyen lógica de infraestructura.
  - Se mantienen inmutables y serializables cuando corresponde.
- **Casos de uso (use cases):** Encapsulan acciones específicas de negocio y orquestan el flujo entre la Presentación y los Datos. Ejemplos: LoginUser, AddItemToCart, GetProductDetails.
  - Cada caso de uso tiene una única responsabilidad.
  - Devuelven modelos de dominio y errores del negocio.
- **Abstracciones de repositorios o servicios:** Definen contratos en forma de interfaces que describen cómo se hace el acceso a los datos o servicios, sin definir cómo se implementan.
  - Garantizan que el Dominio nunca dependa de implementaciones concretas.
  - Permiten intercambiar infraestructuras (API REST, Firebase, base de datos local) sin afectar la lógica de negocio.

### **Principios fundamentales de esta capa:**

- Los casos de uso son el único punto de entrada desde la Presentación al Dominio.
- Los repositorios son siempre abstracciones.
- Todo lo que se expone hacia otras capas son modelos y errores de dominio.

### **Capa de Datos**

La Capa de Datos materializa los contratos definidos en el Dominio y se encarga de traducir datos externos en modelos de dominio consistentes. Aquí se ubican las implementaciones de repositorios y, según la necesidad técnica de cada feature, también pueden vivir fuentes de datos, DTOs, mappers o servicios de infraestructura. Su objetivo es aislar la lógica de negocio de los detalles técnicos, garantizando desacoplamiento y testabilidad.

Dentro de esta capa se organizan los siguientes componentes:

- **DTO (Data Transfer Objects)**
  - **Request Models:** Definen la estructura de los datos que se envían a sistemas externos (ej.: payload de un POST).
  - **Response Models:** Representan los datos recibidos desde APIs o SDKs antes de ser transformados en modelos de dominio.
  - Sirven únicamente como contratos de transporte y no se exponen fuera de la capa de Datos.
- **Repositories Implementation**
  - Implementan las interfaces de repositorio definidas en el Dominio.
  - Coordinan la interacción entre distintas fuentes de datos (API, base local, caché).
  - Transforman DTOs en modelos de dominio y manejan la propagación de errores.
- **DataSources**
  - **Abstracciones:** Definen la interfaz estandarizada de acceso a una fuente específica (ej.: AuthRemoteDataSource).
  - **Implementaciones:** Contienen la lógica concreta de acceso a datos, como llamadas HTTP, consultas locales o integración con SDKs externos.
  - Aíslan los mecanismos de obtención de datos, evitando que filtren detalles hacia capas superiores.
- **Services**
  - Encapsulan la comunicación de bajo nivel con sistemas externos.
  - Incluyen configuraciones de clientes HTTP, definición de endpoints, interceptores, headers y lógica de requests.
  - Se utilizan cuando una feature necesita integrarse con servicios externos fuera del flujo principal resuelto por Brick.

### **Nota para este proyecto**

- No todas las features tienen que usar exactamente la misma subestructura interna dentro de `data/`.
- Si una feature trabaja con Brick como infraestructura offline-first principal, puede resolver su capa `data` sólo con `mappers/` y `repositories/`.
- En esos casos, la sincronización local/remota vive en `lib/brick/`, por lo que `datasources/`, `services/` o `models/` tradicionales pueden no ser necesarios dentro de la feature.
- Si una feature integra hardware, SDKs nativos, Bluetooth o APIs que no pasan por Brick, sí puede tener `datasources/` y otros componentes técnicos propios.

### **Principios fundamentales de esta capa:**

- Las implementaciones de repositorios dependen exclusivamente de las abstracciones del Dominio.
- Los DataSources aíslan los detalles técnicos, mientras que los Services concentran la comunicación de bajo nivel.
- Los DTOs funcionan como contratos claros de intercambio de información con el exterior.

## **2.2.1. Infraestructura Offline-First con Brick**

Para esta app, Brick se utilizará como infraestructura offline-first. La idea es que la app pueda operar en campo sin conexión, persistir los datos localmente y sincronizarlos cuando vuelva internet.

### **Cómo se estructura**

- `lib/brick/`: infraestructura global de Brick.
- `lib/brick/models/`: modelos persistibles y sincronizables con sufijo `.model.dart`.
- `lib/brick/repository.dart`: punto de entrada del repository offline-first.
- `lib/brick/adapters/`: adapters generados por Brick.
- `lib/brick/db/`: schema y migraciones locales.

### **Cómo se conecta con Clean Architecture**

- `presentation` no conoce Brick.
- `domain` no conoce Brick.
- `data/repositories` sí puede usar Brick para implementar los contratos del dominio.
- Si una feature necesita persistencia offline-first, su repositorio implementado en `data` traduce la entidad de dominio a un modelo Brick y delega la operación al repository de `lib/brick/`.
- En una feature que usa Brick, la estructura mínima esperada dentro de `data/` suele ser:
  - `mappers/`
  - `repositories/`

### **Ejemplo conceptual**

- `features/animal_register/domain/entities/animal.dart`: entidad de negocio.
- `brick/models/animal.model.dart`: modelo que Brick persiste y sincroniza.
- `features/animal_register/data/mappers/animal_brick_mapper.dart`: traduce entre dominio y Brick.
- `features/animal_register/data/repositories/animal_repository_impl.dart`: usa `AppBrickRepository`.

### **Flujo**

1. La UI invoca el caso de uso `RegistrarAnimalUseCase`.
2. El caso de uso llama al contrato `AnimalRepository`.
3. `AnimalRepositoryImpl` convierte `Animal` a `BrickAnimalModel`.
4. `AppBrickRepository` guarda localmente y luego, cuando corresponda, sincroniza con remoto.
5. El resultado vuelve a la feature como entidad de dominio.

## **2.3. Estableciendo APIs Públicas (Barrel files)**

Uno de los principales desafíos en sistemas modulares a gran escala es mantener la encapsulación. Sin un mecanismo claro para definir qué es público y qué es interno, los desarrolladores tienden a acoplarse a detalles de implementación, lo que dificulta la refactorización y multiplica el riesgo de introducir errores en otros módulos.

Para resolver este problema, se adopta la convención oficial de Dart de utilizar un único archivo “barril” (barrel file) que define la API pública del paquete. Este archivo concentra las exportaciones necesarias para que otros paquetes consuman la funcionalidad, garantizando que todo lo demás permanezca oculto en la carpeta lib/feat.

### **Beneficios:**

- **Desacoplamiento forzado:** Otros paquetes solo pueden depender de lo que el archivo barril expone, evitando referencias directas a implementaciones internas.
- **Refactorización segura:** El equipo propietario de un paquete puede reorganizar su estructura interna sin afectar a consumidores externos, siempre que la API pública se mantenga estable.
- **Superficie de API controlada:** Cada paquete funciona como una caja negra con un contrato claro y estable, reduciendo la complejidad de integración.
- **Escalabilidad del equipo:** En entornos con múltiples desarrolladores, esta práctica evita conflictos y dependencias cruzadas innecesarias, lo que facilita el trabajo paralelo en diferentes funcionalidades.

### **¿Qué debe exportar un archivo barril?**

El archivo barril debe ser minimalista y deliberado, incluyendo únicamente:

- **Widgets de alto nivel:** Como la pantalla de entrada principal de una funcionalidad (por ejemplo, AuthPage).
- **Interfaces de servicio o repositorio:** Abstracciones de la capa de Dominio que otros paquetes necesitan consumir (por ejemplo, AuthRepository).
- **Modelos de datos públicos:** Entidades de dominio que forman parte del contrato externo del paquete.

De esta forma, cada paquete expone únicamente lo que es necesario, manteniendo su autonomía y facilitando el crecimiento del sistema de manera ordenada y sostenible.

## **3.4. Navegación entre los Límites de las Funcionalidades con go_router**

Un desafío clave en la arquitectura modular es la navegación. ¿Cómo puede un paquete navegar a una pantalla que reside en otro paquete sin dispersar la configuración por toda la aplicación?

La decisión para este proyecto es mantener una navegación simple y centralizada con `go_router`. Todas las rutas principales se declaran en un único lugar, dentro de `lib/app/router/`, y cada feature aporta sus pantallas para ser registradas allí.

Este enfoque mantiene visible el mapa de navegación, evita configuraciones demasiado abstractas y facilita que cualquier desarrollador o IA entienda rápido cómo se mueve la app.

### **Lineamientos prácticos**

- `go_router` se configura una sola vez a nivel aplicación.
- Cada feature expone sus `pages` y, si resulta útil, constantes simples de rutas.
- Las rutas se agregan de forma explícita en el router principal.
- La UI navega con `context.go(...)` o `context.push(...)`.
- La navegación pertenece a la capa de Presentación, no al Dominio ni a Datos.

### **Estructura sugerida**

- `lib/app/router/app_router.dart`: configuración principal de `GoRouter`.
- `lib/features/<feature_name>/presentation/pages/`: pantallas registradas desde el router.
- Opcionalmente, una feature puede tener una clase chica de rutas si mejora la legibilidad.

### **Ejemplo conceptual**

- `/` -> home
- `/registrar-animal` -> alta manual de animal
- `/rfid-scan` -> lectura de identificador RFID

No se usarán por ahora mecanismos avanzados como `RouteConfig`, `Strategy`, `MainInitializer` o configuraciones por aplicación. Si en el futuro aparece esa necesidad, se evaluará en ese momento.

## **3.6. Navegación inferior / Navbar**

Por ahora no se definirá un sistema de navbar modular ni un shell global de navegación. Ese enfoque agrega complejidad innecesaria para la etapa actual del proyecto.

### **Decisión actual**

- Si una pantalla necesita `BottomNavigationBar`, `NavigationBar` o tabs, se resolverá de forma simple dentro de la propia app.
- No se usarán `Registry`, `Presets`, `StatefulShellRoute` ni configuraciones dinámicas por feature en esta primera versión.
- La prioridad es que la estructura por módulos sea clara y que la navegación sea mantenible.

### **Criterio a futuro**

Si más adelante la aplicación necesita una navegación persistente con varias secciones globales, se podrá evaluar una arquitectura de shell con `go_router`. Pero esa decisión se tomará cuando exista una necesidad real y no de forma anticipada.

## **Sección 4: Estándares de Código y Análisis**

La calidad, mantenibilidad y consistencia del código son pilares fundamentales para el éxito a largo plazo de cualquier proyecto de software. Para garantizar estos principios, se establecerá un conjunto de reglas y herramientas que automatizarán la validación de estándares, asegurando que todo el código producido por el equipo cumpla con las mejores prácticas definidas.

### **4.1 Principios Generales de Codificación**

Antes de abordar la automatización, se definen dos reglas de alto nivel que rigen todo el desarrollo:

1. **Idioma del Código:** Todo el código, incluyendo nombres de clases, variables, métodos, comentarios y documentación, deberá ser escrito exclusivamente en inglés. Esta práctica asegura la universalidad y consistencia del proyecto, facilitando la colaboración con desarrolladores de cualquier procedencia y manteniendo la coherencia con el ecosistema de Flutter y Dart, que está basado en inglés.
2. **Gestión de Dependencias (Versioning Fijo):** Para garantizar compilaciones reproducibles y evitar la introducción de cambios disruptivos por actualizaciones automáticas, todas las dependencias en el archivo pubspec.yaml deben tener versiones fijas. Se prohíbe el uso del prefijo caret (^).
  - *Incorrecto:* flutter_bloc: ^8.1.3
    - *Correcto:* flutter_bloc: 8.1.3
3. Este enfoque nos da control total sobre las actualizaciones, que se realizarán de forma manual y controlada tras validar su compatibilidad.

### **4.2 Análisis Estático con very_good_analysis**

Para automatizar la aplicación de las mejores prácticas de Dart y Flutter, se utilizará el paquete very_good_analysis. Este es un conjunto de reglas de "linting" mantenido por la comunidad que es estricto, opinionado y promueve un código de alta calidad, previniendo errores comunes y deuda técnica.

### **Configuración, Flujo de Trabajo y Aplicación Práctica:**

Una vez configurado, very_good_analysis se integra de forma transparente en el entorno de desarrollo, proveyendo retroalimentación en tiempo real.

1. **Integración en el IDE:** El analizador estático se ejecuta continuamente en el editor (Cursor, VS Code, Android Studio). Cualquier violación de una regla se subraya instantáneamente, permitiendo al desarrollador corregirla al momento. Las violaciones se categorizan visualmente, usualmente como:
  - **Info (Azul):** Sugerencias de estilo o buenas prácticas (ej. prefer_const_constructors).
    - **Warning (Amarillo):** Potenciales errores o código que debería evitarse (ej. avoid_print).
    - **Error (Rojo):** Errores de sintaxis o de tipo que impedirán la compilación.
2. **Corrección de Problemas:** El desarrollador puede abordar las advertencias de dos maneras:
  - **Corrección Manual:** Para reglas lógicas o de nombrado (ej. camel_case_types), el desarrollador debe aplicar el cambio manualmente según el mensaje de la advertencia.
    - **Corrección Asistida (Quick Fix):** Muchas reglas de estilo pueden ser corregidas automáticamente por el IDE. Al posicionar el cursor sobre el código subrayado y presionar Ctrl + . (o Cmd + .), se despliega un menú contextual con la opción de aplicar la corrección.
3. **Análisis Completo del Proyecto:** Para realizar una validación exhaustiva de todo el código base, se debe ejecutar el siguiente comando en la terminal. Este es el mismo comando que se utilizará en el pipeline de integración continua.
4. Bash

flutter analyze




La adopción de very_good_analysis implica un estándar de calidad estricto desde el inicio del desarrollo, lo cual minimiza la acumulación de deuda técnica y asegura una base de código robusta y homogénea.

## **Bloques Adicionales de Arquitectura y Herramientas**

### **Generación en Tiempo de Compilación**

Se utiliza `melos run build` para ejecutar `build_runner` de forma centralizada. Este flujo se usará principalmente para la generación de código asociada a `freezed` y `json_serializable`.

### **1.2. Aprovechando Pub Workspaces para la Gestión Unificada de Dependencias**

Históricamente, los monorepos en el ecosistema de Dart presentaban desafíos significativos: la proliferación de archivos pubspec.lock en cada paquete conducía a un “infierno de dependencias", con desajustes de versiones y conflictos difíciles de resolver. Además, los IDEs sufrían una degradación del rendimiento al tener que mantener contextos de análisis separados para cada paquete, lo que aumentaba el uso de memoria.

La introducción de **Pub Workspaces en Dart 3.6** es la solución oficial y definitiva a estos problemas. Permite que todo el monorepo comparta una única resolución de dependencias, garantizando la coherencia y mejorando el rendimiento.

### **1.3. Orquestación con Melos: Configuración y Scripts Centrales**

Con la gestión de dependencias ahora manejada de forma nativa por Pub Workspaces, el rol de Melos ha evolucionado. Ya no es la herramienta principal para el enlace de dependencias (una función ahora absorbida por pub), sino que se ha consolidado como el orquestador de alto nivel indispensable para flujos de trabajo complejos en el monorepo. Melos se encarga de ejecutar tareas como análisis de código, pruebas, generación de código y, crucialmente, la gestión del ciclo de vida de versionado y publicación de paquetes.

Esta relación es simbiótica y representa una clara separación de responsabilidades:

- **pub** gestiona el *qué* (el grafo de dependencias y su resolución).
- **Melos** gestiona el *cómo* (los flujos de trabajo del desarrollador y la automatización).

Esta distinción es clave para entender la cadena de herramientas moderna de un monorepo de Flutter, ya que se apoya en la herramienta oficial de Dart para la función crítica de resolución de dependencias, aumentando la robustez y estabilidad del sistema.

#### **Configuración Base de `melos.yaml`**

El proyecto define un archivo `melos.yaml` en la raíz del repositorio para centralizar scripts y prepararlo para crecer de forma ordenada. Actualmente Melos gestiona el paquete principal del proyecto y expone scripts comunes para análisis, formato, testing, limpieza y generación de código.

Scripts principales:

- `melos run analyze`: ejecuta `flutter analyze`.
- `melos run format`: valida el formato del código.
- `melos run format:fix`: aplica formato automáticamente.
- `melos run test`: ejecuta tests con cobertura en paquetes que tengan carpeta `test`.
- `melos run test:selective`: ejecuta tests solo en paquetes modificados desde `origin/main`.
- `melos run build`: ejecuta `build_runner` solo en paquetes que dependan de `build_runner`.
- `melos run clean`: ejecuta `flutter clean`.

#### **El Poder de los Filtros de Melos**

Una de las características más potentes de Melos es la posibilidad de ejecutar comandos sobre un subconjunto de paquetes. Esto mejora mucho la eficiencia, especialmente en pipelines de CI o en repositorios que luego crezcan a múltiples apps o packages.

Filtros más importantes:

- `--diff="<ref>"`: ejecuta un comando solo en paquetes que hayan cambiado desde una referencia de Git determinada.
- `--dir-exists=<directorio>`: limita la ejecución a paquetes que tengan un directorio concreto, por ejemplo `test`.
- `--depends-on=<paquete>`: ejecuta un comando solo en paquetes que dependan de una librería específica, por ejemplo `build_runner`.

Tabla de scripts recomendados:

| Script | Comando | Descripción | Ejemplo de uso con filtros |
| --- | --- | --- | --- |
| `analyze` | `melos exec -- "flutter analyze"` | Ejecuta el analizador estático de Dart y Flutter. | `melos run analyze --scope="*auth*"` |
| `format` | `melos exec -- "dart format . --output=none --set-exit-if-changed"` | Verifica que el código esté correctamente formateado. | `melos run format --diff="origin/main"` |
| `test` | `melos exec --dir-exists=test -- "flutter test --no-pub --coverage"` | Ejecuta pruebas en paquetes con carpeta `test` y genera cobertura. | `melos run test --scope="*animal*"` |
| `build` | `melos exec --depends-on="build_runner" -- "dart run build_runner build --delete-conflicting-outputs"` | Ejecuta la generación de código solo donde corresponde. | `melos run build --scope="*auth*"` |
| `clean` | `melos exec -- "flutter clean"` | Limpia los artefactos de compilación de todos los paquetes. | `melos run clean` |

### **Clasificación de Módulos dentro del Proyecto**

- **Features:** Los módulos dentro de `lib/features/` encapsulan funcionalidades orientadas al usuario, como `animal_register`, `rfid_scan` o futuras pantallas de listado y detalle. Cada feature contiene su propia UI, gestión de estado y contratos de negocio.
  - *La regla arquitectónica más importante es:* Una feature no debe depender directamente de otra feature. Si varias funcionalidades necesitan compartir lógica o componentes, eso debe vivir en una capa compartida del proyecto.
- **Módulos compartidos:** Las capacidades reutilizables y transversales viven fuera de `features/`, principalmente en:
  - **`lib/app/`:** composición global de la aplicación, router y tema.
  - **`lib/core/`:** UI compartida, tokens visuales, widgets reutilizables, utilidades y piezas comunes.
  - **`lib/brick/`:** infraestructura offline-first, modelos persistibles, repository central, adapters y esquema local.

### **Uso de Freezed en el Proyecto**

`freezed` forma parte del stack base del proyecto y se utilizará como convención general para clases inmutables y generación de código repetitivo.

Se usará principalmente en:

- **Modelos de datos:** entidades de dominio, modelos de infraestructura y DTOs cuando aplique.
- **Estados de UI:** estados de `Cubit` o `Bloc`, especialmente cuando haya operaciones async o múltiples variantes de estado.
- **Eventos o acciones:** cuando una feature use `Bloc` con eventos explícitos.
- **Objetos de configuración o contratos inmutables:** cuando convenga evitar mutaciones accidentales y disponer de `copyWith`, comparación por valor y serialización.

### **Qué aporta Freezed**

- Inmutabilidad por defecto.
- `copyWith`.
- Igualdad por valor (`==` y `hashCode`).
- Unions / sealed states para modelar variantes de estado.
- Integración con serialización cuando se combine con `json_serializable`.

### **Criterio práctico**

- Si una clase representa datos o estado del sistema, en general conviene usar `freezed`.
- Si se trata de helpers pequeños, extensiones, validators, formatters o use cases simples, no es necesario.

### ***Tutoriales:(puede cambiar)***
**Implementación de la Capa de Presentación**
La capa de Presentación es la responsable de gestionar toda la lógica relacionada con la interfaz de usuario, incluyendo la captura de eventos, la gestión del estado reactivo y el renderizado de la UI. Esta capa actúa como puente entre la interacción del usuario y la lógica de negocio, garantizando una separación clara de responsabilidades.  
**Principios fundamentales:**
• Utilizar gestión de estado reactiva basada en streams.  
• Mantener separación estricta de la lógica de negocio.  
• Nunca acceder directamente a repositorios o servicios externos.  
• Garantizar modularidad y autonomía del paquete.  
**Estructura de la Capa de Presentación**
Dentro de cada paquete de funcionalidad, la capa de presentación se organiza en tres submódulos principales:  

presentation/
├── bloc/                          # Controladores de estado
│   ├── feature_bloc.dart          # BLOC para estado complejo/global
│   ├── feature_cubit.dart         # Cubit para estado simple/local
│   ├── feature_event.dart         # Eventos del BLOC
│   └── feature_state.dart         # Estados del BLOC/Cubit
├── pages/
│   └── feature_page.dart          # Pantallas principales (Vista principal de la funcionalidad)
└── widgets/
└── feature_widget.dart        # Componentes reutilizables específicos del feature

### Responsabilidades por Submódulo

### bloc/cubit

- Contiene la lógica de gestión de estado.
- Define eventos y estados asociados.
- Orquesta el flujo de datos entre UI y Dominio.
- Maneja efectos secundarios y validaciones de UI.

### pages

- Representa las pantallas o vistas principales.
- Consume los controladores de estado (BLOC/Cubit).
- Coordina la composición de widgets.
- Implementa navegación y lifecycle hooks.

### widgets

- Componentes reutilizables específicos del feature.
- Encapsulan lógica de UI repetitiva.
- Pueden consumir BLOC/Cubit del contexto padre.
- Mantienen cohesión con el feature.

### BLOC vs Cubit: Criterios de Selección

### Cuándo Usar BLOC

- Estado global o compartido entre múltiples features.
- Lógica compleja con múltiples flujos de datos.
- Necesidad de eventos explícitos con nombres semánticos.
- Operaciones que requieren transformers (debounce, throttle, etc.).
- Estado que persiste entre sesiones (HydratedBloc).

### Cuándo Usar Cubit

- Estado local o de scope limitado.
- Lógica simple con flujos de datos directos.
- No requiere eventos explícitos.
- Operaciones síncronas o async simples.
- Gestión de estado de un solo widget o componente.

### Tabla Comparativa


| **Aspecto**      | **BLOC**                       | **Cubit**                |
| ---------------- | ------------------------------ | ------------------------ |
| **Scope**        | Global / Multi-feature         | Local / Single-feature   |
| **Complejidad**  | Alta (múltiples flujos)        | Baja (flujos simples)    |
| **Eventos**      | Explícitos con semántica clara | Métodos directos         |
| **Transformers** | Soportado (debounce, throttle) | No aplicable             |
| **Testabilidad** | Alta (eventos + estados)       | Alta (métodos + estados) |


## Gestión de Estado con BLOC

### Anatomía de un BLOC

Un BLOC completo consta de tres partes:

1. **Events:** Define todas las acciones posibles.
2. **State:** Define todos los estados posibles.
3. **BLOC:** Procesa eventos y emite estados.

### 1. Definición de Events

Dart

```
@freezed
class AnimalRegisterEvent with _$AnimalRegisterEvent {
  const factory AnimalRegisterEvent.loadForm() = LoadForm;

  const factory AnimalRegisterEvent.rfidRead(String rfid) = RfidRead;

  const factory AnimalRegisterEvent.submitAnimal({
    required String rfid,
    required String identificadorInterno,
    required String sexo,
    required String raza,
  }) = SubmitAnimal;

  const factory AnimalRegisterEvent.clearForm() = ClearForm;
}
```

**Buenas Prácticas en Eventos:**

- Usar `freezed` para inmutabilidad y generación de código.
- Nombres verbales que describan la acción (`loadForm`, `submitAnimal`).
- Incluir solo los datos necesarios para la operación.
- Evitar lógica dentro de los eventos.

### 2. Definición de State

Dart

```
@freezed
class ShoppingCartState with _$ShoppingCartState{
  const factory ShoppingCartState({
    @Default(Initial<List<ShoppingCartModel>>())
    ResultState<List<ShoppingCartModel>> cartsResult,

    @Default(Initial<ShoppingCartModel>())
    ResultState<ShoppingCartModel> updateCartItemResult,

    @Default(Initial<ShoppingCartModel>())
    ResultState<ShoppingCartModel> removeCartItemResult,

    @Default(Initial<ShoppingCartModel>())
    ResultState<ShoppingCartModel> addCartItemResult,

    @Default(Initial<bool>())
    ResultState<bool> deleteCartResult,

    Event<ShoppingCartSnackbarType>? showTopSnackbar,
    ShoppingCartModel? selectedCart,
  }) = _ShoppingCartState;
}
```

**Buenas Prácticas en Estados:**

- Usar `freezed` para `copyWith` y comparación automática.
- Separar estados de diferentes operaciones (permite loading individual).
- Usar `ResultState<T>` para operaciones async.

### 3. Event Handlers

Dart

```
class ShoppingCartBloc extends Bloc<ShoppingCartEvent, ShoppingCartState>{
  final FetchShoppingCartsUseCase _fetchShoppingCartsUseCase;
  final AddItemToCartUseCase _addItemToCartUseCase;
  // otros use cases

  ShoppingCartBloc(
    this._fetchShoppingCartsUseCase,
    this._addItemToCartUseCase,
  ) : super(const ShoppingCartState()) {
    // Registrar handlers para cada evento
    on<FetchCarts>(_fetchCarts, transformer: restartable());
    on<AddProduct>(_addProduct);
    on<RemoveProduct>(_removeProduct);
  }

  void _fetchCarts(
    FetchCarts event,
    Emitter<ShoppingCartState> emitter,
  ) async {
    emitter(state.copyWith(cartsResult: const ResultState.loading()));

    final result = await _fetchShoppingCartsUseCase.fetchShoppingCarts();

    result.fold(
      (exception) => emitter(
        state.copyWith(cartsResult: ResultState.error(error: exception)),
      ),
      (shoppingCarts) => emitter(
        state.copyWith(cartsResult: ResultState.data(data: shoppingCarts)),
      ),
    );
  }
}
```

**Buenas Prácticas en Handlers:**

- Un handler por evento, mantener responsabilidad única.
- Usar transformers cuando sea necesario (`debounce`, `throttle`, `restartable`).
- Emitir estado de loading antes de operaciones async.
- Usar `fold` para manejar `Either<Exception, Data>`.
- Emitir estados inmutables con `copyWith`.

### Transformers Útiles

Dart

```
// Cancelar eventos previos cuando llega uno nuevo
on<FetchCarts>(_fetchCarts, transformer: restartable());

// Ignorar eventos mientras uno está en proceso
on<AddProduct>(_addProduct, transformer: sequential());

// Procesar todos los eventos en paralelo
on<LoadRecommendations>(_loadRecommendations, transformer: concurrent());

// Aplicar debounce a eventos frecuentes
on<SearchProducts>(
  _searchProducts,
  transformer: (events, mapper) => events.debounceTime(
    const Duration(milliseconds: 300),
  ).asyncExpand(mapper),
);
```

## Gestión de Estado con Cubit

### Anatomía de un Cubit

Un Cubit es más simple que un BLOC y consta de dos partes:

1. **State:** Define todos los estados posibles.
2. **Cubit:** Contiene métodos que emiten estados.

### 1. Definición de State

Dart

```
@freezed
class CartRecommendationsState with _$CartRecommendationsState{
  const factory CartRecommendationsState({
    @Default(ResultState<CartRecommendationsData>.initial())
    ResultState<CartRecommendationsData> recommendations,
    @Default(false) bool isEmpty,
  }) = _CartRecommendationsState;
}
```

### 2. Implementación del Cubit

Dart

```
@injectable
class CartRecommendationCubit extends Cubit<CartRecommendationsState>{
  final GetCartRecommendationsUseCase _getCartRecommendationsUseCase;
  final ShoppingCartBloc _shoppingCartBloc;
  final GetHomeStoreUseCase _getHomeUseCase;

  CartRecommendationCubit(
    this._getCartRecommendationsUseCase,
    this._shoppingCartBloc,
    this._getHomeUseCase,
  ) : super(const CartRecommendationsState());

  Future<void> loadRecommendations() async {
    final selectedCart = _shoppingCartBloc.state.selectedCart;
    if (selectedCart == null) {
      _emitEmptyState('No selected cart.');
      return;
    }

    emit(state.copyWith(recommendations: const ResultState.loading()));

    final result = await _getCartRecommendationsUseCase.call(
      storeId: selectedCart.store.id,
      subsidiaryId: selectedCart.store.subsidiaryId,
      cartItems: selectedCart.items,
    );

    result.fold(
      (error) => emit(
        state.copyWith(recommendations: ResultState.error(error: error)),
      ),
      (recommendations) => emit(
        state.copyWith(recommendations: ResultState.data(data: recommendations)),
      ),
    );
  }
}
```

**Buenas Prácticas en Cubit:**

- Métodos públicos con nombres descriptivos.
- Emitir loading antes de operaciones async.
- Manejar casos edge dentro de los métodos.
- Usar métodos privados para lógica auxiliar.
- Mantener métodos cortos y enfocados.

### Cubit con Debouncing

Para casos donde se necesita debouncing sin transformers de BLoC:

Dart

```
@injectable
class CartProductCubit extends Cubit<CartProductState>{
  final ShoppingCartBloc _shoppingCartBloc;
  final ProductModel _product;
  late Debouncer _debouncer;

  CartProductCubit(
    this._shoppingCartBloc,
    @factoryParam this._product,
  ) : super(CartProductState(/* initial state */)) {
    _debouncer = Debouncer();
  }

  void editQuantity(num quantity, {Duration? debounceDuration}) {
    if (state.quantity == quantity) return _debouncer.cancel();

    emit(state.copyWith(updatingProduct: true));

    _debouncer.debounce(
      duration: debounceDuration ?? const Duration(seconds: 1),
      onDebounce: () => _shoppingCartBloc.add(
        ShoppingCartEvent.editProduct(_product, quantity),
      ),
    );
  }

  @override
  Future<void> close() async {
    _debouncer.cancel();
    super.close();
  }
}
```

## Comunicación entre Componentes

### Flujo de Comunicación

image.png

### 1. Proveer Estado: BlocProvider

Para hacer disponible un BLoC/Cubit en el árbol de widgets:

Dart

```
// Singleton global provisto una vez en el árbol
class ShoppingCartPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingCartBloc, ShoppingCartState>(
      bloc: getIt<ShoppingCartBloc>(), // Obtener singleton
      listener: (context, state) {
        // Efectos secundarios
      },
      builder: (context, state) {
        // Renderizar UI
        return const CartItemsListSection();
      },
    );
  }
}

// Cubit local creado para el widget
class CartItemsListSection extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemBuilder: (context, index) {
        return BlocProvider<CartProductCubit>(
          create: (context) => getIt.get<CartProductCubit>(
            param1: products[index].product,
          )..initCartProduct(),
          child: ShoppingCartProduct(item: products[index]),
        );
      },
    );
  }
}
```

### 2. Consumir Estado: BlocBuilder

Para reconstruir widgets cuando cambia el estado:

Dart

```
class ProductQuantityAndMeasurementUnit extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartProductCubit, CartProductState>(
      builder: (context, state) {
        final cubit = context.read<CartProductCubit>();

        return CounterButtonV2(
          value: state.quantity,
          onChanged: (value) => cubit.editQuantity(value),
        );
      },
    );
  }
}
```

**Optimización con buildWhen:**

Dart

```
BlocBuilder<CartProductCubit, CartProductState>(
  buildWhen: (previous, current) =>
    !current.updatingProduct && !current.removingProduct,
  builder: (context, state) {
    // Solo se reconstruye cuando NO está actualizando o removiendo
    return ProductImage(product: state.product);
  },
);
```

### 3. Reaccionar a Estados: BlocListener

Para ejecutar efectos secundarios sin reconstruir:

Dart

```
class ShoppingCartPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return BlocListener<ShoppingCartBloc, ShoppingCartState>(
      bloc: getIt<ShoppingCartBloc>(),
      listener: (context, state) {
        // Navegar cuando el carrito está vacío
        if (state.selectedCart == null || (state.selectedCart?.items.isEmpty ?? true)) {
          getIt<ShopCubit>().toggleLoading(false);
          context.pop();
          return;
        }

        // Mostrar toast en error
        if (state.updateCartItemResult.maybeWhen(orElse: () => false, error: (error) => true)) {
          CartToast.warningMessage(context, ShopStrings.outOfStock);
          return;
        }

        // Controlar loading global
        if (state.cartsResult.isLoadingState()) {
          getIt<ShopCubit>().toggleLoading(true);
        } else {
          getIt<ShopCubit>().toggleLoading(false);
        }
      },
      child: const text('Cart Widget Tree'),
    );
  }
}
```

**Optimización con listenWhen:**

Dart

```
BlocListener<CartProductCubit, CartProductState>(
  listenWhen: (previous, current) => current.removingProduct,
  listener: (context, state) {
    // Solo escucha cuando removingProduct es true
    getIt<ShopCubit>().toggleLoading(true);
  },
  child: const text('Widget Tree'),
);
```

### 4. Combinar Builder y Listener: BlocConsumer

Para renderizar Y reaccionar simultáneamente:

Dart

```
class CartStoreHeaderSection extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CartHeaderMessageCubit>()..loadHeaderMessage(cart.store.name),
      child: BlocConsumer<CartHeaderMessageCubit, CartHeaderMessageState>(
        listener: (context, state) {
          state.messageResult.maybeWhen(
            error: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al cargar el mensaje')),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.messageResult.when(
            initial: () => _buildHeaderLayout(
              messageWidget: _buildDefaultMessageContent(),
            ),
            loading: () => const SizedBox.shrink(),
            data: (message) => _buildHeaderLayout(
              messageWidget: _buildCustomMessageContent(message),
            ),
            error: (error) => _buildHeaderLayout(
              messageWidget: _buildDefaultMessageContent(),
            ),
          );
        },
      ),
    );
  }
}
```

### 5. Acceso Directo al BLOC/Cubit

Dart

```
// Para leer el BLOC sin escuchar cambios
final cubit = context.read<CartProductCubit>();
cubit.editQuantity(newValue);

// Para leer el estado actual (causa rebuild en cambios)
final state = context.watch<CartProductCubit>().state;

// Para acceder al BLoC sin BuildContext
final bloc = getIt<ShoppingCartBloc>();
bloc.add(const ShoppingCartEvent.fetchCarts());
```

## Integración con la Capa de Dominio

### Principio de Comunicación

La capa de Presentación **NUNCA** debe:

- Acceder directamente a repositorios.
- Llamar servicios externos.
- Implementar lógica de negocio.

Toda interacción con datos debe ser a través de **Use Cases**.

### Diagrama de Flujo de la Integración

Plaintext

```
┌──────────────────────────────────────────────────┐        ┌────────────────────────┐
│ Capa de Presentación                             │        │ Capa de Dominio        │
│                                                  │        │                        │
│  ┌─────────────────┐       ┌──────────────────┐  │ call() │   ┌────────────────┐   │
│  │    UI Event     ├──────►│       BLOC       ├──┼────────┼──►│    Use Case    │   │
│  │ (Button Press)  │       │  Event Handler   │  │        │   │   execute()    │   │
│  └─────────────────┘       └───────┬──────────┘  │◄───────┼───┤                │   │
│                                    │             │ returns│   └───┬────────┬───┘   │
│                                    │             │        │       │       ▲        │
│                                    ▼             │        │ invoke│       │ returns│
│                            New State             │        │       ▼       │        │
│                      (Loading, Data, Error)      │        │   ┌───────────┴────┐   │
│                                                  │        │   │   Repository   │   │
│                                                  │        │   └────────────────┘   │
└──────────────────────────────────────────────────┘        └────────────────────────┘
```

## Patrón ResultState

### Introducción

`ResultState<T>` es una clase fundamental que encapsula el estado de cualquier operación asíncrona en la aplicación. Proporciona una forma estandarizada y *type-safe* de manejar los diferentes estados por los que pasa una operación: inicial, cargando, éxito con datos, o error.

### Definición de la Clase

Dart

```
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:/exceptions/domain_exception.dart';

part 'result_state.freezed.dart';

@freezed
class ResultState<T> with _$ResultState<T>{
  const factory ResultState.initial() = Initial<T>;
  const factory ResultState.loading() = Loading<T>;
  const factory ResultState.data({required T data}) = Data<T>;
  const factory ResultState.error({required DomainException error}) = Error<T>;
}
```

### Características Técnicas

- **Generic Type `<T>`:** Permite encapsular cualquier tipo de dato.
- **Freezed:** Genera código inmutable con `copyWith`, `==`, y `toString`.
- **Sealed Union:** Los 4 estados son mutuamente excluyentes.
- **Pattern Matching:** Soporta `.when()`, `.maybeWhen()`, `.map()`, etc.

### Descripción de Cada Estado

### 1. Initial

- **Propósito:** Estado por defecto antes de que se dispare cualquier operación.
- **Cuándo Usar:** Al inicializar el `state` de un BLoC/Cubit , después de resetear una operación , o cuando no hay datos aún y no se ha iniciado la carga.

Dart

```
// En el State
@freezed
class MyState with _$MyState{
  const factory MyState({
    @Default(ResultState.initial()) ResultState<UserData> userResult,
  }) = _MyState;
}

// En la UI Pattern
state.userResult.when(
  initial: () => const EmptyStateWidget(),
  // otros estados...
);
```

### 2. Loading

- **Propósito:** Indica que una operación asíncrona está en progreso.
- **Cuándo Usar:** Inmediatamente antes de llamar a un *use case* o durante cualquier operación que tome tiempo (API calls, DB queries, etc.).

Dart

```
// En el Cubit/Bloc
Future<void> loadUser(String userId) async {
  emit(state.copyWith(userResult: const ResultState.loading()));
  final result = await _getUserUseCase(userId);
  // procesar resultado...
}

// En la UI Pattern
state.userResult.when(
  loading: () => const CircularProgressIndicator(),
  // otros estados...
);
```

### 3. Data

- **Propósito:** Operación completada exitosamente con datos.
- **Cuándo Usar:** Cuando el *use case* retorna un resultado exitoso , datos cargados desde caché , o una operación completada sin errores.

Dart

```
// En el Cubit/Bloc
result.fold(
  (exception) => /* manejar error */,
  (userData) => emit(
    state.copyWith(userResult: ResultState.data(data: userData)),
  ),
);

// En la UI Pattern
state.userResult.when(
  data: (userData) => UserProfileWidget(user: userData),
  // otros estados...
);
```

### 4. Error

- **Propósito:** Operación falló con un error.
- **Cuándo Usar:** Cuando el *use case* retorna una falla o excepción , errores de red, validación, negocio , timeouts o errores inesperados.

Dart

```
// En el Cubit/Bloc
result.fold(
  (exception) => emit(
    state.copyWith(userResult: ResultState.error(error: exception)),
  ),
  (userData) => /* manejar éxito */,
);

// En la UI Pattern
state.userResult.when(
  error: (exception) => ErrorWidget(
    message: exception.message,
    onRetry: () => cubit.loadUser(userId),
  ),
  // otros estados...
);
```

### Patrones de Consumo en UI

### 1. Pattern Matching Completo (.when)

Se usa cuando necesitamos manejar todos los estados explícitamente.

Dart

```
state.recommendations.when(
  initial: () => const EmptyStateWidget(),
  loading: () => const LoadingIndicator(),
  data: (data) => DataWidget(data: data),
  error: (error) => ErrorWidget(error: error),
);
```

- **Ventajas:** Es exhaustivo (el compilador te fuerza a manejar todos los casos) , *type-safe* y *refactor-friendly*.

### 2. Pattern Matching Parcial (.maybeWhen)

Se usa cuando solo nos interesan algunos estados específicos.

Dart

```
// Verificar si hay error
final hasError = state.updateCartItemResult.maybeWhen(
  orElse: () => false,
  error: (error) => true,
);

// Obtener datos si existen, null en caso contrario
final data = state.recommendations.maybeWhen(
  orElse: () => null,
  data: (recommendations) => recommendations,
);

// Ejemplo en un BlocListener
BlocListener<ShoppingCartBloc, ShoppingCartState>(
  listener: (context, state) {
    if (state.updateCartItemResult.maybeWhen(orElse: () => false, error: (error) => true)) {
      CartToast.warningMessage(context, ShopStrings.outOfStock);
    }
  },
);
```

### 3. Pattern Matching Condicional (.whenOrNull)

Se usa cuando queremos extraer datos de un estado específico directamente.

Dart

```
// Retorna el cart si está en estado data, null en caso contrario
final cart = state.cartsResult.whenOrNull<ShoppingCartModel?>(
  data: (cartList) => cartList.firstWhereOrNull((someCart) => someCart.store.id == storeId),
);

// Extraer mensaje de error
final errorMessage = state.userResult.whenOrNull(
  error: (error) => error.message,
);
```

### 4. Map Pattern (.map)

Se usa para transformar cada estado en un tipo de objeto común.

Dart

```
final widgetOrNull = state.recommendations.map(
  initial: (_) => null,
  loading: (_) => const LoadingWidget(),
  data: (dataState) => DataWidget(data: dataState.data),
  error: (errorState) => ErrorWidget(error: errorState.error),
);
```

### Múltiples ResultStates en un Estado (Loading Granular)

Patrón recomendado para trackear operaciones asíncronas independientes dentro de una misma pantalla:

Dart

```
@freezed
class ShoppingCartState with _$ShoppingCartState{
  const factory ShoppingCartState({
    // Estado principal de la vista
    @Default(Initial<List<ShoppingCartModel>>()) ResultState<List<ShoppingCartModel>> cartsResult,

    // Cada operación CRUD tiene su propio ResultState independiente
    @Default(Initial<ShoppingCartModel>()) ResultState<ShoppingCartModel> updateCartItemResult,
    @Default(Initial<ShoppingCartModel>()) ResultState<ShoppingCartModel> removeCartItemResult,
    @Default(Initial<ShoppingCartModel>()) ResultState<ShoppingCartModel> addCartItemResult,
    @Default(Initial<bool>()) ResultState<bool> deleteCartResult,

    Event<ShoppingCartSnackbarType>? showTopSnackbar,
    ShoppingCartModel? selectedCart,
  }) = _ShoppingCartState;
}
```

### Ventajas de este patrón:

1. Dart
  **Loading Granular:** Cada componente visual maneja su propio loader sin bloquear toda la pantalla.
2. Dart
  **Manejo de Errores Independiente:** Cada operación puede fallar individualmente sin tumbar ni afectar los datos de las demás.
3. Dart
  **Estados Simultáneos:** Múltiples operaciones asíncronas pueden ejecutarse a la vez en paralelo.

## Inyección de Dependencias en la UI (Setup con Injectable)

Dart

```
// Singleton: una sola instancia viva para toda la app (se usa para estados globales)
@lazySingleton
class ShoppingCartBloc extends Bloc<ShoppingCartEvent, ShoppingCartState>{ ... }

// Injectable: nueva instancia creada cada vez que se solicita (se usa para cubits locales)
@injectable
class CartHeaderMessageCubit extends Cubit<CartHeaderMessageState>{ ... }

// Factory con parámetros inyectados en runtime
@injectable
class CartProductCubit extends Cubit<CartProductState>{
  final ShoppingCartBloc _bloc;
  final ProductModel _product;

  CartProductCubit(
    this._bloc,
    @factoryParam this._product,
  ) : super(const CartProductState());
}
```

### Tabla de Scopes y Lifecycles


| **Scope**         | **Cuándo Crear**            | **Cuándo Destruir**         | **Uso Típico**                         |
| ----------------- | --------------------------- | --------------------------- | -------------------------------------- |
| **LazySingleton** | Primera vez que se solicita | Nunca (App lifecycle)       | Estado global (ej: `ShoppingCartBloc`) |
| **Singleton**     | Al iniciar la app           | Nunca (App lifecycle)       | Servicios core de infraestructura      |
| **Injectable**    | Cada vez que se solicita    | Al cerrar el widget / scope | Estado local (ej: `CartProductCubit`)  |


## Guía de Buenas Prácticas (DOs y DON'Ts)

### 1. Separación Total de Responsabilidades

- ❌ **INCORRECTO (Lógica de negocio y repositorios metidos en la vista):**Dart
- **CORRECTO (Vista limpia que solo renderiza estados mapeados):**Dart

### 2. Gestión de Recursos Libres de Memory Leaks

- ❌ **INCORRECTO (Streams abiertos sin cerrar):**Dart
- **CORRECTO (Uso de close/dispose para cancelar subscripciones):**Dart

### 3. Inmutabilidad Absoluta del Estado

- ❌ **INCORRECTO (Mutación directa de colecciones de memoria):**Dart
- **CORRECTO (Generar nuevas instancias creando copias de la anterior):**Dart

### 4. Naming Conventions Estrictas

- **BLoCs:** Nombre del feature + sufijo "Bloc" (`ShoppingCartBloc`).
- **Cubits:** Nombre del feature + sufijo "Cubit" (`CartProductCubit`).
- **Events:** Verbos que describan explícitamente la acción (`addProduct`, `removeProduct`).
- **States:** Adjetivo o sustantivo que describa la situación actual (`updatingProduct`, `quantity`).
- **Métodos de Cubit:** Verbos en imperativo (`loadRecommendations`, `editQuantity`).

### 5. Optimización de Rebuilds en la UI

- Usar `buildWhen` y `listenWhen` para filtrar cuándo reconstruir o disparar efectos basados en cambios de propiedades específicas.
- Usar constructores `const` siempre que sea posible para evitar ciclos de renderizado innecesarios en elementos estáticos.
- Extraer widgets complejos a sub-clases `StatelessWidget` dedicadas si no dependen directamente del cambio de estado del árbol padre.

## Análisis con very_good_analysis

### Configuración

La integración se realiza siguiendo estos dos pasos:

1. **Añadir la dependencia:** Se agrega `very_good_analysis` a las dependencias de desarrollo (`dev_dependencies`) en el archivo `pubspec.yaml`.

YAML

```
dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: 5.1.0 # Usar la última versión fija
```

1. **Incluir las reglas:** Se crea o modifica el archivo `analysis_options.yaml` en la raíz del proyecto para que incluya las reglas del paquete.

YAML

```
include: package:very_good_analysis/analysis_options.yaml
```

## Implementación de la Capa de Dominio

La Capa de Dominio es el núcleo de la arquitectura limpia. Representa la lógica de negocio pura, libre de detalles de implementación como frameworks, APIs o bases de datos. Esta capa contiene las reglas fundamentales que definen el comportamiento del sistema y es completamente independiente de cualquier tecnología externa.

### Principios Fundamentales

- **Independencia**: No depende de frameworks, UI o infraestructura.
- **Testabilidad**: Lógica de negocio completamente testeable sin dependencias externas.
- **Inmutabilidad**: Los modelos son inmutables por defecto usando `freezed`.
- **Seguridad de Tipos**: Utiliza tipos fuertes para prevenir errores en tiempo de compilación.
- **Manejo Funcional de Errores**: Usa `Either<L, R>` para gestión explícita de éxito/error.

### Responsabilidades de la Capa de Dominio

1. **Definición de Entidades y Modelos**: Representa los conceptos centrales del negocio con sus atributos y comportamientos.
2. **Contratos de Repositorios**: Define interfaces abstractas que especifican cómo se accede a los datos, sin implementar los detalles.
3. **Casos de Uso (Use Cases)**: Implementa la lógica de negocio específica, orquestando el flujo entre repositorios y coordinando operaciones complejas.
4. **Validaciones de Negocio**: Aplica reglas y restricciones que garantizan la integridad del dominio.
5. **Transformaciones de Datos**: Convierte datos entre diferentes representaciones dentro del contexto del negocio.

### Estructura Organizativa

La capa de Dominio sigue una estructura consistente en cada feature o paquete:

```
domain/
  model/
    # Entidades y modelos de negocio
    entity_a/
      entity_a_model.dart
      entity_a_model.freezed.dart
      entity_a_model.g.dart
    entity_b/
      entity_b_model.dart
  repository/
    # Contratos (interfaces) de repositorios
    feature_repository.dart
    secondary_repository.dart
  usecase/
    # Casos de uso con lógica de negocio
    operation_a_usecase.dart
    operation_b_usecase.dart
	  helper_manager.dart
```

image.png

## Modelos de Dominio

Los modelos de dominio representan las entidades del negocio. Se crean usando `freezed` para garantizar inmutabilidad, seguridad de tipos y funcionalidades útiles como `copyWith`, `==`, `toString` y serialización JSON.

### Características de los Modelos

1. **Inmutabilidad**: Todos los modelos son inmutables, lo que previene modificaciones accidentales y facilita el seguimiento de cambios.
2. **Generación de Código**: Utilizan `freezed` para generar código boilerplate automáticamente:
  - Constructores `const factory`
    - Métodos `copyWith`
    - Implementación de `==` y `hashCode`
    - Método `toString`
    - Serialización JSON (con `json_serializable`)
3. **Validaciones y Lógica de Negocio**: Los modelos pueden incluir getters calculados y métodos de extensión con lógica específica del dominio.

### Anotaciones Especiales

### `@Default(valor)`

Proporciona valores por defecto para propiedades opcionales.

```
@freezed
class CartRecommendationsData with _$CartRecommendationsData {
  const factory CartRecommendationsData({
    @Default([]) List<ProductModel> products, // Lista vacía por defecto
    required CartRecommendationType type,
  }) = CartRecommendationsData;
}
```

### `@JsonKey(includeFromJson: false, includeToJson: false)`

Excluye propiedades de la serialización JSON de lectura o de escritura, útil para valores no persistibles (cálculos o valores que se usan solo en la UI).

```
@freezed
class StoreModel with _$StoreModel {
  const factory StoreModel({
    required String id,
    @JsonKey(includeFromJson: false, includeToJson: false) Color? backgroundColor, // No se serializa ni se lee del JSON
  }) = StoreModel;
}
```

### Generación de Archivos

Para generar los archivos `.freezed.dart` y `.g.dart`:

```
dart pub run build_runner build --delete-conflicting-outputs
```

## Repositorios

Los repositorios en la capa de Dominio son interfaces abstractas que definen contratos para el acceso a datos. No contienen implementación; solo declaran qué operaciones están disponibles.

### Características de los Repositorios

1. **Abstractos**: Solo definen firmas de métodos.
2. **Independientes de Implementación**: No conocen detalles de APIs, bases de datos o caché.
3. **Retornan Either**: Todos los métodos retornan `Either<DomainException, T>` para manejo explícito de errores.
4. **Async por Naturaleza**: La mayoría de operaciones son `Future<Either<...>>`.

### Estructura de un Repositorio

```
abstract class ShoppingCartRepository {
  Future<Either<DomainException, List<ShoppingCartModel>>> fetchShoppingCarts();

  Future<Either<DomainException, ShoppingCartModel>> addShoppingCartItem(
    AddShoppingCartItemOperationModel model,
  );

  Future<Either<DomainException, bool>> deleteShoppingCart({
    required String storeId,
    required String storeSubsidiaryId,
  });
}
```

### BaseRepository: Clase Base para Repositorios

`BaseRepository` es una clase abstracta que proporciona funcionalidades comunes para las implementaciones de todos los repositorios. Su principal responsabilidad es encapsular el patrón de ejecución de llamadas a fuentes de datos, manejando automáticamente la conversión de respuestas y errores.

Sin embargo, todos los repositorios abstractos no deberían de conocer a `BaseRepository`, ya que forma parte de la Capa de Datos. Dentro del Anexo de Capa de Datos se puede ver en detalle cómo funciona.

## Casos de Uso (Use Cases)

Los casos de uso (Use Cases) son las unidades de lógica de negocio. Cada uno representa una operación específica que el usuario o el sistema puede realizar. Son el punto de entrada de la capa de Dominio desde la capa de Presentación.

### Responsabilidades de un Caso de Uso

1. **Orquestar Operaciones**: Coordinar llamadas a uno o varios repositorios, servicios de dominio, o incluso otros casos de uso. Los casos de uso son el punto de orquestación principal de la capa de dominio.
2. **Aplicar Reglas de Negocio**: Implementar la lógica de negocio específica de la aplicación (*application business rules*). Esto incluye validaciones de flujo, transformaciones de datos, cálculos, y decisiones basadas en el contexto del caso de uso.
3. **Propagar Errores de Dominio**: Los casos de uso reciben `Either<DomainException, T>` de los repositorios y los propagan o enriquecen con contexto de negocio. NO deben transformar excepciones técnicas (eso es responsabilidad del repository).

```
// CORRECTO: Repository ya maneja conversión de errores
Future<Either<DomainException, Data>> execute() async {
  final result = await _repository.fetch(); // Ya retorna Either
  return result.fold(
    (error) => Left(error), // Propagar o agregar contexto
    (data) => _applyBusinessLogic(data),
  );
}

// INCORRECTO: Use case manejando excepciones técnicas
Future<Either<DomainException, Data>> execute() async {
  try {
    final data = await _repository.fetch(); // X Lanza Exception
    return Right(data);
  } catch (e) {
    return Left(DomainException(e.toString())); // X No es su responsabilidad
  }
}
```

1. **Coordinar Operaciones de Negocio Relacionadas**: Ejecutar operaciones adicionales que sean parte integral del flujo de negocio, como llamar a otros casos de uso o actualizar estados relacionados. Evitar *side effects* de infraestructura (logs, analytics) que deberían manejarse mediante interceptors o *domain events*.

```
// CORRECTO: Coordinación de lógica de negocio
Future<Either<DomainException, ShoppingCartModel>> execute() async {
  final result = await _repository.addItem(model);
  return result.fold(
    (error) => Left(error),
    (cart) async {
      // Otras operaciones de negocio relacionadas
      await _markCartReminderAsModifiedUseCase(cart.storeId);
      return Right(cart);
    },
  );
}

// CONSIDERAR: Side effects múltiples pueden indicar necesidad de Domain Events
Future<Either<DomainException, ShoppingCartModel>> execute() async {
  final result = await _repository.addItem(model);
  return result.fold(
    (error) => Left(error),
    (cart) async {
      _eventBus.fire(CartUpdatedEvent(cart)); // Otros componentes reaccionan
      return Right(cart);
    },
  );
}
```

1. **Retornar Resultados Consistentes**: Devolver `Either<DomainException, T>` a la capa de Presentación, garantizando un manejo de errores funcional y predecible.

### Límites Importantes: Lo que UN CASO DE USO NO debe hacer

- **NO** debe contener lógica de UI o dependencias de presentación.
- **NO** debe manejar excepciones técnicas de infraestructura (HTTP, DB, etc.).
- **NO** debe construir widgets o formatear texto para UI.
- **NO** debe acceder directamente a APIs, bases de datos o servicios externos.
- **NO** debe de convertir entre DTOs y Modelos (eso es del Repository).
- **EVITAR** acumular demasiados *side effects* (considerar Domain Events o dividir el caso de uso).

### Estructura de un Caso de Uso

```
@injectable
class AddItemToCartUseCase {
  final ShoppingCartRepository _repository;
  final MarkCartReminderAsModifiedUseCase _markCartReminderAsModifiedUseCase;
  final CartCountManager _cartCountManager;

  AddItemToCartUseCase(
    this._repository,
    this._markCartReminderAsModifiedUseCase,
    this._cartCountManager,
  );

  Future<Either<DomainException, ShoppingCartModel>> addShoppingCartItem(
    AddShoppingCartItemOperationModel model,
  ) async {
    final result = await _repository.addShoppingCartItem(model);
    return result.fold(
      (exception) => result,
      (data) => _markCartAsModified(data),
    );
  }

  Future<Either<DomainException, ShoppingCartModel>> _markCartAsModified(
    ShoppingCartModel data,
  ) async {
    await _cartCountManager.add(data);
    await _markCartReminderAsModifiedUseCase(data.store.id);
    return Right(data);
  }
}
```

### Patrones en Casos de Uso

### 1. Caso de Uso Simple (Single Repository)

Ejecuta una operación única en un repositorio.

```
@injectable
class RemoveItemFromCartUseCase {
  final ShoppingCartRepository _repository;

  RemoveItemFromCartUseCase(this._repository);

  Future<Either<DomainException, ShoppingCartModel>> removeShoppingCartItem(
    RemoveShoppingCartItemOperationModel model,
  ) async {
    return await _repository.removeShoppingCartItem(model);
  }
}
```

### 2. Caso de Uso con Coordinación (Multiple Operations)

Orquesta múltiples operaciones y gestiona *side effects*.

```
@injectable
class DeleteShoppingCartUseCase {
  final ShoppingCartRepository _repository;
  final RemoveCartReminderUseCase _removeCartReminderUseCase;
  final CartCountManager _cartCountManager;

  DeleteShoppingCartUseCase(
    this._repository,
    this._removeCartReminderUseCase,
    this._cartCountManager,
  );

  Future<Either<DomainException, bool>> deleteShoppingCart({
    required String storeId,
    required String storeSubsidiaryId,
  }) async {
    final result = await _repository.deleteShoppingCart(
      storeId: storeId,
      storeSubsidiaryId: storeSubsidiaryId,
    );
    return result.fold(
      (exception) => result,
      (success) => _postDeleteCleanup(storeId, success),
    );
  }

  Future<Either<DomainException, bool>> _postDeleteCleanup(
    String storeId,
    bool result,
  ) async {
    await _cartCountManager.remove(storeId);
    await _removeCartReminderUseCase(storeId);
    return Right(result);
  }
}
```

### 3. Caso de Uso con Lógica Compleja

Implementa reglas de negocio sofisticadas con validaciones y transformaciones.

```
@injectable
class GetCartRecommendationsUsecase {
  final CategoryAndProductsRepository _categoryRepository;
  final HomeCategoriesRepository _homeCategoriesRepository;

  static const int _minimumRecommendedProducts = 3;
  static const int _maxRecommendedProducts = 15;

  GetCartRecommendationsUsecase(
    this._categoryRepository,
    this._homeCategoriesRepository,
  );

  Future<Either<DomainException, CartRecommendationsData>> call({
    required String storeId,
    required String subsidiaryId,
    required List<ShoppingCartItemModel> cartItems,
  }) async {
    // 1. Obtener productos excluidos
    final excludedIds = _getExcludedProductIds(cartItems);

    // 2. Obtener categorías configuradas
    final categoryId = _homeCategoriesRepository.buyAgainCategoryId;
    if (categoryId == null) return _createEmptyError();

    // 3. Fetch productos recomendados
    final result = await _categoryRepository.fetchSwimlines(
      storeId: storeId,
      categoryId: categoryId,
      pageSize: 30,
    );

    // 4. Filtrar y transformar
    return result.fold(
      (error) => Left(error),
      (categoryProducts) {
        final filtered = _filterExcludedProducts(
          categoryProducts.products,
          excludedIds,
        );

        if (filtered.length < _minimumRecommendedProducts) {
          return _createEmptyError();
        }

        return Right(CartRecommendationsData(
          products: filtered.take(_maxRecommendedProducts).toList(),
          type: CartRecommendationType.buyAgain,
        ));
      },
    );
  }

  List<String> _getExcludedProductIds(List<ShoppingCartItemModel> cartItems) {
    return cartItems.map((item) => item.product.productId).toList();
  }

  List<ProductModel> _filterExcludedProducts(
    List<ProductModel> products,
    List<String> excludedIds,
  ) {
    return products
        .where((product) => !excludedIds.contains(product.productId))
        .toList();
  }

  Left<DomainException, CartRecommendationsData> _createEmptyError() {
    return const Left(
      DomainException(
        message: 'No recommendations available',
        exceptionType: DataException.customError('No recommendations available'),
      ),
    );
  }
}
```

## Manejo de Errores: Either y DomainException

La capa de Dominio utiliza programación funcional para el manejo de errores mediante el tipo `Either<L, R>` de la librería `dartz`.

### `Either<L, R>`

`Either` representa un valor que puede ser `Left` (error) o `Right` (éxito).

```
Either<DomainException, ShoppingCartModel>
```

- **Left**: Contiene una excepción de dominio (`DomainException`).
- **Right**: Contiene el valor exitoso (`ShoppingCartModel`).

### `DomainException`

Es la representación de errores en el dominio. Encapsula información estructurada sobre el error.

```
@freezed
class DomainException with _$DomainException {
  const factory DomainException({
    @Default('') String message,
    @Default(0) int code,
    required DataException exceptionType,
    @Default(null) Payload? payload,
  }) = DomainException;
}
```

### Tipos de `DataException`

```
@freezed
abstract class DataException with _$DataException {
  const factory DataException.connectionError() = ConnectionError;
  const factory DataException.timeoutError() = TimeoutError;
  const factory DataException.unauthorizedError(int codeError) = UnauthorizedError;
  const factory DataException.customError(String message) = CustomError;
  const factory DataException.unexpectedError({UnexpectedErrorDto? data}) = UnexpectedError;
  const factory DataException.unProcessableRequest(int httpCode, UnProcessableRequestDto data) = UnProcessableRequest;
}
```

### Retornar Éxito en Caso de Uso

```
Future<Either<DomainException, ShoppingCartModel>> addItem(model) async {
  final cart = await _repository.addShoppingCartItem(model);
  return Right(cart); // Éxito
}
```

### Retornar Error en Caso de Uso

```
Future<Either<DomainException, CartRecommendationsData>> getRecommendations() async {
  if (products.isEmpty) {
    return const Left(
      DomainException(
        message: 'No recommendations available',
        exceptionType: DataException.customError('No recommendations available'),
      ),
    );
  }
  return Right(data);
}
```

### Manejar Resultados con `fold`

`fold` permite manejar ambos casos (error y éxito) de forma explícita:

```
final result = await _repository.fetchShoppingCarts();
return result.fold(
  (exception) {
    // Manejar error
    print('Error: ${exception.message}');
    return Left(exception);
  },
  (carts) {
    // Manejar éxito
    print('Carts fetched: ${carts.length}');
    return Right(carts);
  },
);
```

### Encadenar Operaciones

Cuando una operación depende del éxito de otra:

```
Future<Either<DomainException, bool>> deleteCart() async {
  final deleteResult = await _repository.deleteShoppingCart(
    storeId: storeId,
    subsidiaryId: subsidiaryId,
  );

  return deleteResult.fold(
    (exception) => Left(exception), // Propagar error
    (success) async {
      // Solo si el delete fue exitoso
      await _cartCountManager.remove(storeId);
      await _removeReminderUseCase(storeId);
      return Right(success);
    },
  );
}
```

### Ventajas de Either

1. **Explícito**: Los errores son parte del tipo de retorno.
2. **Seguro**: El compilador fuerza el manejo de ambos casos.
3. **Funcional**: Permite encadenar operaciones de forma elegante.
4. **Testeable**: Fácil de simular en tests unitarios.

## Patrones y Convenciones

### 1. Nomenclatura

- **Modelos**: Sufijo `Model` (ej. `ShoppingCartModel`, `StoreModel`).
- **Repositorios**: Sufijo `Repository` (ej. `ShoppingCartRepository`, `HomeCategoriesRepository`).
- **Casos de Uso**: Sufijo `UseCase` y verbos en imperativo: *Fetch, Add, Remove, Edit* (ej. `AddItemToCartUseCase`, `FetchShoppingCartsUseCase`).
- **Managers**: Sufijo `Manager` (ej. `CartCountManager`).

### 2. Patrón de Validación

Las validaciones de negocio van en casos de uso o en getters de modelos:

```
// En modelo (lógica simple relacionada con el estado)
@freezed
class ShoppingCartItemModel with _$ShoppingCartItemModel {
  const ShoppingCartItemModel._();

  bool get isWeightable {
    return product.measurementUnits.any((unit) => unit.label == 'kg');
  }
}

// En caso de uso (reglas de negocio complejas)
class ValidateCartUseCase {
  Either<DomainException, bool> validate(ShoppingCartModel cart) {
    if (cart.totalAmount < cart.minAmountPurchase) {
      return Left(DomainException(
        message: 'Minimum purchase amount not met',
        exceptionType: DataException.customError('MIN_AMOUNT_ERROR'),
      ));
    }
    return const Right(true);
  }
}
```

## Inyección de Dependencias

Todos los casos de uso y managers se registran en el contenedor de inyección de dependencias usando `injectable`.

### Anotaciones de Inyección

- `**@injectable**`: Para casos de uso y servicios estándar.

```
@injectable
class AddItemToCartUseCase {
  final ShoppingCartRepository _repository;
  AddItemToCartUseCase(this._repository);
}
```

- `**@lazySingleton**`: Para managers o servicios que deben tener una única instancia compartida, pero que se instancian solo cuando se necesitan.

```
@lazySingleton
class CartCountManager {
  final AppSessionRepository _appSessionRepository;
  CartCountManager(this._appSessionRepository);
}
```

- `**@singleton**`: Para servicios que se instancian inmediatamente al iniciar la app.

```
@singleton
class ConfigurationManager {
  // Instancia única creada al inicio
}
```

### Registro de Implementaciones

Las interfaces (repositorios) se declaran en la capa de Dominio, pero sus implementaciones se registran en la capa de Datos:

```
// Domain: Interfaz
abstract class ShoppingCartRepository {
  Future<Either<DomainException, List<ShoppingCartModel>>> fetchShoppingCarts();
}

// Data: Implementación
@Injectable(as: ShoppingCartRepository)
class ShoppingCartRepositoryImpl implements ShoppingCartRepository {
  @override
  Future<Either<DomainException, List<ShoppingCartModel>>> fetchShoppingCarts() async {
    // Implementación con API calls, mappers, etc.
  }
}
```

## Buenas Prácticas

### 1. Un Caso de Uso, Una Responsabilidad

Cada caso de uso debe tener una única responsabilidad clara.

- **Mal:**

```
class CartUseCase {
  Future<void> addItem() {}
  Future<void> removeItem() {}
  Future<void> clearCart() {}
  Future<void> applyDiscount() {}
}
```

- **Bien:**

```
class AddItemToCartUseCase { ... }
class RemoveItemFromCartUseCase { ... }
class ClearCartUseCase { ... }
class ApplyDiscountUseCase { ... }
```

### 2. Repositorios Agnósticos

Los repositorios no deben conocer frameworks o detalles de implementación.

- **Mal:**

```
abstract class ShoppingCartRepository extends BaseRepository { // Expone DTOs
  Future<Response> fetchShoppingCarts(); // X Expone Dio
  Future<Either<DomainException, Database>> getDatabase(); // Expone DB
}
```

- **Bien:**

```
abstract class ShoppingCartRepository {
  Future<Either<DomainException, List<ShoppingCartModel>>> fetchShoppingCarts();
}
```

### 3. Modelos Inmutables

Siempre usar `freezed` y nunca exponer mutabilidad.

- **Mal:**

```
class StoreModel {
  String id;
  String name;
  StoreModel(this.id, this.name);
}
```

- **Bien:**

```
@freezed
class StoreModel with _$StoreModel {
  const factory StoreModel({
    required String id,
    required String name,
  }) = StoreModel;
}
```

### 4. Errores Explícitos

Siempre usar `Either` para operaciones que pueden fallar.

- **Mal:**

```
Future<ShoppingCartModel?> fetchCart(); // X null = error?
Future<ShoppingCartModel> fetchCart(); // X Lanza excepciones?
```

- **Bien:**

```
Future<Either<DomainException, ShoppingCartModel>> fetchCart();
```

### 5. Casos de Uso Pequeños y Testeables

Preferir casos de uso pequeños que se puedan componer.

- **Bien:**

```
@injectable
class TrackSwimlaneProductUseCase {
  final SwimlaneTrackingRepository _repository;

  TrackSwimlaneProductUseCase(this._repository);

  Either<DomainException, void> add(String storeId, ProductModel product) {
    return _repository.addProduct(storeId, product);
  }
}
```

### 6. Documentación en Modelos Complejos

Documentar enums, uniones y lógica de negocio no obvia.

```
/// Tipos de recomendaciones para productos en el carrito.
///
/// [buyAgain] Productos que el usuario compró previamente.
/// [highlights] Productos destacados o en tendencia.
enum CartRecommendationType {
  buyAgain,
  highlights,
}
```

### 7. Constantes en Casos de Uso

Extraer constantes mágicas a valores con nombre.

- **Mal:**

```
if (products.length < 3) return _error();
final limited = products.take(15).toList();
```

- **Bien:**

```
static const int _minimumRecommendedProducts = 3;
static const int _maxRecommendedProducts = 15;

if (products.length < _minimumRecommendedProducts) return _error();
final limited = products.take(_maxRecommendedProducts).toList();
```

# Implementación de la Capa de Datos

La Capa de Datos es la capa más externa de la arquitectura limpia. Es responsable de obtener y persistir datos desde y hacia fuentes externas (APIs REST, bases de datos locales, caché, etc.). Esta capa implementa las interfaces de repositorio definidas en la capa de Dominio y traduce entre el mundo externo y el mundo del dominio.

## Principios Fundamentales

- **Implementación de Contratos:** Implementa las interfaces de repositorio del dominio.
- **Conversión de Datos:** Transforma DTOs (de la API) a Modelos (del dominio).
- **Manejo de Infraestructura:** Gestiona detalles técnicos (HTTP, serialización, caché).
- **Independencia del Dominio:** El dominio no conoce esta capa.
- **Múltiples Fuentes:** Puede combinar datos de API, DB local, caché, etc.

## Responsabilidades de la Capa de Datos

1. **Comunicación con APIs Externas:** Realiza llamadas HTTP a servicios REST usando Retrofit y Dio.
2. **Conversión DTO** $\rightarrow$ **Model:** Mapea entre objetos de transferencia de datos (DTOs) y modelos de dominio.
3. **Gestión de Caché y Persistencia Local:** Maneja almacenamiento local con Shared Preferences, bases de datos SQLite/Hive, etc.
4. **Manejo de Errores Técnicos:** Captura excepciones de red, timeouts, errores de serialización y los convierte a `DataException`.
5. **Implementación de Repositorios:** Provee implementaciones concretas de las interfaces de repositorio del dominio.

## Estructura Organizativa

La capa de Datos sigue una estructura consistente en cada feature:

```
data/
  dto/
    # Data Transfer Objects (request/response)
    add_item_body.dart
    cart_response.dart
    *.freezed.dart      # Generados por freezed
    *.g.dart            # Generados por json_serializable
  service/
    # Definiciones de API con Retrofit
    cart_service.dart
    *.g.dart            # Generados por retrofit_generator
  source/
    # DataSources (abstracción de fuentes de datos)
    cart_source.dart         # Interfaz abstracta
    cart_remote_source.dart  # Implementación remota (API)
  repository/
    # Implementaciones de repositorios
    cart_repository_impl.dart
```

## DTOs - Data Transfer Objects

Los DTOs son objetos que representan la estructura de datos que viaja entre el cliente y el servidor. Son la representación exacta del JSON que envía/recibe la API.

### Características de los DTOs

1. Usan `freezed` para inmutabilidad y generación de código.
2. Usan `json_serializable` para serialización automática.
3. Nombrados con el sufijo `Body` o `Response`.
4. Implementan `BaseDtoResponse<T>` cuando son respuestas que se mapean a modelos.

> **Nota:** Usamos `freezed` como regla general. En DTOs legados sin freezed se utiliza `@JsonKey` para mapear nombres de campos.

### Tipos de DTOs

### A. Request Bodies (Cuerpos de Petición)

DTOs que se envían al servidor en peticiones POST, PUT, DELETE.

```
@freezed
class AddShoppingCartItemBody with _$AddShoppingCartItemBody {
  const factory AddShoppingCartItemBody({
    required String storeId,
    required String storeSubsidiaryId,
    required String productId,
    required String productStockPriceId,
    required num unitCount,
  }) = _AddShoppingCartItemBody;

  factory AddShoppingCartItemBody.fromJson(Map<String, dynamic> json) =>
      _$AddShoppingCartItemBodyFromJson(json);
}
```

**Uso:**

```
final body = AddShoppingCartItemBody(
  storeId: '123',
  storeSubsidiaryId: '789',
  productId: '456',
  productStockPriceId: 'abc',
  unitCount: 2,
);

// Se serializa automáticamente a JSON por Retrofit
await service.addShoppingCartItem(body);
```

### B. Response DTOs (Respuestas de la API)

DTOs que reciben datos del servidor e implementan `BaseDtoResponse<T>` para poder ser convertidos automáticamente a modelos de dominio.

```
@freezed
class ShoppingCartResponse with _$ShoppingCartResponse implements BaseDtoResponse<ShoppingCartModel> {
  const ShoppingCartResponse._();

  const factory ShoppingCartResponse({
    required String shoppingCartId,
    required int productCount,
    required double totalAmount,
    required List<ShoppingCartItemResponse> items,
  }) = _ShoppingCartResponse;

  factory ShoppingCartResponse.fromJson(Map<String, dynamic> json) =>
      _$ShoppingCartResponseFromJson(json);

  @override
  ShoppingCartModel toDomainModel() {
    return ShoppingCartModel(
      cartId: shoppingCartId,
      productCount: productCount,
      totalAmount: totalAmount,
      items: items.map((e) => e.toDomainModel()).toList(),
    );
  }
}
```

### Generación de DTOs

Para generar los archivos `.freezed.dart` y `.g.dart`:

```
dart pub run build_runner build --delete-conflicting-outputs
```

## Repository Implementations

Las implementaciones de repositorio (`Repository Implementations`) son las clases concretas que implementan los contratos definidos en la capa de Dominio, uniendo la l?gica pura con la infraestructura real de datos.

En este proyecto, cuando una feature trabaja con Brick como infraestructura offline-first, el repositorio implementado en `data/` es quien se encarga de traducir la entidad de dominio al modelo persistible y delegar la operaci?n al repository de `lib/brick/`.

### Caracter?sticas

1. Implementan interfaces del Dominio.
2. No contienen l?gica de negocio.
3. Orquestan mappers e infraestructura.
4. Devuelven modelos del Dominio o resultados del proyecto (`Result<T>`).
5. Encapsulan c?mo se persiste y sincroniza la informaci?n.

### Ejemplo de Repository Implementation

```dart
class AnimalRepositoryImpl implements AnimalRepository {
  AnimalRepositoryImpl({
    required AppBrickRepository brickRepository,
  }) : _brickRepository = brickRepository;

  final AppBrickRepository _brickRepository;

  @override
  Future<Result<Animal>> registrarAnimal(Animal animal) async {
    try {
      final brickModel = AnimalBrickMapper.toBrick(animal);
      final saved = await _brickRepository.upsertAnimal(brickModel);

      return Success(AnimalBrickMapper.toDomain(saved));
    } catch (_) {
      return const Error('No se pudo registrar el animal.');
    }
  }
}
```

## Mappers - Conversi?n entre Dominio e Infraestructura

Los mappers se usan para traducir entre:

- entidades del dominio
- modelos t?cnicos de persistencia o sincronizaci?n

Cuando una feature usa Brick, el caso m?s habitual es mapear:

- `features/.../domain/entities/...`
- `brick/models/...`

### Ejemplo de Mapper

```dart
class AnimalBrickMapper {
  static BrickAnimalModel toBrick(Animal animal) {
    return BrickAnimalModel(
      idRfid: animal.idRfid,
      identificadorInterno: animal.identificadorInterno,
      sexo: animal.sexo,
      raza: animal.raza,
      fechaAlta: animal.fechaAlta,
    );
  }

  static Animal toDomain(BrickAnimalModel model) {
    return Animal(
      idRfid: model.idRfid,
      identificadorInterno: model.identificadorInterno,
      sexo: model.sexo,
      raza: model.raza,
      fechaAlta: model.fechaAlta,
    );
  }
}
```

## Buenas Pr?cticas

### 1. El Repository no lleva l?gica de negocio

El repositorio coordina acceso a datos, persistencia y sincronizaci?n, pero no valida reglas de negocio.

### 2. El Dominio no conoce Brick

Las entidades, contratos y casos de uso deben permanecer independientes de la infraestructura offline-first.

### 3. Los mappers a?slan lo t?cnico

Si el modelo de Brick cambia, el impacto debe quedar contenido en `data/mappers` y `data/repositories`.

### 4. No todas las features necesitan la misma capa `data`

En features offline-first con Brick, la estructura m?nima puede ser:

- `mappers/`
- `repositories/`

En cambio, features que integren hardware, Bluetooth o SDKs externos pueden requerir `datasources/` u otros componentes t?cnicos propios.

## Arquitectura Completa de las 3 Capas

La integraci?n de las capas sigue un flujo simple y predecible:

1. **Capa de Presentaci?n**
   - La UI o el `Cubit` invoca un caso de uso.
2. **Capa de Dominio**
   - El caso de uso llama a un contrato de repositorio.
3. **Capa de Datos**
   - La implementaci?n del repositorio traduce la entidad de dominio a un modelo Brick y delega la operaci?n a `AppBrickRepository`.
4. **Infraestructura Offline-First**
   - Brick persiste localmente y luego sincroniza con remoto cuando corresponda.

```text
UI / Cubit / Bloc
  -> UseCase
    -> Repository (contrato de dominio)
      -> RepositoryImpl
        -> Mapper Dominio <-> Brick
          -> AppBrickRepository
            -> almacenamiento local + sincronizacion remota
```
```
