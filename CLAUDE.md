# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. It is the single most important reference for AI-assisted work here: read it fully before generating, editing, or reviewing any code. It encodes decisions and conventions the team has already agreed on in the Working Agreement, the Configuration Management document, and the Test Plan — those documents are the source of truth and this file mirrors them.

## Project Overview

**VITA** is a monorepo for a livestock traceability platform (_trazabilidad ganadera_) for small and medium cattle producers in Córdoba, Argentina. It is the academic final project (_Proyecto Final_) at UTN FRC, 2026.

- **Domain goal**: digitize the animal life cycle (identification, weighing, health events, movements, commercialization), surface productive KPIs (notably GPD — daily weight gain), and comply with **SENASA Resolution 530/2025** (mandatory individual electronic identification), generating export files for **SIGBIOTRAZA / SIGSA**.
- **Defining constraint**: **offline-first**. Producers work in the field ("la manga") with no connectivity. Every feature must be designed first for how it works without internet; connectivity is an optional enhancement, never a requirement.
- **Multi-tenant**: data is isolated per establishment (`establecimiento`) via Supabase Row Level Security. Six roles: `administrator`, `owner`, `veterinarian`, `capataz`, `asset_manager`, `external_buyer`.
- **Identification / reading**: an animal's identifier can be read by RFID Bluetooth, entered manually, or captured by **OCR of the visual ear tag**. OCR is a valid reading method alongside the others — design identification flows so any of these can supply the identifier.
- **Economic module**: in scope. The platform records the money side of the operation — sales (`ventas`), operating expenses (`egresos_operativos`), cash flow and gross margin — and may value stock in pesos, pull external market quotes (Rosgan/Liniers), and simulate or project a sale. Treat it like any other module: offline-first, multi-tenant, tested.

### Hard constraints — do NOT do these

These are settled team/product decisions. Do not reintroduce them even if they seem like reasonable improvements:

- **Do not** propose or implement blockchain for traceability.
- **Do not** weaken offline-first to simplify an implementation. This applies to the economic module too: an external price feed is an enhancement, never a precondition — every screen must render and every operation must be recordable with the last cached quote, or with none at all.

## Monorepo Structure

The repository is a **monorepo on GitHub**. Each top-level folder is an independent subproject with its own toolchain, linter config, tests, and CI workflow.

- `backend/` — FastAPI (Python 3.12) API server.
- `mobile/` — Flutter (Dart) offline-first mobile app (Brick + SQLite sync queue).
- `ai_models/` — TensorFlow/Keras vision model training pipeline (weight estimation), MLflow tracking, TFLite conversion. **Not part of the MVP / Release 1.**
- `database/` — Alembic migrations, SQLAlchemy/SQLModel models, Row Level Security policies and SQL functions for Supabase. No real pilot data ever lives here.
- `docs/` — Academic instances, Working Agreement, Test Plan, ADRs, manuals. Formal deliverables in `.docx`; technical docs in Markdown.
- `scripts/` — Dev utilities (seeders, synthetic data generators, deployment helpers).
- `.github/` — CI/CD workflows, PR/issue templates, repo security config.

## Backend Commands

```bash
cd backend

# Setup (uses uv as package manager)
uv venv && source .venv/bin/activate
uv sync

# Run dev server (factory pattern)
python main.py
# Or directly:
uvicorn core.server:create_fastapi_app --reload --factory

# Lint / format (Ruff is the project standard — run before opening a PR)
ruff check .
ruff format .

# Run all tests
pytest

# Run a single test file
pytest tests/test_health.py

# Run a single test function
pytest tests/test_auth.py::test_login_and_me

# Coverage (CI enforces 70% global / 85% on critical modules)
pytest --cov

# Migrations (Alembic lives in backend/alembic; CI runs `alembic heads`)
alembic upgrade head          # apply pending migrations
alembic downgrade -1          # roll back the last one
alembic check                 # models vs. DB must show no pending diff
alembic revision --autogenerate -m "descripcion"
```

