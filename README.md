# Trazabilidad Ganadera Inteligente

Plataforma offline-first de gestión y trazabilidad ganadera para pequeños y medianos productores bovinos de Córdoba, Argentina. Cumple con la Resolución SENASA 530/2025 e integra con SIGBIOTRAZA.

> Proyecto Final — Ingeniería en Sistemas de Información, UTN FRC, 2026.

## Estructura del repositorio

Este es un **monorepo**: un único repositorio en GitHub que aloja los distintos subproyectos en carpetas hermanas. Cada subproyecto mantiene su propio toolchain, sus propias dependencias y su propio pipeline de CI.

```
.
├── /mobile        App Flutter (Dart) — frontend del productor
├── /backend       API FastAPI (Python) — lógica de negocio y SENASA
├── /ai_models     Pipeline de entrenamiento del modelo de visión
├── /database      Migraciones Alembic y políticas RLS de Supabase
├── /docs          Documentación académica y técnica
├── /scripts       Utilidades de desarrollo (seeders, helpers)
└── /.github       Workflows de CI/CD y plantillas
```

La justificación de la decisión de monorepo está en `docs/Gestion_de_la_Configuracion.docx`, sección 1.

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Frontend móvil | Flutter (Dart) + Brick + SQLite |
| Backend API | FastAPI (Python 3.12) + SQLAlchemy + Alembic |
| Tareas asíncronas | Celery + Redis |
| Base de datos | PostgreSQL 16 (Supabase) + PostGIS |
| Auth y storage | Supabase Auth + Supabase Storage |
| Visión artificial | TensorFlow Lite (on-device) + TensorFlow/Keras (training) |
| RFID | Bastones Bluetooth comerciales (Tru-Test / Datamars) |
| Infraestructura | Docker + GitHub Actions + Railway/Render |

El detalle completo del stack y las alternativas descartadas está en `docs/Stack_Tecnologico_Trazabilidad_Ganadera.docx`.

## Requisitos previos

Antes de clonar, instalar en tu máquina:

- **Git** 2.40 o superior.
- **Docker Desktop** (incluye Docker Compose). Necesario para levantar PostgreSQL y Redis en local.
- **Python 3.12** (recomendado vía `pyenv` o `uv`). Solo si vas a trabajar en `/backend` o `/ai_models`.
- **Flutter SDK 3.24** o superior, con Android Studio y un emulador Android configurado. Solo si vas a trabajar en `/mobile`.
- **Cuenta de Supabase** del proyecto (pedirla al Scrum Master).

## Clonado del proyecto

```bash
git clone https://github.com/<organizacion>/trazabilidad-ganadera.git
cd trazabilidad-ganadera
```

## Configuración de secretos

Ningún secreto se commitea al repositorio. Cada subproyecto incluye un archivo `.env.example` que lista las variables necesarias.

Para cada subproyecto en el que vayas a trabajar, copiá el ejemplo y completá los valores:

```bash
cp backend/.env.example backend/.env
cp mobile/.env.example mobile/.env
```

Los valores reales se comparten por canal seguro entre integrantes del equipo (no por chat ni por email). Ver `docs/Gestion_de_la_Configuracion.docx`, sección 6.

## Levantar el backend

```bash
cd backend

# Crear entorno virtual e instalar dependencias
python -m venv .venv
source .venv/bin/activate          # en Windows: .venv\Scripts\activate
pip install -e ".[dev]"

# Levantar PostgreSQL y Redis vía Docker Compose
docker compose up -d postgres redis

# Aplicar migraciones
alembic upgrade head

# Levantar el servidor con autoreload
uvicorn app.main:app --reload
```

La API queda disponible en `http://localhost:8000`. La documentación interactiva (Swagger) en `http://localhost:8000/docs`.

## Levantar la app móvil

```bash
cd mobile

# Resolver dependencias
flutter pub get

# Generar código (Brick, freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Correr la app en el emulador o dispositivo conectado
flutter run
```

Para apuntar al backend local en lugar de Supabase, ajustar `API_BASE_URL` en `mobile/.env`.

## Pipeline de modelos de IA

```bash
cd ai_models
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Los notebooks de entrenamiento están en `ai_models/notebooks/`. El tracking de experimentos se hace con MLflow; los modelos entrenados se exportan a TFLite y se copian a `mobile/assets/models/` para embeberse en la app.

## Cómo se trabaja

- **Modelo de ramas, code review y convención de commits:** definidos en `docs/Working_Agreement.docx`, sección 4.
- **Estrategia de testing y cobertura mínima:** `docs/Plan_de_Testing.docx`.
- **Decisiones técnicas (ADRs):** `docs/adr/`.
- **Backlog y tarjetas activas:** Linear (link en el canal `#general` de Slack del equipo).

Resumen rápido:

- Ramas: `feature/<nombre-tarea>` desde `develop`.
- Commits: Conventional Commits en español, formato `tipo(módulo): descripción`.
- PRs: a `develop`, con al menos una aprobación y CI en verde.
- Releases: tags semánticos (`v0.1`, `v0.2`, ...) en `main` al cerrar cada instancia académica.

## Equipo

| Integrante | Legajo | Rol |
|---|---|---|
| Ernesto Petrich | 90431 | Product Owner |
| Augusto Höhlke | 90263 | Scrum Master |
| Luciano Gomez | 89058 | Backend / ML / Infraestructura |
| Agustín Molina | 92351 | Frontend |
| Franco Filippa | 92191 | QA |

## Licencia

Proyecto académico — UTN FRC, Cátedra Proyecto Final, 2026. Uso restringido al equipo y a la cátedra.
