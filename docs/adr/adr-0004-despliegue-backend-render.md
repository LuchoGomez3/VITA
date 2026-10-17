# ADR-0004 — Despliegue del backend en Render (plan free)

- **Estado:** propuesto
- **Fecha:** 2026-09-29

## Contexto

El backend solo corría en local. Hace falta una URL pública para la sincronización del
móvil y para las demos. Los usuarios son pocos (equipo y piloto) y no hay presupuesto
asignado. Las opciones evaluadas fueron Render y Railway. El repo es un monorepo, y el
backend importa `database/` desde la raíz.

## Decisión

- Render, plan **free**, con **un único entorno `production`** desplegado desde `main`.
- Imagen Docker (`backend/Dockerfile`) construida con la raíz del monorepo como contexto,
  declarada en `render.yaml` con filtro de build sobre `backend/**` y `database/**`.
- `autoDeploy` desactivado: GitHub Actions corre lint y tests, aplica
  `alembic upgrade head` y recién después dispara el deploy hook, porque el plan free no
  ofrece pre-deploy command.

## Consecuencias

- El servicio se duerme tras 15 min sin tráfico. Un workflow de keepalive lo mitiga, y
  el cliente de sync del móvil debe tolerar un arranque en frío de 30–60 s. Esto no
  afecta al offline-first: la cola local se reintenta.
- Las migraciones se aplican antes que el código nuevo, así que deben ser compatibles
  hacia atrás.
- Una sola instancia con un worker: el rate limit de auth en memoria sigue siendo válido.
- Camino de upgrade si el sleep o los 512 MB molestan: Render Starter (siempre
  encendido, con pre-deploy) o Railway Hobby. Los dos reutilizan el mismo Dockerfile.