> Migrations are **incremental deltas** — there is no baseline revision, because the
> schema predates Alembic. Write every `upgrade()` defensively (check with
> `sa.inspect(connection)` before creating) so it can run on a database that already
> has the objects. Each migration also ships a mirror `backend/scripts/*.sql` as a
> manual-intervention fallback for the Supabase SQL Editor.

## Backend Architecture

The backend uses a **factory pattern** via `core/server.py:create_fastapi_app()`. The entrypoint is `backend/main.py`.

The agreed architecture is layered **Router → Service → Repository**, with Pydantic schemas (`schemas.py`) as API DTOs and SQLModel models (`models.py`) as the ORM/persistence layer. Keep these layers separated: routers never touch the database directly, services hold business logic, repositories own all data access.

**Core layer** (`backend/core/`):

- `config.py` — Settings loaded from env vars via dotenv. Contains the `settings` singleton and the `EnvironmentOption` enum.
- `server.py` — FastAPI app factory. Wires up CORS, session middleware, custom middlewares, exception handler, and routes under the `/api/v1` prefix.
- `router.py` — `get_global_router()` aggregates all route modules.
- `contextmanager.py` — App lifespan: verifies the DB connection; creates tables in LOCAL/TEST envs (production uses Alembic migrations only).
- `middlewares.py` — camelCase→snake_case body conversion, request body caching, response time logging, custom exception handler.
- `logger.py` — Logging config.

**API layer** (`backend/api/`) — modular, one folder per resource:

- Each module (e.g. `api/auth/`, `api/animales/`) is self-contained: `router.py`, `service.py`, `repository.py`, `schemas.py`, and optionally `models.py`, `dependencies.py`, `exceptions.py`.
- `api/shared/schemas.py` — shared Pydantic models (`StandardResponse`, `Pagination`) used across modules.
- `api/auth/dependencies.py` — `get_current_user` dependency, importable by any module needing auth.
- **To add a new module**: create `api/<recurso>/` with the files above, then register its router in `core/router.py`.

**Database layer** (`database/`):

- `database.py` — Async SQLAlchemy engine, `AsyncSessionLocal`, `get_session()` dependency.
- `models.py` — `Base` SQLModel with `id` (UUID), `created_at`, `updated_at` (and `deleted_at` for soft-deletable, sync-able entities).
- `search.py` — Safe ILIKE pattern helpers (`escape_like`, `like_pattern`).

> **Sync note (offline-first):** every sync-able entity uses a **client-generated UUID** primary key and carries `created_at` / `updated_at` / `deleted_at`. Conflict resolution is **last-write-wins by `updated_at`**. Deletes are soft (set `deleted_at`) so they also sync. Never use auto-increment integer PKs on sync-able tables.

## Key Conventions

These are enforced by the team. Code that violates them will be rejected at review.

**Naming (Configuration Management §2):**

- **Database tables**: Spanish, `snake_case`, **plural** — e.g. `animales`, `movimientos`, `eventos_sanitarios`.
- **Database columns**: Spanish, `snake_case` — e.g. `fecha_nacimiento`, `numero_caravana`, `peso_estimado`.
- **Foreign keys**: referenced table in singular + `_id` — e.g. `animal_id`, `establecimiento_id`.
- **API endpoints**: Spanish, `snake_case`, **plural**, versioned — e.g. `/api/v1/animales`, `/api/v1/establecimientos`, `/api/v1/movimientos`.
- **Python**: PEP8 — modules `snake_case`, classes `PascalCase`, functions/vars `snake_case`.
- **Dart**: Effective Dart — files `snake_case`, classes `PascalCase`, members `lowerCamelCase`.
- **ADRs**: `adr-NNNN-titulo-corto.md` (four-digit correlative). ADRs are never edited; a new ADR supersedes an old one.

**Git workflow (Working Agreement §4 — single source of truth):**

- **Branches**: GitFlow simplified. `main` (tagged releases `v0.1`, `v0.2`…), `develop` (integration base), `feature/[nombre-tarea]` (one per story, created from `develop`, deleted after merge), `hotfix/[nombre]` (urgent fixes on `main`, merged back to both `main` and `develop`).
- **Commits**: Conventional Commits in Spanish — `tipo(módulo): descripción`. Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
- **Pull Requests**: no code reaches `develop` without a PR. CI (lint + tests) must be green or the merge is blocked at repo level. At least one peer review is required; review priority is legibility, error handling, offline-first behavior, convention compliance. The PR author resolves conflicts with `develop` before requesting review. **The reviewer performs the merge, not the author.** PR title is descriptive and references the Linear card.

**API responses:**

- All endpoints wrap data in `StandardResponse(success, data, meta, errors)`.
- Incoming camelCase JSON bodies are auto-converted to snake_case by middleware.

**Auth:**

- Supabase Auth issues JWTs; the backend validates them via `python-jose`. The `get_current_user` dependency guards protected routes. `usuario` is the profile table, 1:1 with `auth.users`; never store passwords in app tables.

**Error handling:**

- No empty `try/except`. Errors in critical operations (weight capture, RFID read, sync) must be logged and surfaced with a user-friendly message — the app runs in rough field conditions where the producer cannot debug.

**Tests:**

- `pytest` with the `anyio` marker; async integration tests use `httpx.AsyncClient` + `ASGITransport`.
- New functionality requires tests. CI enforces **70% coverage global, 85% on critical modules** (sync, RLS/multi-tenant isolation, SENASA file generation, withdrawal-period calculation). Tests must actually exercise acceptance criteria — no empty tests or trivial asserts.

**Secrets & config (Configuration Management §6):**

- Never commit secrets (Supabase keys, JWT secrets, Railway/Render creds, external API keys). `.env` is gitignored; each subproject has a versioned `.env.example` documenting required vars with no real values. Production secrets live in GitHub Secrets.

## Definition of Ready / Definition of Done

A story is **Ready** when: it has clear, verifiable acceptance criteria; it's estimated in Story Points (Planning Poker); technical and legal dependencies are explicit (e.g. needs physical RFID baton? touches a specific SENASA 530/2025 field?); visual stories have an approved Figma design; it fits in one sprint.

A story is **Done** when: code is merged to `develop` via an approved PR; tests are written and all CI tests pass at the required coverage; it was tested manually in a real/emulated environment including the offline scenario when applicable; code review is approved by at least one peer; docs are updated (docstring, module README, new ADR if a technical decision was made); if it touches SENASA 530/2025, the Product Owner explicitly validates compliance; the Linear card is moved to Done with a comment linking the merged PR.

## AI Usage Policy (applies to Claude Code itself)

- Never paste real secrets, tokens, producer personal data, or identifiable pilot-field data into any AI tool. Use anonymized or synthetic data only.
- Code touching auth, secret handling, or permission validation must be written or finally reviewed by a human — never "paste and pray".
- All AI-generated code goes through the same PR + human review as hand-written code; the author remains responsible for its correctness and must understand it before committing.
- AI-assisted features must have automated tests.

## Project Management

- Tracking lives in **Linear** (team `Proyecto Final`, key `PRO`). Stories are written by the Product Owner. Reference the Linear card in branch names, commits, and PRs.
- Team & Scrum roles: **Ernesto** (Product Owner), **Augusto** (Scrum Master), **Lucho** (Backend / ML / Infra), **Agustín** (Frontend), **Franco** (QA).
- Sprints are 14 days. Estimation in Story Points via Planning Poker (Fibonacci). The Working Agreement is reviewed at each Sprint Planning.

## Tech Stack

| Layer       | Tech                                                                      |
| ----------- | ------------------------------------------------------------------------- |
| Backend API | FastAPI + SQLAlchemy + SQLModel + Alembic (Router → Service → Repository) |
| Database    | PostgreSQL 16 (Supabase) + PostGIS (Release 2: lote geolocation)          |
| Auth        | Supabase Auth + JWT (python-jose)                                         |
| Async tasks | Celery + Redis                                                            |
| Mobile      | Flutter (Dart) + Brick + SQLite (offline-first sync queue)                |
| AI/ML       | TensorFlow Lite (on-device) + TensorFlow/Keras (training) — Release 2     |
| Lint/format | Ruff (Python) · Dart Analyzer (Flutter)                                   |
| Infra       | Docker + GitHub Actions + Railway/Render                                  |
